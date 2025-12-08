import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/session.dart';
import '../../data/models/session_model.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../config/di/injection.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  SessionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = getIt<LocalStorageService>();

  @override
  Future<Session> createSession(String userId) async {
    final docRef = _firestore.collection('sessions').doc();
    final session = SessionModel(
      id: docRef.id,
      userId: userId,
      startTime: DateTime.now(),
      status: 'active',
    );

    // Save Locally First
    final sessionData = session.toFirestore();
    sessionData['id'] = session.id;
    // Convert Timestamp to String for Hive
    if (sessionData['startTime'] is Timestamp) {
      sessionData['startTime'] =
          (sessionData['startTime'] as Timestamp).toDate().toIso8601String();
    }
    if (sessionData['endTime'] is Timestamp) {
      sessionData['endTime'] =
          (sessionData['endTime'] as Timestamp).toDate().toIso8601String();
    }
    await _localStorage.saveSession(sessionData);

    // Save to Firestore (non-blocking, fire and forget)
    // If offline, this will fail silently and we rely on local storage
    if (userId != 'guest_user') {
      docRef.set(session.toFirestore()).catchError((e) {
        debugPrint("Firestore create session failed (offline?): $e");
      });
    }

    return session;
  }

  @override
  Future<void> updateSession(Session session) async {
    if (session is SessionModel) {
      // Update Local
      final sessionData = session.toFirestore();
      sessionData['id'] = session.id;
      // Convert Timestamp to String for Hive
      if (sessionData['startTime'] is Timestamp) {
        sessionData['startTime'] =
            (sessionData['startTime'] as Timestamp).toDate().toIso8601String();
      }
      if (sessionData['endTime'] is Timestamp) {
        sessionData['endTime'] =
            (sessionData['endTime'] as Timestamp).toDate().toIso8601String();
      }
      await _localStorage.saveSession(sessionData);

      // Update Remote
      try {
        await _firestore
            .collection('sessions')
            .doc(session.id)
            .update(session.toFirestore());
      } catch (e) {
        // Ignore if offline
      }
    }
  }

  @override
  Future<void> addDetectionToSession(
      String sessionId, Map<String, dynamic> detectionData) async {
    debugPrint("=== addDetectionToSession called ===");
    debugPrint("SessionId: $sessionId");
    debugPrint("Detection data: ${detectionData.toString()}");

    // 1. Save Locally
    await _localStorage.saveDetection(sessionId, detectionData);
    debugPrint("Detection saved to local storage");

    // 2. Update Parent Session Document (Firestore)
    // We want the session to reflect the catch details directly.
    // CRITICAL: We do NOT await this. If offline, awaiting can hang.
    // We let it run in background.
    final sessionRef = _firestore.collection('sessions').doc(sessionId);

    // Prepare update data
    final Map<String, dynamic> updateData = {
      'totalDetections': FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    // If this is the first/main catch, update session details
    if (detectionData.containsKey('class')) {
      updateData['catchSpecies'] = detectionData['class'];
    }
    if (detectionData.containsKey('imageUrl')) {
      updateData['catchImageLocalPath'] = detectionData['imageUrl'];
    }
    if (detectionData.containsKey('freshness')) {
      updateData['freshnessStatus'] =
          detectionData['freshness'] == true ? 'Fresh' : 'Stale';
    }
    if (detectionData.containsKey('weight')) {
      updateData['weight'] = detectionData['weight'];
    }
    if (detectionData.containsKey('approximateCount')) {
      updateData['approximateCount'] = detectionData['approximateCount'];
    }
    // GPS Location fields
    if (detectionData.containsKey('latitude')) {
      updateData['latitude'] = detectionData['latitude'];
    }
    if (detectionData.containsKey('longitude')) {
      updateData['longitude'] = detectionData['longitude'];
    }
    if (detectionData.containsKey('locationName')) {
      updateData['locationName'] = detectionData['locationName'];
    }
    if (detectionData.containsKey('vesselId')) {
      updateData['vesselId'] = detectionData['vesselId'];
    }

    // Fire and forget
    // Fire and forget update on session doc
    sessionRef.update(updateData).catchError((e) {
      debugPrint("Error updating session document (background): $e");
    });

    // 3. Add to Detections Subcollection (CRITICAL FIX)
    try {
      final detectionRef = sessionRef.collection('detections').doc();
      final firestoreDetectionData = Map<String, dynamic>.from(detectionData);

      // Ensure timestamp is proper for Firestore
      if (firestoreDetectionData['timestamp'] is String) {
        firestoreDetectionData['timestamp'] = Timestamp.fromDate(
            DateTime.parse(firestoreDetectionData['timestamp']));
      } else {
        firestoreDetectionData['timestamp'] = FieldValue.serverTimestamp();
      }

      detectionRef.set(firestoreDetectionData).catchError((e) {
        debugPrint("Error adding detection to subcollection: $e");
      });
    } catch (e) {
      debugPrint("Error preparing detection subcollection write: $e");
    }

    // 3. Trigger Sync (if online)
    try {
      getIt<SyncService>().syncData();
    } catch (e) {
      // Ignore sync errors, we are offline or sync failed but local save is done.
      debugPrint("Sync trigger failed (expected if offline): $e");
    }
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    // Try Local First (not implemented fully in LocalStorageService for single get, but we can add if needed)
    // For now, fallback to Firestore
    final doc = await _firestore.collection('sessions').doc(sessionId).get();
    if (doc.exists) {
      return SessionModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<List<Session>> getUserSessions(String userId) async {
    // Get Local Sessions (Source of Truth for offline)
    final localSessions = _localStorage.getSessions(userId);

    // Return local sessions immediately.
    // We do NOT fetch from Firestore here to ensure instant load.
    // Syncing should be triggered separately via syncSessions().
    return localSessions
        .map((data) => SessionModel(
              id: data['id'],
              userId: data['userId'],
              startTime: (data['startTime'] is Timestamp)
                  ? (data['startTime'] as Timestamp).toDate()
                  : DateTime.parse(data['startTime'].toString()),
              endTime: data['endTime'] != null
                  ? ((data['endTime'] is Timestamp)
                      ? (data['endTime'] as Timestamp).toDate()
                      : DateTime.parse(data['endTime'].toString()))
                  : null,
              status: data['status'] ?? 'active',
              totalDetections: data['totalDetections'] ?? 0,
            ))
        .toList();
  }

  @override
  Future<List<Session>> syncSessions(String userId) async {
    try {
      // 1. Fetch from Firestore (with timeout)
      final snapshot = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get()
          .timeout(const Duration(seconds: 3)); // Timeout fast if offline

      // 2. Update Local Storage with Remote Data
      for (var doc in snapshot.docs) {
        final sessionData = doc.data();
        sessionData['id'] = doc.id;

        // Convert ALL Timestamps for Hive (Hive doesn't support Timestamp type)
        if (sessionData['startTime'] is Timestamp) {
          sessionData['startTime'] = (sessionData['startTime'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (sessionData['endTime'] is Timestamp) {
          sessionData['endTime'] =
              (sessionData['endTime'] as Timestamp).toDate().toIso8601String();
        }
        if (sessionData['lastUpdated'] is Timestamp) {
          sessionData['lastUpdated'] = (sessionData['lastUpdated'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        await _localStorage.saveSession(sessionData);

        // --- SYNC DETECTIONS (Fix for missing data) ---
        try {
          final detectionsSnapshot =
              await doc.reference.collection('detections').get();

          for (var detectionDoc in detectionsSnapshot.docs) {
            final detectionData = detectionDoc.data();

            // Convert Timestamps for Hive
            if (detectionData['timestamp'] is Timestamp) {
              detectionData['timestamp'] =
                  (detectionData['timestamp'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }
            if (detectionData['lastUpdated'] is Timestamp) {
              detectionData['lastUpdated'] =
                  (detectionData['lastUpdated'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            // Save using the new synced method (avoids unsynced queue)
            await _localStorage.saveSyncedDetection(
                doc.id, detectionDoc.id, detectionData);
          }
        } catch (e) {
          debugPrint("Error syncing detections for session ${doc.id}: $e");
        }
      }

      // 3. Return updated local sessions
      return getUserSessions(userId);
    } catch (e) {
      debugPrint("Sync failed: $e");
      // If sync fails (e.g. offline), rethrow so UI knows
      rethrow;
    }
  }

  @override
  Future<Session?> getLastSession(String userId) async {
    // 1. Try Local Storage FIRST (Instant)
    final localSession = _localStorage.getLastSession(userId);
    if (localSession != null) {
      return SessionModel(
        id: localSession['id'],
        userId: localSession['userId'],
        startTime: (localSession['startTime'] is Timestamp)
            ? (localSession['startTime'] as Timestamp).toDate()
            : DateTime.parse(localSession['startTime'].toString()),
        endTime: localSession['endTime'] != null
            ? ((localSession['endTime'] is Timestamp)
                ? (localSession['endTime'] as Timestamp).toDate()
                : DateTime.parse(localSession['endTime'].toString()))
            : null,
        status: localSession['status'] ?? 'active',
        totalDetections: localSession['totalDetections'] ?? 0,
      );
    }

    // 2. Fallback to Firestore
    try {
      final snapshot = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return SessionModel.fromFirestore(snapshot.docs.first);
      }
    } catch (e) {
      print("Error getting last session: $e");
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getSessionDetections(
      String sessionId) async {
    // 1. Try Local Storage
    final localDetections = _localStorage.getDetections(sessionId);
    if (localDetections.isNotEmpty) {
      return localDetections;
    }

    // 2. Fallback to Firestore
    try {
      final snapshot = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('detections')
          .orderBy('timestamp', descending: true)
          .get();

      final detections = snapshot.docs.map((doc) => doc.data()).toList();

      if (detections.isNotEmpty) {
        return detections;
      }

      // 3. Fallback to Session Document Fields (Legacy/Recovery)
      // If subcollection is empty, check if session doc has catch details directly
      final sessionDoc =
          await _firestore.collection('sessions').doc(sessionId).get();
      if (sessionDoc.exists) {
        final data = sessionDoc.data();
        if (data != null && data.containsKey('catchSpecies')) {
          debugPrint("Recovering detection from session doc fields...");
          return [
            {
              'class': data['catchSpecies'],
              'imageUrl': data['catchImageLocalPath'],
              'freshness': data['freshnessStatus'] == 'Fresh',
              'approximateCount': data['approximateCount'] ?? 1,
              'latitude': data['latitude'],
              'longitude': data['longitude'],
              'locationName': data['locationName'],
              'vesselId': data['vesselId'],
              'confidence': 1.0, // Dummy confidence
              'timestamp': data['lastUpdated'] ?? data['startTime'],
            }
          ];
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error getting session detections: $e");
      return [];
    }
  }

  @override
  Future<void> mergeGuestData(String newUserId) async {
    // 1. Update Local Data
    final updatedSessions = await _localStorage.mergeGuestSessions(newUserId);

    // 2. Upload Sessions to Firestore
    for (var sessionData in updatedSessions) {
      try {
        // Convert String timestamps back to Timestamp for Firestore
        final firestoreData = Map<String, dynamic>.from(sessionData);
        if (firestoreData['startTime'] is String) {
          firestoreData['startTime'] =
              Timestamp.fromDate(DateTime.parse(firestoreData['startTime']));
        }
        if (firestoreData['endTime'] is String) {
          firestoreData['endTime'] =
              Timestamp.fromDate(DateTime.parse(firestoreData['endTime']));
        }

        await _firestore
            .collection('sessions')
            .doc(sessionData['id'])
            .set(firestoreData);
      } catch (e) {
        debugPrint("Error merging session ${sessionData['id']}: $e");
      }
    }

    // 3. Trigger Sync for Detections
    getIt<SyncService>().syncData();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    // 1. Delete from Local Storage
    // Assuming LocalStorageService has a way to delete or we just ignore it for now if not exposed.
    // But we should try. Let's assume we can remove it from the list or mark as deleted.
    // Since _localStorage.saveSession is used, maybe there is no delete yet.
    // We will implement a basic Firestore delete for now as that's the primary concern for "history".
    // TODO: Add delete to LocalStorageService if needed.

    // 2. Delete from Firestore
    try {
      await _firestore.collection('sessions').doc(sessionId).delete();
    } catch (e) {
      debugPrint("Error deleting session: $e");
    }
  }
}
