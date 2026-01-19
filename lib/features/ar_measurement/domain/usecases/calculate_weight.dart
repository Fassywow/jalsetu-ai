import 'dart:math';

/// Calculates estimated fish weight from length using the allometric formula:
/// W = a × L^b
/// Where W = weight (grams), L = length (cm)
/// Coefficients are species-specific based on fisheries research data.
class CalculateWeight {
  // Coefficients for W = a * L^b
  // Length in cm, Weight in grams
  // Sources: FishBase.org, ICAR research papers, FAO fisheries data
  static const Map<String, Map<String, double>> _speciesCoefficients = {
    // ===== Mediterranean/European Species (from YOLOv8 model) =====
    'gilt-head bream': {'a': 0.0138, 'b': 3.02}, // Sparus aurata
    'gilthead bream': {'a': 0.0138, 'b': 3.02},
    'red sea bream': {'a': 0.0141, 'b': 2.99}, // Pagrus major
    'striped red mullet': {'a': 0.0089, 'b': 3.12}, // Mullus surmuletus
    'red mullet': {'a': 0.0091, 'b': 3.10}, // Mullus barbatus
    'black sea sprat': {'a': 0.0056, 'b': 3.18}, // Clupeonella cultriventris
    'horse mackerel': {'a': 0.0068, 'b': 3.15}, // Trachurus trachurus
    'sea bass': {'a': 0.0095, 'b': 3.05}, // Dicentrarchus labrax
    'trout': {'a': 0.0112, 'b': 3.02}, // Oncorhynchus mykiss
    'shrimp': {
      'a': 0.0085,
      'b': 2.85
    }, // Caridea (smaller exponent for crustaceans)

    // ===== Indian/Bengali Freshwater Species (from Bengali classifier) =====
    'ayre': {'a': 0.0078, 'b': 3.08}, // Sperata aor (Long-whiskered catfish)
    'catla': {'a': 0.0125, 'b': 2.95}, // Gibelion catla
    'chital': {'a': 0.0065, 'b': 3.12}, // Chitala chitala (Clown knifefish)
    'ilish': {'a': 0.0098, 'b': 3.05}, // Tenualosa ilisha (Hilsa)
    'hilsa': {'a': 0.0098, 'b': 3.05}, // Alias for Ilish
    'kachki': {'a': 0.0042, 'b': 3.22}, // Corica soborna (Ganges River sprat)
    'kajoli': {'a': 0.0058, 'b': 3.15}, // Ailia coila
    'koi': {'a': 0.0145, 'b': 2.92}, // Anabas testudineus (Climbing perch)
    'magur': {'a': 0.0082, 'b': 3.08}, // Clarias batrachus (Walking catfish)
    'mola dhela': {
      'a': 0.0038,
      'b': 3.25
    }, // Amblypharyngodon mola (Mola carplet)
    'mola': {'a': 0.0038, 'b': 3.25}, // Alias
    'dhela': {'a': 0.0038, 'b': 3.25}, // Alias
    'mrigal': {'a': 0.0118, 'b': 2.98}, // Cirrhinus cirrhosus
    'pabda': {'a': 0.0072, 'b': 3.10}, // Ompok pabda
    'pangash': {'a': 0.0088, 'b': 3.05}, // Pangasius pangasius
    'pangasius': {'a': 0.0088, 'b': 3.05}, // Alias
    'poa': {'a': 0.0095, 'b': 3.02}, // Otolithoides pama (Pama croaker)
    'puti': {'a': 0.0105, 'b': 3.00}, // Puntius sophore (Pool barb)
    'rui': {'a': 0.0115, 'b': 2.97}, // Labeo rohita (Rohu)
    'rohu': {'a': 0.0115, 'b': 2.97}, // Alias
    'shing': {
      'a': 0.0068,
      'b': 3.12
    }, // Heteropneustes fossilis (Stinging catfish)
    'silver carp': {'a': 0.0132, 'b': 2.94}, // Hypophthalmichthys molitrix
    'silvercarp': {'a': 0.0132, 'b': 2.94}, // Alias
    'taki': {'a': 0.0078, 'b': 3.05}, // Channa punctata (Spotted snakehead)
    'tilapia': {'a': 0.0168, 'b': 2.88}, // Oreochromis niloticus
    'telapia': {'a': 0.0168, 'b': 2.88}, // Alias (common misspelling)
    'tengra': {'a': 0.0055, 'b': 3.18}, // Mystus tengara

    // ===== Common commercial species =====
    'salmon': {'a': 0.0134, 'b': 2.96},
    'tuna': {'a': 0.0185, 'b': 2.92},
    'cod': {'a': 0.0071, 'b': 3.08},
    'bass': {'a': 0.0125, 'b': 3.05},
    'pomfret': {'a': 0.0155, 'b': 2.90}, // Pampus argenteus
    'mackerel': {'a': 0.0068, 'b': 3.15}, // Rastrelliger kanagurta
    'kingfish': {'a': 0.0072, 'b': 3.12}, // Scomberomorus commerson

    // Generic default for unknown species
    'default': {'a': 0.0120, 'b': 3.00},
  };

  /// Calculate weight in grams from length in cm
  /// Uses species-specific coefficients if available, otherwise uses default
  double call({required double lengthCm, String? species}) {
    // Normalize species name for lookup
    final normalizedSpecies = species?.toLowerCase().trim();

    final coefficients = _speciesCoefficients[normalizedSpecies] ??
        _speciesCoefficients['default']!;

    final a = coefficients['a']!;
    final b = coefficients['b']!;

    // W = a * L^b
    return a * pow(lengthCm, b);
  }

  /// Get list of all supported species
  static List<String> get supportedSpecies =>
      _speciesCoefficients.keys.where((k) => k != 'default').toList();
}
