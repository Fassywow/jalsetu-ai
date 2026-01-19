import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Custom painter for drawing bounding boxes on detected objects
import '../../domain/entities/detection.dart';

/// Custom painter for drawing bounding boxes on detected objects
class DetectionPainter extends CustomPainter {
  final List<Detection> detections;
  final ui.Image? image;

  DetectionPainter({required this.detections, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    // Calculate scale to fit image in widget
    final imageAspect = image!.width / image!.height;
    final widgetAspect = size.width / size.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspect > widgetAspect) {
      // Image is wider - fit to width
      scale = size.width / image!.width;
      offsetY = (size.height - image!.height * scale) / 2;
    } else {
      // Image is taller - fit to height
      scale = size.height / image!.height;
      offsetX = (size.width - image!.width * scale) / 2;
    }

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final rect = detection.boundingBox;

      // Scale bounding box to widget size
      final scaledRect = Rect.fromLTWH(
        rect.left * scale + offsetX,
        rect.top * scale + offsetY,
        rect.width * scale,
        rect.height * scale,
      );

      // Get color for this detection (cycle through primary colors)
      final color = Colors.primaries[i % Colors.primaries.length];

      // Draw bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRect(scaledRect, boxPaint);

      // Draw filled rectangle for label background
      final className = detection.className;
      final confidence = detection.confidence;
      final labelText = '$className ${(confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        scaledRect.left,
        scaledRect.top - textPainter.height - 6,
        textPainter.width + 12,
        textPainter.height + 6,
      );

      final labelPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(labelRect, labelPaint);

      // Draw label text
      textPainter.paint(
        canvas,
        Offset(scaledRect.left + 6, scaledRect.top - textPainter.height - 3),
      );
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return detections != oldDelegate.detections || image != oldDelegate.image;
  }
}
