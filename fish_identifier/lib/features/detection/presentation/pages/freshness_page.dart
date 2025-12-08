import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/localization_manager.dart';
import '../bloc/detection_bloc.dart';
import '../bloc/detection_event.dart';
import '../bloc/detection_state.dart';

class FreshnessPage extends StatefulWidget {
  const FreshnessPage({super.key});

  @override
  State<FreshnessPage> createState() => _FreshnessPageState();
}

class _FreshnessPageState extends State<FreshnessPage> {
  final LocalizationManager _loc = LocalizationManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            context.read<DetectionBloc>().add(const ResetDetection());
            Navigator.pop(context);
          },
        ),
        title: Text(
          _loc.translate('detection_check_freshness_title'),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              context.read<DetectionBloc>().add(const ResetDetection());
              Navigator.pop(context);
            },
            tooltip: 'New Scan',
          ),
        ],
      ),
      body: BlocBuilder<DetectionBloc, DetectionState>(
        builder: (context, state) {
          if (state is DetectionLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FreshnessAnalysisSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        state.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Result Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status Icon & Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.result.isFresh
                                  ? Icons.check_circle
                                  : Icons.warning_rounded,
                              color: state.result.isFresh
                                  ? Colors.green
                                  : Colors.red,
                              size: 48,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              state.result.isFresh
                                  ? _loc.translate('detection_fresh_fish')
                                  : _loc.translate('detection_stale_fish'),
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: state.result.isFresh
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Confidence Meter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _loc.translate('detection_confidence_label'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${(state.result.confidence * 100).toStringAsFixed(1)}%",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: state.result.confidence,
                                minHeight: 8,
                                backgroundColor: Colors.grey[100],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  state.result.isFresh
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (state.result.detailedLabel != null) ...[
                    const SizedBox(height: 24),
                    // Detailed Analysis Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detailed Analysis",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.result.detailedLabel!
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (state.result.detailedConfidence != null)
                                      Text(
                                        "Confidence: ${(state.result.detailedConfidence! * 100).toStringAsFixed(1)}%",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Description / Tips
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _loc.translate('detection_check_freshness_desc'),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DetectionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _loc.translate('common_error'),
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<DetectionBloc>()
                            .add(const ResetDetection());
                        Navigator.pop(context);
                      },
                      child: Text(_loc.translate('common_back')),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
