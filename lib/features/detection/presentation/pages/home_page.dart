import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/widgets/source_selection_dialog.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/session/domain/entities/session.dart';
import '../../../../features/session/domain/repositories/session_repository.dart';
import '../bloc/detection_bloc.dart';
import '../bloc/detection_event.dart';
import '../bloc/detection_state.dart';
import 'detection_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../features/session/presentation/pages/session_history_page.dart';
import '../../../../core/localization/localization_manager.dart';
import 'freshness_page.dart';
import 'session_options_page.dart';
import '../../../../features/explore/presentation/pages/explore_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalizationManager _loc = LocalizationManager();
  int _currentIndex = 0;
  String? _userId;
  Session? _lastSession;
  bool _isLoadingSession = true;

  final List<Widget> _pages = [
    const SizedBox.shrink(), // Placeholder for Home (index 0)
    const SessionHistoryPage(), // History (index 1)
    const ExplorePage(), // Explore (index 2)
    const ProfilePage(), // Profile (index 3)
  ];

  String? _currentSessionId;
  bool _isSessionMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        if (result.contains(ConnectivityResult.none)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_loc.translate('home_offline_msg')),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Internet Restored
          if (_userId == null) {
            // Prompt for login if guest
            _showLoginPrompt();
          }
        }
      }
    });
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wifi,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                _loc.translate('home_back_online'),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                _loc.translate('home_back_online_desc'),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Text(
                        _loc.translate('common_later'),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ).then((_) => _loadUserData());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _loc.translate('home_login_now'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    final authRepo = getIt<AuthRepository>();
    final userId = await authRepo.getLoggedInUser(); // Returns phone number

    if (userId != null) {
      setState(() => _userId = userId);

      // Merge any guest data
      await getIt<SessionRepository>().mergeGuestData(userId);

      _loadLastSession(userId);
    } else {
      setState(() => _isLoadingSession = false);
    }
  }

  Future<void> _loadLastSession(String userId) async {
    try {
      final session = await getIt<SessionRepository>().getLastSession(userId);
      if (mounted) {
        setState(() {
          _lastSession = session;
          _isLoadingSession = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading last session: $e");
      if (mounted) {
        setState(() => _isLoadingSession = false);
      }
    }
  }

  Future<void> _startSessionFlow() async {
    showDialog(
      context: context,
      builder: (context) => SourceSelectionDialog(
        title: _loc.translate('home_start_session'),
        description: _loc.translate('home_start_session_desc'),
        onCameraTap: () {
          Navigator.pop(context);
          _initiateSession(true);
        },
        onGalleryTap: () {
          Navigator.pop(context);
          _initiateSession(false);
        },
      ),
    );
  }

  Future<void> _initiateSession(bool isCamera) async {
    // Don't create session yet. Just set mode and navigate.
    _currentSessionId = null;
    _isSessionMode = true;

    if (isCamera) {
      context.read<DetectionBloc>().add(const PickImageFromCamera());
    } else {
      context.read<DetectionBloc>().add(const PickImageFromGallery());
    }
  }

  Future<void> _identifySpecies() async {
    // Clear session ID to indicate standalone identification
    _currentSessionId = null;
    _isSessionMode = false;

    showDialog(
      context: context,
      builder: (context) => SourceSelectionDialog(
        title: _loc.translate('home_identify_species'),
        description: _loc.translate('home_identify_desc'),
        onCameraTap: () {
          Navigator.pop(context);
          context.read<DetectionBloc>().add(const PickImageFromCamera());
        },
        onGalleryTap: () {
          Navigator.pop(context);
          context.read<DetectionBloc>().add(const PickImageFromGallery());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DetectionBloc, DetectionState>(
      listener: (context, state) {
        if (state is DetectionSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetectionPage(
                sessionId: _currentSessionId,
                isSessionMode: _isSessionMode,
              ),
            ),
          ).then((_) {
            // Refresh last session when returning
            if (_userId != null) _loadLastSession(_userId!);
          });
        } else if (state is DetectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is FreshnessAnalysisSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FreshnessPage(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Stack(
          children: [
            _currentIndex == 0
                ? DetectionView(
                    loc: _loc,
                    onStartSession: _startSessionFlow,
                    lastSession: _lastSession,
                    isLoadingSession: _isLoadingSession,
                    onIdentifySpecies: _identifySpecies,
                  )
                : _pages[_currentIndex],
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, "Home"),
                    _buildNavItem(1, Icons.history_rounded, "History"),
                    _buildNavItem(2, Icons.explore_rounded, "Explore"),
                    _buildNavItem(3, Icons.person_rounded, "Profile"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}

class DetectionView extends StatelessWidget {
  final LocalizationManager loc;
  final VoidCallback onStartSession;
  final VoidCallback onIdentifySpecies;
  final Session? lastSession;
  final bool isLoadingSession;

  const DetectionView({
    super.key,
    required this.loc,
    required this.onStartSession,
    required this.onIdentifySpecies,
    this.lastSession,
    required this.isLoadingSession,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('home_welcome_back'),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        loc.translate('home_captain'),
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Main Action Area
              Text(
                loc.translate('home_start_fishing'),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),

              // Big Hero Button (New Session)
              GestureDetector(
                onTap: onStartSession,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E3192).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add_a_photo,
                                  color: Colors.white, size: 32),
                            ),
                            const Spacer(),
                            Text(
                              loc.translate('home_new_session'),
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              loc.translate('home_new_session_desc'),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary Actions
              Row(
                children: [
                  Expanded(
                    child: _SecondaryActionButton(
                      icon: Icons.search,
                      label: loc.translate('home_identify_label'),
                      color: Colors.purple,
                      onTap: onIdentifySpecies,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SecondaryActionButton(
                      icon: Icons.health_and_safety,
                      label: loc.translate('home_freshness_label'),
                      color: Colors.teal,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => SourceSelectionDialog(
                            title: loc.translate('home_check_freshness_title'),
                            description:
                                loc.translate('home_check_freshness_desc'),
                            onCameraTap: () {
                              Navigator.pop(context);
                              context.read<DetectionBloc>().add(
                                  const PickImageFromCamera(
                                      isFreshnessOnly: true));
                            },
                            onGalleryTap: () {
                              Navigator.pop(context);
                              context.read<DetectionBloc>().add(
                                  const PickImageFromGallery(
                                      isFreshnessOnly: true));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Start New Session Button (previously Live Guidance)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SessionOptionsPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_circle_outline,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start New Session",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            "Identify fish • 29 species supported",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Recent Activity Card
              if (!isLoadingSession && lastSession != null) ...[
                Text(
                  loc.translate('home_recent_activity'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.history,
                            color: Colors.orange.shade700, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('home_last_session'),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, y • h:mm a',
                                      loc.currentLanguageCode)
                                  .format(lastSession!.startTime),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${lastSession!.totalDetections} ${loc.translate('home_catches_recorded')}",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
