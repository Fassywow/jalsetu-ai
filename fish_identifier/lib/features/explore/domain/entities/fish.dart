class Fish {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String nutritionalInfo;
  final List<String> regions;
  final String imageUrl;

  const Fish({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.nutritionalInfo,
    required this.regions,
    required this.imageUrl,
  });
}

class FishCategory {
  final String id;
  final String name;
  final String description;
  final List<Fish> fishes;

  const FishCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.fishes,
  });
}
