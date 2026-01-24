import 'dart:ui' as ui;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/services/image_service.dart';
import '../../../../features/session/domain/repositories/session_repository.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../bloc/detection_bloc.dart';
import '../bloc/detection_event.dart';
import '../bloc/detection_state.dart';
import '../widgets/detection_painter.dart';
import '../../../../core/localization/localization_manager.dart';

import '../../../image_measurement/presentation/pages/image_measure_page.dart';
import '../../../explore/presentation/pages/explore_ai_page.dart';

/// Page displaying detection results
class DetectionPage extends StatefulWidget {
  final String? sessionId;
  final bool isSessionMode;

  const DetectionPage({
    super.key,
    this.sessionId,
    this.isSessionMode = false,
  });

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  ui.Image? _image;
  bool _isSaving = false;
  // Track if we have saved this catch to prevent duplicates
  bool _hasSaved = false;
  String? _activeSessionId;

  final LocalizationManager _loc = LocalizationManager();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _vesselController = TextEditingController();

  // GPS Location tracking
  double? _latitude;
  double? _longitude;
  bool _useManualLocation = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _activeSessionId = widget.sessionId;
    _loadImage();
    // Auto-fetch GPS location
    _getGPSLocation();
  }

  @override
  void dispose() {
    _countController.dispose();
    _locationController.dispose();
    _vesselController.dispose();
    super.dispose();
  }

  Future<void> _getGPSLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      log("Attempting to get GPS location...");

      // Check if GPS is on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("Location services are disabled");
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log("Location permissions denied");
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log("Location permissions permanently denied");
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get Position (Works Offline!)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });

      log("GPS location obtained: Lat=${position.latitude}, Long=${position.longitude}");

      // Update location display if not in manual mode
      if (!_useManualLocation) {
        _locationController.text =
            "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      }
    } catch (e) {
      log("Error getting GPS location: $e");
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _loadImage() async {
    final state = context.read<DetectionBloc>().state;
    if (state is DetectionSuccess) {
      // Pre-populate count from detections if it's currently empty
      if (_countController.text.isEmpty && state.detections.isNotEmpty) {
        _countController.text = state.detections.length.toString();
      }

      final bytes = await state.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _image = frame.image;
      });
    }
  }

  Future<void> _saveCatch() async {
    if (_hasSaved) return;

    // Validation
    if (_countController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loc.translate('detection_fill_all_details'),
              style: GoogleFonts.outfit()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final state = context.read<DetectionBloc>().state;

    if (state is DetectionSuccess) {
      try {
        log("Starting save process...");
        // Lazy Creation: Create session now if we don't have one but are in session mode
        if (_activeSessionId == null && widget.isSessionMode) {
          log("Creating new session...");
          // We need userId to create session.
          final authRepo = getIt<AuthRepository>();
          final userId = await authRepo.getLoggedInUser() ?? 'guest_user';
          log("Got userId: $userId");

          final session =
              await getIt<SessionRepository>().createSession(userId);
          _activeSessionId = session.id;
          log("Session created: $_activeSessionId");
        }

        // We assume one main detection for the catch
        if (_activeSessionId != null && state.detections.isNotEmpty) {
          log("Saving detection to session: $_activeSessionId");
          final detection = state.detections.first;

          final detectionData = {
            'class': detection.className,
            'confidence': detection.confidence,
            'boundingBox': {
              'left': detection.boundingBox.left,
              'top': detection.boundingBox.top,
              'width': detection.boundingBox.width,
              'height': detection.boundingBox.height,
            },
            'imageUrl': state.imageFile.path,
            'freshness': state.freshnessResult?.isFresh,
            'freshnessConfidence': state.freshnessResult?.confidence,
            // Form Data
            'approximateCount': int.tryParse(_countController.text) ?? 1,
            // Location data - 3 fields
            'latitude': _latitude,
            'longitude': _longitude,
            'locationName':
                _useManualLocation && _locationController.text.isNotEmpty
                    ? _locationController.text
                    : null,
            'vesselId': _vesselController.text,
            'timestamp': DateTime.now().toIso8601String(),
          };

          log("Detection data: species=${detection.className}, count=${detectionData['approximateCount']}, lat=${_latitude}, long=${_longitude}, locationName=${detectionData['locationName']}, vessel=${detectionData['vesselId']}");

          await getIt<SessionRepository>().addDetectionToSession(
            _activeSessionId!,
            detectionData,
          );
          log("Detection saved successfully to local storage");

          if (mounted) {
            setState(() {
              _hasSaved = true;
              _isSaving = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_loc.translate('detection_saved'),
                    style: GoogleFonts.outfit()),
                backgroundColor: Colors.green,
              ),
            );

            // Auto-navigate back to home after saving
            log("Navigating back to home...");
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              // Pop all the way back to home page
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          }
        } else {
          log("No active session or detections empty");
          if (mounted) setState(() => _isSaving = false);
        }
      } catch (e, stackTrace) {
        log("Failed to save detection: $e", error: e, stackTrace: stackTrace);
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${_loc.translate('detection_failed_save')}: $e",
                  style: GoogleFonts.outfit()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      log("State is not DetectionSuccess");
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isSessionMode || _hasSaved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_loc.translate('detection_discard_session'),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text(
              _loc.translate('detection_discard_message'),
              style: GoogleFonts.outfit(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_loc.translate('common_cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_loc.translate('detection_discard_exit'),
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          if (mounted) {
            // Pop all the way back to home page
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              // Trigger PopScope
              Navigator.maybePop(context);
            },
          ),
          title: Text(
            widget.isSessionMode
                ? _loc.translate('detection_catch_details_title')
                : _loc.translate('detection_species_id_title'),
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
              tooltip: 'New Catch',
            ),
          ],
        ),
        body: BlocBuilder<DetectionBloc, DetectionState>(
          builder: (context, state) {
            if (state is! DetectionSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Active Banner
                  if (widget.isSessionMode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.blue.shade100),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.timer,
                                size: 12, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.sessionId != null
                                ? "Session Active • #${widget.sessionId!.substring(0, 4)}"
                                : "New Session • Pending",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Image with bounding boxes
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    color: Colors.black,
                    child: _image != null
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      state.imageFile,
                                      fit: BoxFit.contain,
                                    ),
                                    CustomPaint(
                                      painter: DetectionPainter(
                                        detections: state.detections,
                                        image: _image,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Image.file(
                            state.imageFile,
                            fit: BoxFit.contain,
                          ),
                  ),

                  // Stats bar - COMMENTED OUT as requested
                  /*
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.radar,
                        label: 'Detections',
                        value: '${state.detections.length}',
                        color: Colors.blue,
                      ),
                      Container(
                          width: 1, height: 40, color: Colors.grey.shade200),
                      _StatItem(
                        icon: Icons.speed,
                        label: 'Time',
                        value: '${state.inferenceTime}ms',
                        color: Colors.green,
                      ),
                      Container(
                          width: 1, height: 40, color: Colors.grey.shade200),
                      _StatItem(
                        icon: Icons.photo_size_select_large,
                        label: 'Size',
                        value: '${_image?.width ?? 0}x${_image?.height ?? 0}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                */

                  const SizedBox(height: 24),

                  // 1. Detection Info (Title)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.isSessionMode
                          ? _loc.translate('detection_catch_details_title')
                          : _loc.translate('detection_identification_result'),
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  // 1. Detection Info or Low Confidence Warning
                  if (state.detections.isNotEmpty)
                    if (state.detections.first.confidence < 0.60)
                      // LOW CONFIDENCE UI
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5), // Light Orange
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFFFD180)), // Orange border
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Low Confidence Detection",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Our AI model is not confident about this identification. The image quality or fish angle may be affecting accuracy.",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.orange.shade800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Possible: ",
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    state.detections.first.className
                                        .toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    " (${(state.detections.first.confidence * 100).toStringAsFixed(0)}%)",
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to ExploreAIPage (JalSetu) with image
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExploreAIPage(
                                        initialImage: state.imageFile,
                                        initialPrompt:
                                            "I found this fish but I'm not sure. Can you identify it and tell me more?",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 20),
                                label: Text(
                                  "Ask JelsetuAI",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF1E88E5), // Blue
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wifi,
                                      size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Requires internet connection",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // HIGH CONFIDENCE UI (Standard)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Text(
                          _loc.translateFishName(
                              state.detections.first.className),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                  const SizedBox(height: 16),

                  // 2. Freshness Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (state.freshnessResult == null)
                          Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.health_and_safety,
                                    color: Colors.teal),
                              ),
                              title: Text(
                                _loc.translate(
                                    'detection_check_freshness_title'),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              childrenPadding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                Text(
                                  _loc.translate(
                                      'detection_check_freshness_desc'),
                                  style: GoogleFonts.outfit(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<DetectionBloc>()
                                          .add(CheckFreshness(state.imageFile));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      _loc.translate('detection_check_now'),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: state.freshnessResult!.isFresh
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  state.freshnessResult!.isFresh
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: state.freshnessResult!.isFresh
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.freshnessResult!.isFresh
                                            ? _loc.translate(
                                                'detection_fresh_fish')
                                            : _loc.translate(
                                                'detection_stale_fish'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: state.freshnessResult!.isFresh
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                      Text(
                                        '${_loc.translate('detection_confidence_label')}: ${(state.freshnessResult!.confidence * 100).toStringAsFixed(1)}%',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: Colors.grey[700],
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
                  ),

                  const SizedBox(height: 16),

                  // 3. Weight/Measure Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.straighten,
                              color: Colors.orange),
                        ),
                        title: Text(
                          _loc.translate('detection_measure_weigh'),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Text(
                            _loc.translate('detection_measure_desc'),
                            style: GoogleFonts.outfit(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ImageMeasurePage(
                                        imageFile: state.imageFile,
                                        species: state.detections.isNotEmpty
                                            ? state.detections.first.className
                                            : null,
                                        isFresh:
                                            state.freshnessResult?.isFresh ??
                                                true,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _loc.translate('detection_measure_button'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (widget.isSessionMode) ...[
                    const SizedBox(height: 24),

                    // 4. Additional Details Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _loc.translate('detection_additional_details'),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _countController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  _loc.translate('detection_count_label'),
                              hintText: _loc.translate('detection_count_hint'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _locationController,
                            enabled: _useManualLocation,
                            decoration: InputDecoration(
                              labelText: _useManualLocation
                                  ? _loc.translate('detection_location_manual')
                                  : _loc.translate('detection_location_gps'),
                              hintText: _useManualLocation
                                  ? _loc.translate(
                                      'detection_location_hint_manual')
                                  : _loc.translate(
                                      'detection_location_hint_auto'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: _isLoadingLocation
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : Icon(_useManualLocation
                                      ? Icons.edit_location
                                      : Icons.gps_fixed),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _useManualLocation
                                      ? Icons.gps_fixed
                                      : Icons.edit,
                                  color: _useManualLocation
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _useManualLocation = !_useManualLocation;
                                    if (_useManualLocation) {
                                      _locationController.clear();
                                    } else {
                                      // Switch back to GPS mode
                                      if (_latitude != null &&
                                          _longitude != null) {
                                        _locationController.text =
                                            "${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}";
                                      } else {
                                        _getGPSLocation();
                                      }
                                    }
                                  });
                                },
                                tooltip: _useManualLocation
                                    ? _loc
                                        .translate('detection_use_gps_tooltip')
                                    : _loc.translate(
                                        'detection_enter_manually_tooltip'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _vesselController,
                            decoration: InputDecoration(
                              labelText:
                                  _loc.translate('detection_vessel_label'),
                              hintText: _loc.translate('detection_vessel_hint'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.directions_boat),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 5. Save Button
                  if (widget.isSessionMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _hasSaved || _isSaving ? null : _saveCatch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        _hasSaved
                                            ? Icons.check
                                            : Icons.save_alt,
                                        color: _hasSaved
                                            ? Colors.green
                                            : Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      _hasSaved
                                          ? _loc.translate(
                                              'detection_saved_to_session')
                                          : _loc.translate(
                                              'detection_save_catch'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _hasSaved
                                            ? Colors.green
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
