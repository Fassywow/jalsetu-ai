import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String sessionBoxName = 'sessions';
  static const String detectionBoxName = 'detections';
  static const String unsyncedBoxName = 'unsynced_data';

  // --- Chat Session Management ---
  static const String chatSessionBoxName = 'chat_sessions';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(sessionBoxName);
    await Hive.openBox(detectionBoxName);
    await Hive.openBox(unsyncedBoxName);
    await Hive.openBox(chatSessionBoxName);
  }

  // Save Chat Session
  Future<void> saveChatSession(Map<String, dynamic> sessionData) async {
    final box = Hive.box(chatSessionBoxName);
    await box.put(sessionData['id'], sessionData);
  }

  // Get Chat Sessions
  List<Map<String, dynamic>> getChatSessions() {
    final box = Hive.box(chatSessionBoxName);
    final sessions =
        box.values.map((e) => Map<String, dynamic>.from(e)).toList();

    // Sort by timestamp descending
    sessions.sort((a, b) {
      DateTime timeA = DateTime.parse(a['timestamp']);
      DateTime timeB = DateTime.parse(b['timestamp']);
      return timeB.compareTo(timeA);
    });

    return sessions;
  }

  // Delete Chat Session
  Future<void> deleteChatSession(String sessionId) async {
    final box = Hive.box(chatSessionBoxName);
    await box.delete(sessionId);
  }

  // Get Specific Chat Session
  Map<String, dynamic>? getChatSession(String sessionId) {
    final box = Hive.box(chatSessionBoxName);
    final data = box.get(sessionId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // Save Session Locally
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    final box = Hive.box(sessionBoxName);
    await box.put(sessionData['id'], sessionData);
  }

  // Get Local Sessions (Sorted by time if possible, but Hive is key-value)
  List<Map<String, dynamic>> getSessions(String userId) {
    final box = Hive.box(sessionBoxName);

    final sessions = box.values
        .where((s) => s['userId'] == userId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // Sort by startTime descending
    sessions.sort((a, b) {
      DateTime timeA = DateTime.parse(a['startTime']);
      DateTime timeB = DateTime.parse(b['startTime']);
      return timeB.compareTo(timeA);
    });

    return sessions;
  }

  // Get Last Session
  Map<String, dynamic>? getLastSession(String userId) {
    final sessions = getSessions(userId);
    if (sessions.isNotEmpty) {
      return sessions.first;
    }
    return null;
  }

  // Save Detection Locally
  Future<void> saveDetection(
      String sessionId, Map<String, dynamic> detectionData) async {
    final box = Hive.box(detectionBoxName);
    // Use a composite key or just a unique ID for detection
    final detectionId = DateTime.now().millisecondsSinceEpoch.toString();
    detectionData['id'] = detectionId;
    detectionData['sessionId'] = sessionId;
    detectionData['isSynced'] = false; // Mark as unsynced

    await box.put(detectionId, detectionData);

    // Also update the session's total detection count locally
    final sessionBox = Hive.box(sessionBoxName);
    final session = sessionBox.get(sessionId);
    if (session != null) {
      final updatedSession = Map<String, dynamic>.from(session);
      updatedSession['totalDetections'] =
          (updatedSession['totalDetections'] ?? 0) + 1;
      await sessionBox.put(sessionId, updatedSession);
    }

    // Add to unsynced queue
    await addToUnsyncedQueue('detection', detectionId);
  }

  // Save Synced Detection (from Firestore)
  Future<void> saveSyncedDetection(String sessionId, String detectionId,
      Map<String, dynamic> detectionData) async {
    final box = Hive.box(detectionBoxName);
    detectionData['id'] = detectionId;
    detectionData['sessionId'] = sessionId;
    detectionData['isSynced'] = true; // Mark as synced

    await box.put(detectionId, detectionData);
  }

  Future<void> addToUnsyncedQueue(String type, String id) async {
    final box = Hive.box(unsyncedBoxName);
    await box.add({
      'type': type,
      'id': id,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  List<Map<String, dynamic>> getUnsyncedItems() {
    final box = Hive.box(unsyncedBoxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> removeFromUnsyncedQueue(int key) async {
    final box = Hive.box(unsyncedBoxName);
    await box.delete(key);
  }

  // Helper to get detection by ID
  Map<String, dynamic>? getDetection(String id) {
    final box = Hive.box(detectionBoxName);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> updateDetection(String id, Map<String, dynamic> data) async {
    final box = Hive.box(detectionBoxName);
    await box.put(id, data);
  }

  // Get Detections for a Session
  List<Map<String, dynamic>> getDetections(String sessionId) {
    final box = Hive.box(detectionBoxName);
    return box.values
        .where((d) => d['sessionId'] == sessionId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Merge Guest Sessions
  Future<List<Map<String, dynamic>>> mergeGuestSessions(
      String newUserId) async {
    final box = Hive.box(sessionBoxName);
    final guestSessions = box.values
        .where((s) => s['userId'] == 'guest_user')
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    List<Map<String, dynamic>> updatedSessions = [];

    for (var session in guestSessions) {
      session['userId'] = newUserId;
      await box.put(session['id'], session);
      updatedSessions.add(session);
    }

    return updatedSessions;
  }
}
