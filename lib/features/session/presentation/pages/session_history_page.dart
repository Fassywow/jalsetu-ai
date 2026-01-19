import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../features/session/domain/entities/session.dart';
import '../../../../features/session/domain/repositories/session_repository.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/localization/localization_manager.dart';
import 'session_details_page.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  final LocalizationManager _loc = LocalizationManager();
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      log("=== Loading sessions ===");
      final authRepo = getIt<AuthRepository>();
      final userId = await authRepo.getLoggedInUser() ?? 'guest_user';
      log("User ID: $userId");

      final repo = getIt<SessionRepository>();

      // 1. Load Local Immediately (Fast)
      log("Fetching local sessions for user: $userId");
      final localSessions = await repo.getUserSessions(userId);
      log("Local sessions found: ${localSessions.length}");

      // Show UI immediately with local data
      if (mounted) {
        setState(() {
          _sessions = localSessions;
          _isLoading = false;
        });
      }

      // 2. Trigger Sync in Background (non-blocking)
      log("Triggering background sync...");
      repo.syncSessions(userId).then((syncedSessions) {
        log("Sync complete. Sessions: ${syncedSessions.length}");
        if (mounted) {
          setState(() {
            _sessions = syncedSessions;
          });
        }
      }).catchError((e) {
        log("Sync failed (likely offline): $e");
      });
    } catch (e, stack) {
      log("Error loading sessions: $e", error: e, stackTrace: stack);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _loc.translate('session_fishing_history'),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              log("Manual refresh triggered");
              setState(() => _isLoading = true);
              _loadSessions();
            },
            tooltip: _loc.translate('session_refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        _loc.translate('session_no_history_found'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SessionDetailsPage(session: session),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.phishing,
                                  color: Colors.blue.shade700, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMMM d, y',
                                            _loc.currentLanguageCode)
                                        .format(session.startTime),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                            'h:mm a', _loc.currentLanguageCode)
                                        .format(session.startTime),
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${session.totalDetections}",
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  _loc.translate('session_catches_label'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
