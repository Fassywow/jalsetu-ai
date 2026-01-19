import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/detection/presentation/bloc/detection_bloc.dart';
import '../../../../features/detection/presentation/bloc/detection_event.dart';
import '../../../../features/detection/presentation/pages/detection_page.dart';

class LiveGuidancePage extends StatefulWidget {
  const LiveGuidancePage({super.key});

  @override
  State<LiveGuidancePage> createState() => _LiveGuidancePageState();
}

class _LiveGuidancePageState extends State<LiveGuidancePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final FlutterTts _flutterTts = FlutterTts();

  // Isolate Communication
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _mainReceivePort;
  bool _isIsolateBusy = false;

  // Model Parameters
  static const String _modelAssetPath = 'assets/models/fish_yolov8n.tflite';

  // Guidance State
  String _guidanceText = "Initializing...";
  DateTime _lastSpeakTime = DateTime.now();
  bool _isGoodPosition = false;
  int _consecutiveGoodFrames = 0;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeTts();
    _spawnIsolate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _isolate?.kill();
    _mainReceivePort?.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _controller!.startImageStream(_processCameraImage);
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _spawnIsolate() async {
    _mainReceivePort = ReceivePort();

    // Copy model to file system for Isolate access
    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/fish_yolov8n.tflite';

    if (!File(modelPath).existsSync()) {
      final data = await rootBundle.load(_modelAssetPath);
      final bytes = data.buffer.asUint8List();
      await File(modelPath).writeAsBytes(bytes, flush: true);
    }

    _isolate = await Isolate.spawn(
      _inferenceIsolateEntry,
      _mainReceivePort!.sendPort,
    );

    _mainReceivePort!.listen((message) {
      if (message is SendPort) {
        _isolateSendPort = message;
        // Send config
        _isolateSendPort!.send({'type': 'init', 'modelPath': modelPath});
      } else if (message is Map) {
        // Result
        _isIsolateBusy = false;
        if (message['type'] == 'result') {
          final rectData = message['rect'];
          final confidence = message['confidence'] as double? ?? 0.0;
          Rect? detectedFish;
          if (rectData != null) {
            detectedFish = Rect.fromLTWH(
                rectData[0], rectData[1], rectData[2], rectData[3]);
          }
          if (mounted) {
            _updateGuidance(detectedFish, confidence, message['imgWidth'],
                message['imgHeight']);
          }
        }
      }
    });
  }

  void _processCameraImage(CameraImage image) {
    if (_isIsolateBusy || _isolateSendPort == null || _isCapturing) return;

    _isIsolateBusy = true;

    // Prepare data to send to isolate
    // We need to copy bytes because CameraImage buffers might be reused
    // Sending raw bytes is safer across isolates than sending CameraImage

    final planes = image.planes.map((plane) {
      return {
        'bytes': plane.bytes,
        'bytesPerRow': plane.bytesPerRow,
        'bytesPerPixel': plane.bytesPerPixel,
      };
    }).toList();

    _isolateSendPort!.send({
      'type': 'image',
      'width': image.width,
      'height': image.height,
      'planes': planes,
      'format': Platform.isAndroid ? 'yuv420' : 'bgra8888',
    });
  }

  void _updateGuidance(
      Rect? fishBox, double confidence, int imgWidth, int imgHeight) {
    String newGuidance = "";
    bool isGood = false;

    // HIGH CONFIDENCE AUTO-CAPTURE: If confidence > 75%, capture immediately!
    if (confidence >= 0.6 && !_isCapturing) {
      newGuidance = "Fish detected! Capturing...";
      setState(() {
        _guidanceText = newGuidance;
        _isGoodPosition = true;
      });
      _speak("Capturing now.");
      _captureAndProceed();
      return;
    }

    if (fishBox == null) {
      newGuidance = "I cannot see the fish. Please place it in the frame.";
    } else {
      // Show confidence in guidance
      final confPercent = (confidence * 100).toStringAsFixed(0);

      // Calculate centers
      double fishCx = fishBox.center.dx;
      double fishCy = fishBox.center.dy;
      double imgCx = imgWidth / 2;
      double imgCy = imgHeight / 2;

      // Check size (Too far?)
      double boxArea = fishBox.width * fishBox.height;
      double imgArea = imgWidth * imgHeight * 1.0;
      double coverage = boxArea / imgArea;

      if (coverage < 0.15) {
        newGuidance = "Bring fish closer ($confPercent% sure)";
      } else if (coverage > 0.8) {
        newGuidance = "Move back a little ($confPercent% sure)";
      } else {
        // Check centering
        double offsetX = (fishCx - imgCx).abs();
        double offsetY = (fishCy - imgCy).abs();

        if (offsetX > imgWidth * 0.15 || offsetY > imgHeight * 0.15) {
          newGuidance = "Center the fish ($confPercent% sure)";
        } else {
          newGuidance = "Perfect! $confPercent% confident. Hold still...";
          isGood = true;
        }
      }
    }

    if (newGuidance != _guidanceText) {
      setState(() {
        _guidanceText = newGuidance;
        _isGoodPosition = isGood;
      });
      _speak(newGuidance);
    }

    // Also trigger capture after several good frames even if confidence is lower
    if (isGood && confidence >= 0.5) {
      _consecutiveGoodFrames++;
      if (_consecutiveGoodFrames > 10 && !_isCapturing) {
        _captureAndProceed();
      }
    } else {
      _consecutiveGoodFrames = 0;
    }
  }

  Future<void> _captureAndProceed() async {
    if (_isCapturing) return;
    _isCapturing = true;
    _speak("Capturing now.");

    try {
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();

      if (!mounted) return;

      // Dispatch event to Bloc
      context.read<DetectionBloc>().add(DetectObjectsEvent(File(file.path)));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DetectionPage(),
        ),
      );
    } catch (e) {
      print("Capture error: $e");
      _isCapturing = false;
      _controller!.startImageStream(_processCameraImage);
    }
  }

  Future<void> _speak(String text) async {
    if (DateTime.now().difference(_lastSpeakTime).inSeconds < 3) {
      return; // Debounce speech
    }
    _lastSpeakTime = DateTime.now();
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.videocam,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Live Guidance",
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                ),

                const Spacer(),

                // Guidance Box
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isGoodPosition
                        ? Colors.green.withOpacity(0.9)
                        : Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          _isGoodPosition ? Colors.greenAccent : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isGoodPosition
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _guidanceText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- ISOLATE ENTRY POINT ---
void _inferenceIsolateEntry(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  Interpreter? interpreter;
  List<int> outputShape = [];
  const int inputSize = 640;

  await for (final message in receivePort) {
    if (message is Map) {
      final type = message['type'];

      if (type == 'init') {
        final modelPath = message['modelPath'];
        try {
          final options = InterpreterOptions();
          interpreter = Interpreter.fromFile(File(modelPath), options: options);
          outputShape = interpreter.getOutputTensor(0).shape;
          print("Isolate: Model loaded. Output shape: $outputShape");
        } catch (e) {
          print("Isolate: Model load error: $e");
        }
      } else if (type == 'image') {
        if (interpreter == null) {
          sendPort.send({'type': 'error', 'message': 'Model not loaded'});
          continue;
        }

        try {
          final width = message['width'] as int;
          final height = message['height'] as int;
          final format = message['format'];
          final planes = (message['planes'] as List).cast<Map>();

          img.Image? convertedImage;

          if (format == 'yuv420') {
            convertedImage = _convertYUV420ToImage(width, height, planes);
          } else {
            convertedImage = _convertBGRA8888ToImage(width, height, planes);
          }

          // Resize
          final resized = img.copyResize(convertedImage,
              width: inputSize, height: inputSize);

          // Normalize - using same normalization as the working service (0-1 range)
          final inputTensor = Float32List(1 * inputSize * inputSize * 3);
          int pixelIndex = 0;
          for (var y = 0; y < inputSize; y++) {
            for (var x = 0; x < inputSize; x++) {
              final pixel = resized.getPixel(x, y);
              inputTensor[pixelIndex++] = pixel.r / 255.0;
              inputTensor[pixelIndex++] = pixel.g / 255.0;
              inputTensor[pixelIndex++] = pixel.b / 255.0;
            }
          }

          final input = inputTensor.reshape([1, inputSize, inputSize, 3]);

          // Create proper nested list output buffer (like working TFLiteDetectionService)
          // outputShape is typically [1, 13, 8400] for 9 classes (4 box + 9 classes)
          // or [1, 8400, 13] if transposed
          final output = List.generate(
            outputShape[0],
            (_) => List.generate(
              outputShape[1],
              (_) => List<double>.filled(outputShape[2], 0.0),
            ),
          );

          interpreter.run(input, output);

          // Parse with proper shape information - returns (Rect?, confidence)
          final result = _postProcessOutputV2(
              output, outputShape, inputSize, width, height);

          sendPort.send({
            'type': 'result',
            'rect': result.$1 == null
                ? null
                : [
                    result.$1!.left,
                    result.$1!.top,
                    result.$1!.width,
                    result.$1!.height
                  ],
            'confidence': result.$2,
            'imgWidth': width,
            'imgHeight': height
          });
        } catch (e, stackTrace) {
          print("Isolate inference error: $e");
          print("Stack trace: $stackTrace");
          sendPort.send({'type': 'result', 'rect': null, 'confidence': 0.0});
        }
      }
    }
  }
}

