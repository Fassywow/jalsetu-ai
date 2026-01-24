import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/price_factors.dart';
import '../../domain/services/price_calculation_service.dart';

class PricePredictionPage extends StatefulWidget {
  final String species;
  final double weightGrams;
  final bool isFresh;

  const PricePredictionPage({
    super.key,
    required this.species,
    required this.weightGrams,
    required this.isFresh,
  });

  @override
  State<PricePredictionPage> createState() => _PricePredictionPageState();
}

class _PricePredictionPageState extends State<PricePredictionPage> {
  String _selectedPort = 'Mumbai';
  String _selectedSeason = 'Regular Season';
  double _predictedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final price = PriceCalculationService.calculatePrice(
      species: widget.species,
      weightGrams: widget.weightGrams,
      isFresh: widget.isFresh,
      port: _selectedPort,
      season: _selectedSeason,
    );
    setState(() {
      _predictedPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fair Price Prediction',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Result Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Fair Price',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${_predictedPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Auction Estimate',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Input Factors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prediction Factors',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Species & Weight Info (Readonly)
                  _buildInfoRow(
                      Icons.set_meal, 'Species', widget.species.toUpperCase()),
                  _buildInfoRow(Icons.fitness_center, 'Weight',
                      '${(widget.weightGrams / 1000).toStringAsFixed(2)} kg'),
                  _buildInfoRow(
                    widget.isFresh ? Icons.check_circle : Icons.warning,
                    'Freshness',
                    widget.isFresh ? 'Fresh (100%)' : 'Stale (40%)',
                    color: widget.isFresh ? Colors.green : Colors.red,
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Port Selection
                  _buildDropdown<String>(
                    label: 'Port Location',
                    value: _selectedPort,
                    items: PriceFactors.portModifiers.keys.map((port) {
                      return DropdownMenuItem(value: port, child: Text(port));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPort = val);
                        _calculate();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Season Selection
                  _buildDropdown<String>(
                    label: 'Season & Demand',
                    value: _selectedSeason,
                    items: PriceFactors.seasonalModifiers.keys.map((season) {
                      return DropdownMenuItem(
                          value: season, child: Text(season));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSeason = val);
                        _calculate();
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Prices are estimates based on historical auction data and current market trends.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.outfit(color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
      ],
    );
  }
}
