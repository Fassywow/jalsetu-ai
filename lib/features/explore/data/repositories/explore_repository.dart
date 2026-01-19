import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/fish_model.dart';
import '../../domain/entities/fish.dart';
import '../../../../core/localization/localization_manager.dart';

class ExploreRepository {
  final LocalizationManager _loc = LocalizationManager();

  /// Get the JSON file path based on current language
  String _getJsonPath() {
    final langCode = _loc.currentLanguageCode;
    switch (langCode) {
      case 'hi':
        return 'assets/data/fish_data_hi.json';
      case 'gu':
        return 'assets/data/fish_data_gu.json';
      default:
        return 'assets/data/fish_data.json'; // English default
    }
  }

  Future<List<FishCategory>> getFishCategories() async {
    try {
      final String jsonPath = _getJsonPath();
      final String jsonString = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> categoriesJson = jsonMap['categories'];

      return categoriesJson.map((e) => FishCategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load fish data: $e');
    }
  }
}
