import 'dart:io';
import 'package:equatable/equatable.dart';

/// Events for detection BLoC
abstract class DetectionEvent extends Equatable {
  const DetectionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeModel extends DetectionEvent {
  const InitializeModel();
}

class PickImageFromCamera extends DetectionEvent {
  final bool isFreshnessOnly;
  const PickImageFromCamera({this.isFreshnessOnly = false});

  @override
  List<Object?> get props => [isFreshnessOnly];
}

class PickImageFromGallery extends DetectionEvent {
  final bool isFreshnessOnly;
  const PickImageFromGallery({this.isFreshnessOnly = false});

  @override
  List<Object?> get props => [isFreshnessOnly];
}

class DetectObjectsEvent extends DetectionEvent {
  final File imageFile;

  const DetectObjectsEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class ResetDetection extends DetectionEvent {
  const ResetDetection();
}

class CheckFreshness extends DetectionEvent {
  final File imageFile;

  const CheckFreshness(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class AnalyzeFreshnessOnly extends DetectionEvent {
  final File imageFile;

  const AnalyzeFreshnessOnly(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}
