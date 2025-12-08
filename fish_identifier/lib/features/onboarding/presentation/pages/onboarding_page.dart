import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/offline_mode_page.dart';
import '../../../../core/localization/localization_manager.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final LocalizationManager _loc = LocalizationManager();

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/page1.png',
      'title': 'Welcome',
      'desc': 'Loading...',
    },
    {
      'image': 'assets/images/page2.png',
      'title': 'Features',
      'desc': 'Loading...',
    },
    {
      'image': 'assets/images/page3.png',
      'title': 'Permissions',
      'desc': 'Loading...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _onboardingData[0]['title'] = _loc.translate('welcome_title');
    _onboardingData[0]['desc'] = _loc.translate('welcome_desc');
    _onboardingData[1]['title'] = _loc.translate('features_title');
    _onboardingData[1]['desc'] = _loc.translate('features_desc');
    _onboardingData[2]['title'] = _loc.translate('permissions_title');
    _onboardingData[2]['desc'] = _loc.translate('permissions_desc');
  }

  void _nextPage() async {
    if (_currentPage == 2) {
      // Request permissions on the last slide before finishing
      await [
        Permission.camera,
        Permission.location,
        Permission.storage,
      ].request();
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    // connectivity_plus 6.0.0+ returns List<ConnectivityResult>
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (mounted) {
      if (hasInternet) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OfflineModePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Ocean Mist
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              _onboardingData[index]['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]['desc']!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.black87
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // FAB
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: FloatingActionButton(
                      onPressed: _nextPage,
                      backgroundColor: Colors.black87,
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
