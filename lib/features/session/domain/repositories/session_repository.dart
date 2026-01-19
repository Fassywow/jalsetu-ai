import '../../domain/entities/session.dart';

abstract class SessionRepository {
  Future<Session> createSession(String userId);
  Future<void> updateSession(Session session);
  Future<void> addDetectionToSession(
      String sessionId, Map<String, dynamic> detectionData);
  Future<Session?> getSession(String sessionId);
  Future<List<Session>> getUserSessions(String userId);
  Future<Session?> getLastSession(String userId);
  Future<List<Map<String, dynamic>>> getSessionDetections(String sessionId);
  Future<void> mergeGuestData(String newUserId);
  Future<List<Session>> syncSessions(String userId);
  Future<void> deleteSession(String sessionId);
}
