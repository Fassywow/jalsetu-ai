import 'dart:ui';
import '../../domain/entities/detection.dart';
import '../../../../core/constants/model_config.dart';

/// Data model for Detection with JSON serialization
class DetectionModel extends Detection {
  const DetectionModel({
    required super.className,
    required super.confidence,
    required super.boundingBox,
  });

  /// Create from raw detection data and image dimensions
  factory DetectionModel.fromRawData(
    Map<String, dynamic> data,
    double imageWidth,
    double imageHeight,
  ) {
    final classIndex = data['class'] as int;
    final className =
        classIndex < ModelConfig.labels.length
            ? ModelConfig.labels[classIndex]
            : 'unknown';

    // Convert from normalized coordinates to pixel coordinates
    final centerX = (data['x'] as double) * imageWidth;
    final centerY = (data['y'] as double) * imageHeight;
    final width = (data['w'] as double) * imageWidth;
    final height = (data['h'] as double) * imageHeight;

    // Convert from center format to corner format
    final left = centerX - width / 2;
    final top = centerY - height / 2;

    return DetectionModel(
      className: className,
      confidence: data['confidence'] as double,
      boundingBox: Rect.fromLTWH(left, top, width, height),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'confidence': confidence,
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
    };
  }

  /// Create from JSON
  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    final bbox = json['boundingBox'] as Map<String, dynamic>;
    return DetectionModel(
      className: json['className'] as String,
      confidence: json['confidence'] as double,
      boundingBox: Rect.fromLTRB(
        bbox['left'] as double,
        bbox['top'] as double,
        bbox['right'] as double,
        bbox['bottom'] as double,
      ),
    );
  }
}
