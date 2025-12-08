class FreshnessResult {
  final bool isFresh;
  final double confidence;
  final String? detailedLabel;
  final double? detailedConfidence;

  FreshnessResult({
    required this.isFresh,
    required this.confidence,
    this.detailedLabel,
    this.detailedConfidence,
  });

  @override
  String toString() {
    return 'FreshnessResult(isFresh: $isFresh, confidence: $confidence, detailedLabel: $detailedLabel, detailedConfidence: $detailedConfidence)';
  }
}
