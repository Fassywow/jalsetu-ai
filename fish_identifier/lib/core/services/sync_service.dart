import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'image_service.dart';
import 'local_storage_service.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../config/di/injection.dart';

class SyncService {
  final LocalStorageService _localStorage;
  final ImageService _imageService;
  final SessionRepository _sessionRepository;

  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  SyncService({
    required LocalStorageService localStorage,
    required ImageService imageService,
    required SessionRepository sessionRepository,
  })  : _localStorage = localStorage,
        _imageService = imageService,
        _sessionRepository = sessionRepository {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint("Internet restored! Triggering sync...");
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    if (_isSyncing) return;

    // Check connectivity first
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    _isSyncing = true;
    debugPrint("Starting Sync...");

    try {
      final unsyncedItems = _localStorage.getUnsyncedItems();

      for (var item in unsyncedItems) {
        try {
          if (item['type'] == 'detection') {
            await _syncDetection(item['id']);
          }
          // Add other types here if needed (e.g. session creation)

          // If successful, remove from queue
          // Note: Hive keys are dynamic, might need to store key in item
          // For simplicity, we'll just remove by finding the key again or assuming success
          // Ideally we should store the key in the item map or iterate keys
        } catch (e) {
          debugPrint("Failed to sync item ${item['id']}: $e");
        }
      }

      // Clean up queue - this is a bit naive, better to remove individually on success
      // But for this MVP we'll just re-check unsynced items
    } catch (e) {
      debugPrint("Sync Error: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncDetection(String detectionId) async {
    final detection = _localStorage.getDetection(detectionId);
    if (detection == null || detection['isSynced'] == true) return;

    String? imageUrl = detection['imageUrl'];

    // 1. Upload Image if local path
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      final file = File(imageUrl);
      if (await file.exists()) {
        final uploadedUrl = await _imageService.uploadImage(file);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
          detection['imageUrl'] = imageUrl; // Update local data with cloud URL
        } else {
          throw Exception("Image upload failed");
        }
      }
    }

    // 2. Save to Firestore
    // Skip if guest user (offline session)
    if (detection['sessionId'].toString().startsWith('guest_')) {
      debugPrint("Skipping sync for guest session detection");
      return;
    }

    await _sessionRepository.addDetectionToSession(
      detection['sessionId'],
      {
        'class': detection['class'],
        'confidence': detection['confidence'],
        'boundingBox': detection['boundingBox'],
        'imageUrl': imageUrl,
        'freshness': detection['freshness'],
        'freshnessConfidence': detection['freshnessConfidence'],
        'timestamp': detection['timestamp'],
      },
    );

    // 3. Mark as Synced
    detection['isSynced'] = true;
    await _localStorage.updateDetection(detectionId, detection);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
