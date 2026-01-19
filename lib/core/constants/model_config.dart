import 'dart:ui';

class ModelConfig {
  // ============ YOLO Detection Model ============
  static const String modelPath = 'assets/models/fish_yolov8n.tflite';
  static const int inputSize = 640;
  static const double confidenceThreshold = 0.25;
  static const double iouThreshold = 0.45;
  static const int numChannels = 3;

  // YOLO Class labels - From Fish-Detection-1 dataset (9 species)
  static const List<String> labels = [
    'Gilt-Head Bream',
    'Red sea bream',
    'Striped Red Mullet',
    'black sea sprat',
    'house mackerel',
    'red mullet',
    'sea bass',
    'shrimp',
    'trout',
  ];

  // ============ Bengali Fish Classifier Model ============
  static const String bengaliModelPath =
      'assets/models/bengali_fish_classifier.tflite';
  static const int bengaliInputSize = 224;

  // Bengali Class labels (20 species)
  static const List<String> bengaliLabels = [
    'Ayre',
    'Catla',
    'Chital',
    'Ilish',
    'Kachki',
    'Kajoli',
    'Koi',
    'Magur',
    'Mola Dhela',
    'Mrigal',
    'Pabda',
    'Pangash',
    'Poa',
    'Puti',
    'Rui',
    'Shing',
    'Silver Carp',
    'Taki',
    'Telapia',
    'Tengra',
  ];

  // ============ Combined Species List (29 total) ============
  static List<String> get allSpecies => [...labels, ...bengaliLabels];

  // Colors for each class
  static const Map<String, Color> classColors = {
    'Gilt-Head Bream': Color(0xFF4CAF50), // Green
    'Red sea bream': Color(0xFFF44336), // Red
    'Striped Red Mullet': Color(0xFFFF9800), // Orange
    'black sea sprat': Color(0xFF2196F3), // Blue
    'house mackerel': Color(0xFF9C27B0), // Purple
    'red mullet': Color(0xFFFFEB3B), // Yellow
    'sea bass': Color(0xFF00BCD4), // Cyan
    'shrimp': Color(0xFFE91E63), // Pink
    'trout': Color(0xFF795548), // Brown
    // Bengali fish colors
    'Ayre': Color(0xFF3F51B5),
    'Catla': Color(0xFF009688),
    'Chital': Color(0xFF673AB7),
    'Ilish': Color(0xFFFF5722),
    'Kachki': Color(0xFF607D8B),
    'Kajoli': Color(0xFF8BC34A),
    'Koi': Color(0xFFCDDC39),
    'Magur': Color(0xFF9E9E9E),
    'Mola Dhela': Color(0xFF00BCD4),
    'Mrigal': Color(0xFFFFC107),
    'Pabda': Color(0xFF795548),
    'Pangash': Color(0xFF03A9F4),
    'Poa': Color(0xFFE91E63),
    'Puti': Color(0xFF4CAF50),
    'Rui': Color(0xFFF44336),
    'Shing': Color(0xFF9C27B0),
    'Silver Carp': Color(0xFFB0BEC5),
    'Taki': Color(0xFF2196F3),
    'Telapia': Color(0xFFFF9800),
    'Tengra': Color(0xFF795548),
  };

  // Emoji icons for each class
  static const Map<String, String> classIcons = {
    'Gilt-Head Bream': '🐟',
    'Red sea bream': '🐠',
    'Striped Red Mullet': '🐟',
    'black sea sprat': '🐟',
    'house mackerel': '🐟',
    'red mullet': '🐟',
    'sea bass': '🐟',
    'shrimp': '🦐',
    'trout': '🐟',
    // Bengali fish
    'Ayre': '🐟',
    'Catla': '🐟',
    'Chital': '🐟',
    'Ilish': '🐟',
    'Kachki': '🐟',
    'Kajoli': '🐟',
    'Koi': '🐠',
    'Magur': '🐟',
    'Mola Dhela': '🐟',
    'Mrigal': '🐟',
    'Pabda': '🐟',
    'Pangash': '🐟',
    'Poa': '🐟',
    'Puti': '🐟',
    'Rui': '🐟',
    'Shing': '🐟',
    'Silver Carp': '🐟',
    'Taki': '🐟',
    'Telapia': '🐟',
    'Tengra': '🐟',
  };

  // Model output configuration
  static const int maxDetections = 300;
  static const int stride = 32;
}
