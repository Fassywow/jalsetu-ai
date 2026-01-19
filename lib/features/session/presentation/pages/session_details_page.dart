import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../features/session/domain/entities/session.dart';
import '../../../../features/session/domain/repositories/session_repository.dart';
import '../../../../core/localization/localization_manager.dart';

class SessionDetailsPage extends StatefulWidget {
  final Session session;

  const SessionDetailsPage({super.key, required this.session});

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  List<Map<String, dynamic>> _detections = [];
  bool _isLoading = true;
  final LocalizationManager _loc = LocalizationManager();

  @override
  void initState() {
    super.initState();
    _loadDetections();
  }

  Future<void> _loadDetections() async {
    debugPrint("Loading detections for session: ${widget.session.id}");
    try {
      final detections = await getIt<SessionRepository>()
          .getSessionDetections(widget.session.id);
      debugPrint("Loaded ${detections.length} detections");
      setState(() {
        _detections = detections;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading detections: $e");
      setState(() => _isLoading = false);
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _loc.translate('session_details_title'),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Session Summary
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.calendar_today,
                      color: Colors.blue.shade700, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, y', _loc.currentLanguageCode)
                          .format(widget.session.startTime),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      "${widget.session.totalDetections} ${_loc.translate('session_catches')}",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detections.isEmpty
                    ? Center(
                        child: Text(
                          _loc.translate('session_no_detections'),
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _detections.length,
                        itemBuilder: (context, index) {
                          final detection = _detections[index];
                          final imageUrl = detection['imageUrl'];
                          final isLocal =
                              imageUrl != null && !imageUrl.startsWith('http');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Header
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: imageUrl != null
                                        ? (isLocal
                                            ? Image.file(
                                                File(imageUrl),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey),
                                                ),
                                              )
                                            : Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ));
                                                },
                                              ))
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _loc.translateFishName(
                                                detection['class'] ??
                                                    'unknown'),
                                            style: GoogleFonts.outfit(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.green.shade100),
                                            ),
                                            child: Text(
                                              "${((detection['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (detection['freshness'] != null)
                                        Row(
                                          children: [
                                            Icon(
                                              detection['freshness'] == true
                                                  ? Icons.check_circle
                                                  : Icons.warning,
                                              size: 16,
                                              color:
                                                  detection['freshness'] == true
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              detection['freshness'] == true
                                                  ? _loc.translate(
                                                      'detection_fresh_catch')
                                                  : _loc.translate(
                                                      'detection_not_fresh'),
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                color: detection['freshness'] ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      // Add Count
                                      if (detection['approximateCount'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.numbers,
                                                  size: 16,
                                                  color: Colors.blue.shade700),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${_loc.translate('detection_count_prefix')}${detection['approximateCount']}",
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // Add GPS Location
                                      if (detection['latitude'] != null &&
                                          detection['longitude'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.gps_fixed,
                                                  size: 16,
                                                  color: Colors.green.shade700),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "${_loc.translate('detection_gps_prefix')}${detection['latitude'].toStringAsFixed(6)}, ${detection['longitude'].toStringAsFixed(6)}",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // Add Location Name (if manually entered)
                                      if (detection['locationName'] != null &&
                                          detection['locationName']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Colors.red.shade700),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "${_loc.translate('detection_location_prefix')}${detection['locationName']}",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      // Add Vessel ID
                                      if (detection['vesselId'] != null &&
                                          detection['vesselId']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.directions_boat,
                                                  size: 16,
                                                  color:
                                                      Colors.indigo.shade700),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${_loc.translate('detection_vessel_prefix')}${detection['vesselId']}",
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
