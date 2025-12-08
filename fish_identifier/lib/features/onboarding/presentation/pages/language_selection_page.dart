import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/localization_manager.dart';
import 'onboarding_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    await LocalizationManager().loadLanguage();
    setState(() {
      _selectedLanguage = LocalizationManager().currentLanguageCode;
    });
  }

  Future<void> _onLanguageSelected(String code) async {
    setState(() {
      _selectedLanguage = code;
    });
    await LocalizationManager().setLanguage(code);
  }

  void _onContinue() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Ocean Mist
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Choose your\nLanguage',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select the language you prefer for the app.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguage == lang['code'];

                    return GestureDetector(
                      onTap: () {
                        _onLanguageSelected(lang['code']!);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black87 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.black87, width: 2)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang['native']!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