// Helper functions for Isolate (must be static or top-level)
img.Image _convertBGRA8888ToImage(int width, int height, List<Map> planes) {
  final bytes = planes[0]['bytes'] as Uint8List;
  return img.Image.fromBytes(
    width: width,
    height: height,
    bytes: bytes.buffer,
    order: img.ChannelOrder.bgra,
  );
}

img.Image _convertYUV420ToImage(int width, int height, List<Map> planes) {
  final uvRowStride = planes[1]['bytesPerRow'] as int;
  final uvPixelStride = (planes[1]['bytesPerPixel'] as int?) ?? 1;
  final yBytes = planes[0]['bytes'] as Uint8List;
  final uBytes = planes[1]['bytes'] as Uint8List;
  final vBytes = planes[2]['bytes'] as Uint8List;
  final yRowStride = planes[0]['bytesPerRow'] as int;

  final img.Image rgbImage = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    final int uvRowIndex = uvRowStride * (y >> 1);
    final int yp = yRowStride * y;

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvPixelStride * (x >> 1) + uvRowIndex;

      final int indexY = yBytes[yp + x];
      final int indexU = uBytes[uvIndex];
      final int indexV = vBytes[uvIndex];

      rgbImage.setPixelRgb(
          x,
          y,
          _yuv2rgb(indexY, indexU, indexV, 0),
          _yuv2rgb(indexY, indexU, indexV, 1),
          _yuv2rgb(indexY, indexU, indexV, 2));
    }
  }
  return rgbImage;
}

