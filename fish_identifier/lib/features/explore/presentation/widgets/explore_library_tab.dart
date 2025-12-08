import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/explore_repository.dart';
import '../../domain/entities/fish.dart';
import '../../../../core/localization/localization_manager.dart';
import '../pages/explore_page.dart'; // For FishCard

class ExploreLibraryTab extends StatefulWidget {
  const ExploreLibraryTab({super.key});

  @override
  State<ExploreLibraryTab> createState() => _ExploreLibraryTabState();
}

class _ExploreLibraryTabState extends State<ExploreLibraryTab> {
  final ExploreRepository _repository = ExploreRepository();
  Future<List<FishCategory>>? _categoriesFuture;
  final LocalizationManager _loc = LocalizationManager();
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final currentLang = _loc.currentLanguageCode;
    // Only reload if language changed or first load
    if (_lastLanguageCode != currentLang) {
      _lastLanguageCode = currentLang;
      _categoriesFuture = _repository.getFishCategories();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if language changed when tab becomes visible again
    if (_lastLanguageCode != _loc.currentLanguageCode) {
      setState(() {
        _loadData();
      });
    }
  }

  // Get translated category name based on category ID
  String _getCategoryName(FishCategory category) {
    switch (category.id) {
      case 'supported':
        return _loc.translate('fish_category_supported');
      case 'marine':
        return _loc.translate('fish_category_marine');
      case 'freshwater':
        return _loc.translate('fish_category_freshwater');
      case 'shellfish':
        return _loc.translate('fish_category_shellfish');
      default:
        return category.name;
    }
  }

  // Get translated category description based on category ID
  String _getCategoryDescription(FishCategory category) {
    switch (category.id) {
      case 'supported':
        return _loc.translate('fish_category_supported_desc');
      case 'marine':
        return _loc.translate('fish_category_marine_desc');
      case 'freshwater':
        return _loc.translate('fish_category_freshwater_desc');
      case 'shellfish':
        return _loc.translate('fish_category_shellfish_desc');
      default:
        return category.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FishCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _loc.translate('error_load_failed'),
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final categories = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSupported = category.id == 'supported';
            final categoryName = _getCategoryName(category);
            final categoryDesc = _getCategoryDescription(category);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isSupported)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(Icons.stars_rounded,
                                  color: Colors.amber.shade700),
                            ),
                          Text(
                            categoryName,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      if (categoryDesc.isNotEmpty)
                        Text(
                          categoryDesc,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSupported)
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: category.fishes.length,
                      itemBuilder: (context, fishIndex) {
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 16),
                          child: FishCard(
                            fish: category.fishes[fishIndex],
                            isCompact: true,
                          ),
                        );
                      },
                    ),
                  )
                else
                  ...category.fishes.map((fish) => FishCard(fish: fish)),
              ],
            );
          },
        );
      },
    );
  }
}
