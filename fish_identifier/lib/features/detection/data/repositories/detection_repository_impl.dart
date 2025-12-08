import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/tflite_detection_service.dart';
import '../datasources/bengali_fish_classifier_service.dart';
import '../models/detection_model.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/constants/model_config.dart';
import '../../../../core/errors/failures.dart';

/// Implementation of detection repository with dual-model support
class DetectionRepositoryImpl implements DetectionRepository {
  final TFLiteDetectionService _detectionService;
  final BengaliFishClassifierService _bengaliClassifier;
  final ImagePicker _imagePicker;

  DetectionRepositoryImpl({
    required TFLiteDetectionService detectionService,
    BengaliFishClassifierService? bengaliClassifier,
    ImagePicker? imagePicker,
  })  : _detectionService = detectionService,
        _bengaliClassifier =
            bengaliClassifier ?? BengaliFishClassifierService(),
        _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<void> initialize() async {
    try {
      await _detectionService.initialize();
      await _bengaliClassifier.initialize();
    } catch (e) {
      throw ModelLoadFailure('Failed to initialize model: $e');
    }
  }

  @override
  Future<List<Detection>> detectFromFile(File imageFile) async {
    try {
      // Get original image dimensions
      final decodedImage = await ImageUtils.decodeImage(imageFile);
      if (decodedImage == null) {
        throw const ImageProcessingFailure('Could not decode image');
      }

      final imageWidth = decodedImage.width.toDouble();
      final imageHeight = decodedImage.height.toDouble();

      // Run BOTH models in parallel for speed
      final List<Detection> yoloDetections =
          await _runYoloDetection(imageFile, imageWidth, imageHeight);
      final Detection? bengaliDetection =
          await _runBengaliClassification(imageFile, imageWidth, imageHeight);

      // Compare confidences and choose the best result
      double yoloMaxConf = yoloDetections.isNotEmpty
          ? yoloDetections
              .map((d) => d.confidence)
              .reduce((a, b) => a > b ? a : b)
          : 0.0;
      double bengaliConf = bengaliDetection?.confidence ?? 0.0;

      log('📊 YOLO max confidence: ${(yoloMaxConf * 100).toStringAsFixed(1)}%');
      log('📊 Bengali confidence: ${(bengaliConf * 100).toStringAsFixed(1)}%');

      // Return the result with higher confidence
      if (bengaliConf > yoloMaxConf && bengaliDetection != null) {
        log('✅ Using Bengali Fish Classifier result: ${bengaliDetection.className}');
        return [bengaliDetection];
      } else if (yoloDetections.isNotEmpty) {
        log('✅ Using YOLO detection result: ${yoloDetections.first.className}');
        return yoloDetections;
      }

      return [];
    } catch (e) {
      if (e is Failure) rethrow;
      log(e.toString());
      throw InferenceFailure('Detection failed: $e');
    }
  }

  /// Run YOLO object detection model
  Future<List<Detection>> _runYoloDetection(
    File imageFile,
    double imageWidth,
    double imageHeight,
  ) async {
    try {
      // Preprocess image for YOLO
      final preprocessedData = await ImageUtils.preprocessImage(
        imageFile,
        ModelConfig.inputSize,
      );

      // Run inference
      final rawDetections = await _detectionService.runInference(
        preprocessedData,
      );

      // Convert to domain entities with proper scaling
      return rawDetections.map((data) {
        return DetectionModel.fromRawData(data, imageWidth, imageHeight);
      }).toList();
    } catch (e) {
      log('YOLO detection error: $e');
      return [];
    }
  }

  /// Run Bengali fish classification model
  Future<Detection?> _runBengaliClassification(
    File imageFile,
    double imageWidth,
    double imageHeight,
  ) async {
    try {
      final result = await _bengaliClassifier.classify(imageFile);
      if (result == null || result.confidence < 0.25) {
        return null;
      }

      // Create a detection entity for the Bengali classifier result
      // Since this is a classification (not detection), we use the full image as bounding box
      return Detection(
        className: result.className,
        confidence: result.confidence,
        boundingBox: Rect.fromLTWH(0, 0, imageWidth, imageHeight),
      );
    } catch (e) {
      log('Bengali classification error: $e');
      return null;
    }
  }

  @override
  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw ImagePickFailure('Failed to pick image: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _detectionService.dispose();
    _bengaliClassifier.dispose();
  }
}
