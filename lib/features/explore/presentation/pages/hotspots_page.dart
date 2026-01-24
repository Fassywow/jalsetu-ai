import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/session/domain/repositories/session_repository.dart';

class HotspotsPage extends StatefulWidget {
  const HotspotsPage({super.key});

  @override
  State<HotspotsPage> createState() => _HotspotsPageState();
}

class _HotspotsPageState extends State<HotspotsPage> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = {};
  bool _isLoading = true;

  // Default to India center if no location
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  @override
  void initState() {
    super.initState();
    _loadHotspots();
  }

  Future<void> _loadHotspots() async {
    try {
      // 1. Get logged-in user
      final authRepo = getIt<AuthRepository>();
      final userId = await authRepo.getLoggedInUser();

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Fetch Sessions
      final sessionRepo = getIt<SessionRepository>();
      final sessions = await sessionRepo.getUserSessions(userId);

      Set<Marker> newMarkers = {};

      for (var session in sessions) {
        // Fetch detections specifically for this session
        final detections = await sessionRepo.getSessionDetections(session.id);

        if (detections.isNotEmpty) {
          for (var detection in detections) {
            // Safe parsing of coordinates
            final lat =
                double.tryParse(detection['location_lat']?.toString() ?? '');
            final lng =
                double.tryParse(detection['location_lng']?.toString() ?? '');
            final species = detection['class']?.toString() ?? 'Unknown Fish';

            if (lat != null && lng != null) {
              final isFreshwater =
                  ['rohu', 'catla', 'mrigal'].contains(species.toLowerCase());

              newMarkers.add(
                Marker(
                  markerId: MarkerId("${session.id}_${detection.hashCode}"),
                  position: LatLng(lat, lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(isFreshwater
                      ? BitmapDescriptor.hueBlue
                      : BitmapDescriptor.hueCyan),
                  infoWindow: InfoWindow(
                    title: species.toUpperCase(),
                    snippet: DateFormat('MMM d, y').format(session.startTime),
                  ),
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _isLoading = false;
        });

        // Auto-zoom to fit markers if any exist
        if (newMarkers.isNotEmpty) {
          final first = newMarkers.first.position;
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(first, 10));
        }
      }
    } catch (e) {
      debugPrint("Error loading hotspots: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "My Hotspots",
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kDefaultLocation,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Future: Filter Logic
        },
        label: Text("All Catches",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.filter_list),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}
