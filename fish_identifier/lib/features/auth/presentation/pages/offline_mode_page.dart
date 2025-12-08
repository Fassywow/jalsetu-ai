import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../features/splash/presentation/pages/splash_page.dart';
import '../../../detection/presentation/pages/home_page.dart';
import 'login_page.dart';

class OfflineModePage extends StatefulWidget {
  const OfflineModePage({super.key});

  @override
  State<OfflineModePage> createState() => _OfflineModePageState();
}

class _OfflineModePageState extends State<OfflineModePage> {
  final LocalizationManager _loc = LocalizationManager();
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 1000));

    final result = await Connectivity().checkConnectivity();

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      if (!result.contains(ConnectivityResult.none)) {
        // Internet is back, go to Splash to re-check auth
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashPage()),
        );
      } else {
        // Still offline
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_loc.translate('check_internet'))),
        );
      }
    }
  }

  void _continueOffline() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Ocean Mist
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'No Internet\nConnection',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You can still use the app in offline mode with limited features.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Try Again',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _continueOffline,
                child: Text(
                  'Continue Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