int _yuv2rgb(int y, int u, int v, int channel) {
  int r = (y + (1.370705 * (v - 128))).toInt();
  int g = (y - (0.337633 * (u - 128)) - (0.698001 * (v - 128))).toInt();
  int b = (y + (1.732446 * (u - 128))).toInt();

  r = r.clamp(0, 255);
  g = g.clamp(0, 255);
  b = b.clamp(0, 255);

  switch (channel) {
    case 0:
      return r;
    case 1:
      return g;
    case 2:
      return b;
  }
  return 0;
}

/// Post-process YOLOv8 output using shape information (matches TFLiteDetectionService)
/// Returns (Rect?, confidence)
(Rect?, double) _postProcessOutputV2(
    List output, List<int> shape, int inputSize, int imgWidth, int imgHeight) {
  final predictions = output[0] as List;

  // Determine format based on shape
  // YOLOv8 can output in two formats:
  // [1, 13, 8400] means 13 channels (4 box + 9 classes), 8400 predictions per channel
  // [1, 8400, 13] means 8400 predictions, each with 13 values
  final bool isTransposed = shape[1] > shape[2]; // [1, 8400, 13]
  final int numPredictions = isTransposed ? shape[1] : shape[2];
  final int numChannels = isTransposed ? shape[2] : shape[1];

  print(
      "Isolate: Processing $numPredictions predictions with $numChannels channels. Transposed: $isTransposed");

  double maxConf = 0.0;
  Rect? bestBox;

  for (int i = 0; i < numPredictions; i++) {
    double x, y, w, h;
    double maxScore = 0.0;

    if (isTransposed) {
      // Format: [1, 8400, 13] - each prediction is a row
      final pred = predictions[i] as List;
      x = (pred[0] as num).toDouble();
      y = (pred[1] as num).toDouble();
      w = (pred[2] as num).toDouble();
      h = (pred[3] as num).toDouble();

      // Class scores start from index 4
      for (int j = 4; j < numChannels; j++) {
        final score = (pred[j] as num).toDouble();
        if (score > maxScore) maxScore = score;
      }
    } else {
      // Format: [1, 13, 8400] - each channel is a column
      x = (predictions[0][i] as num).toDouble();
      y = (predictions[1][i] as num).toDouble();
      w = (predictions[2][i] as num).toDouble();
      h = (predictions[3][i] as num).toDouble();

      // Class scores from channels 4 onwards
      for (int j = 4; j < numChannels; j++) {
        final score = (predictions[j][i] as num).toDouble();
        if (score > maxScore) maxScore = score;
      }
    }

    // Filter by confidence threshold (0.25 matches ModelConfig)
    if (maxScore > 0.25 && maxScore > maxConf) {
      maxConf = maxScore;

      // Convert from center/width/height to top-left/width/height
      // and normalize to original image dimensions
      double left = (x - w / 2) / inputSize * imgWidth;
      double top = (y - h / 2) / inputSize * imgHeight;
      double width = w / inputSize * imgWidth;
      double height = h / inputSize * imgHeight;

      bestBox = Rect.fromLTWH(left, top, width, height);
    }
  }

  if (bestBox != null) {
    print(
        "Isolate: Found fish with confidence ${(maxConf * 100).toStringAsFixed(1)}%");
  }

  return (bestBox, maxConf);
}
