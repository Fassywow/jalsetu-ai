import '../../data/models/price_factors.dart';

class PriceCalculationService {
  /// Calculate estimated price based on the formula:
  /// Final Price = Base Price × Weight(kg) × Freshness Modifier × (1 + Modifiers)
  static double calculatePrice({
    required String species,
    required double weightGrams,
    required bool isFresh,
    required String port,
    required String season,
  }) {
    // Normalize species name
    final normalizedSpecies = species.toLowerCase().trim();

    // 1. Get Base Price (Default to Mackerel if species not found)
    final portPrices = PriceFactors.speciesBasePrices[normalizedSpecies] ??
        PriceFactors.speciesBasePrices['mackerel']!;

    // Get price for specific port, fallback to Mumbai
    final double basePricePerKg = portPrices[port] ?? portPrices['Mumbai']!;

    // 2. Weight in KG
    final double weightKg = weightGrams / 1000.0;

    // 3. Freshness Modifier
    // 100% (1.0) for fresh, 40% (0.4) for stale
    final double freshnessModifier = isFresh ? 1.0 : 0.4;

    // 4. Port Variation Modifier
    final double portMod = PriceFactors.portModifiers[port] ?? 0.0;

    // 5. Seasonal Modifier
    double seasonMod = PriceFactors.seasonalModifiers[season] ?? 0.0;

    // Special case: Durga Puja + Hilsa (as specified in logic)
    if (normalizedSpecies == 'hilsa' && season.contains('Durga Puja')) {
      seasonMod = 0.50;
    }

    // Calculation
    // Base Price * Weight * Freshness * (Seasonal Multiplier)
    // Note: The Port Variation is often already reflected in the base price,
    // but the logic mentioned "Port Location (10-30% variation)" as a factor.
    // We will apply the seasonal modifier on top of the port-adjusted base.

    double finalPrice = basePricePerKg *
        weightKg *
        freshnessModifier *
        (1 + seasonMod + portMod);

    return finalPrice;
  }
}
