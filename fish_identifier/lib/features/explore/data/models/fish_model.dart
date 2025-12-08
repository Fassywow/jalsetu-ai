import '../../domain/entities/fish.dart';

class FishModel extends Fish {
  const FishModel({
    required super.id,
    required super.name,
    required super.scientificName,
    required super.description,
    required super.nutritionalInfo,
    required super.regions,
    required super.imageUrl,
  });

  factory FishModel.fromJson(Map<String, dynamic> json) {
    return FishModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      description: json['description'] as String,
      nutritionalInfo: json['nutritional_info'] as String,
      regions: List<String>.from(json['regions'] as List),
      imageUrl: json['image_url'] as String,
    );
  }
}

class FishCategoryModel extends FishCategory {
  const FishCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.fishes,
  });

  factory FishCategoryModel.fromJson(Map<String, dynamic> json) {
    return FishCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      fishes: (json['fishes'] as List)
          .map((e) => FishModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
