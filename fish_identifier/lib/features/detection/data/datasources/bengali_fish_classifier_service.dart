import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/constants/model_config.dart';

/// Result from the Bengali fish classifier
class ClassificationResult {
  final String className;
  final double confidence;
  final String modelSource;

  ClassificationResult({
    required this.className,
    required this.confidence,
    required this.modelSource,
  });

  @override
  String toString() =>
      'ClassificationResult($className, ${(confidence * 100).toStringAsFixed(1)}%, $modelSource)';
}

/// Service for Bengali fish classification using TFLite
class BengaliFishClassifierService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initialize the classifier model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = InterpreterOptions()..threads = 4;

      _interpreter = await Interpreter.fromAsset(
        ModelConfig.bengaliModelPath,
        options: options,
      );

      _isInitialized = true;
      print('✅ Bengali Fish Classifier loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('❌ Failed to load Bengali Fish Classifier: $e');
    }
  }

  /// Classify a fish image
  /// Returns the class name and confidence score
  Future<ClassificationResult?> classify(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
      if (!_isInitialized) return null;
    }

    try {
      // 1. Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // 2. Resize to 224x224
      final resized = img.copyResize(
        image,
        width: ModelConfig.bengaliInputSize,
        height: ModelConfig.bengaliInputSize,
      );

      // 3. Preprocess: Convert to Float32List and normalize to 0-1
      final inputSize = ModelConfig.bengaliInputSize;
      final input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            },
          ),
        ),
      );

      // 4. Run inference
      final output = List.filled(1 * 20, 0.0).reshape([1, 20]);
      _interpreter!.run(input, output);

      // 5. Find the class with highest probability
      final probabilities = output[0] as List<double>;
      double maxScore = 0.0;
      int maxIndex = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxScore) {
          maxScore = probabilities[i];
          maxIndex = i;
        }
      }

      final className = maxIndex < ModelConfig.bengaliLabels.length
          ? ModelConfig.bengaliLabels[maxIndex]
          : 'Unknown';

      print(
          '🐟 Bengali Classifier: $className (${(maxScore * 100).toStringAsFixed(1)}%)');

      return ClassificationResult(
        className: className,
        confidence: maxScore,
        modelSource: 'Bengali Fish Classifier',
      );
    } catch (e) {
      print('❌ Bengali classification error: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    print('🗑️ Bengali Fish Classifier disposed');
  }
}
