import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'active', 'completed'
  final int totalDetections;

  const Session({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.status = 'active',
    this.totalDetections = 0,
  });

  @override
  List<Object?> get props =>
      [id, userId, startTime, endTime, status, totalDetections];
}
