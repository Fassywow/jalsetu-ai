import 'package:equatable/equatable.dart';

class PriceFactors extends Equatable {
  // Base prices per kg for major ports (Dec 2024 data provided)
  static const Map<String, Map<String, double>> speciesBasePrices = {
    'hilsa': {
      'Mumbai': 1200,
      'Chennai': 1100,
      'Vizag': 1000,
      'Kochi': 1150,
    },
    'pomfret': {
      'Mumbai': 800,
      'Chennai': 750,
      'Vizag': 700,
      'Kochi': 780,
    },
    'kingfish': {
      'Mumbai': 600,
      'Chennai': 550,
      'Vizag': 500,
      'Kochi': 580,
    },
    'shrimp': {
      'Mumbai': 450,
      'Chennai': 400,
      'Vizag': 380,
      'Kochi': 420,
    },
    'mackerel': {
      'Mumbai': 250,
      'Chennai': 220,
      'Vizag': 200,
      'Kochi': 240,
    },
    'rohu': {
      'Mumbai': 180,
      'Chennai': 160,
      'Vizag': 150,
      'Kochi': 170,
    },
    'catla': {
      'Mumbai': 170,
      'Chennai': 150,
      'Vizag': 140,
      'Kochi': 160,
    },
    'sea bass': {
      'Mumbai': 500,
      'Chennai': 480,
      'Vizag': 450,
      'Kochi': 490,
    },
    'trout': {
      'Mumbai': 400,
      'Chennai': 380,
      'Vizag': 350,
      'Kochi': 390,
    },
  };

  // Port location variation (10-30%)
  // Values represent percentage adjustment relative to base
  static const Map<String, double> portModifiers = {
    'Mumbai': 0.10, // +10%
    'Chennai': 0.05, // +5%
    'Vizag': 0.0, // Base
    'Kochi': 0.08, // +8%
    'Kolkata': 0.20, // +20%
    'Veraval': -0.05, // -5% (High supply)
  };

  // Seasonal & Demand Modifiers
  static const Map<String, double> seasonalModifiers = {
    'Regular Season': 0.0,
    'Festive Season (High Demand)': 0.30, // +30%
    'Off-Season': -0.15, // -15%
    'Monsoon (Low Supply)': 0.25, // +25%
    'Durga Puja (Hilsa Specific)': 0.50, // +50% for Hilsa
  };

  @override
  List<Object?> get props => [];
}
