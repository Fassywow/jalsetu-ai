import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/model_config.dart';

/// Card widget to display individual detection
import '../../domain/entities/detection.dart';

/// Card widget to display individual detection
class DetectionCard extends StatelessWidget {
  final Detection detection;
  final VoidCallback? onTap;

  const DetectionCard({super.key, required this.detection, this.onTap});

  @override
  Widget build(BuildContext context) {
    final className = detection.className;
    final confidenceValue = detection.confidence;
    final color = ModelConfig.classColors[className] ?? Colors.blue;
    final confidence = (confidenceValue * 100).toStringAsFixed(1);
    final isLowConfidence = confidenceValue < 0.5;
    final displayColor = isLowConfidence ? Colors.orange : color;
    final displayName =
        isLowConfidence ? "Unidentified Fish" : className.toUpperCase();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: displayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLowConfidence ? '❓' : '🐟',
                  style: const TextStyle(fontSize: 32),
                ),
              ),

              const SizedBox(width: 16),

              // Detection details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: displayColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Confidence progress bar
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: confidenceValue,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$confidence%',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
