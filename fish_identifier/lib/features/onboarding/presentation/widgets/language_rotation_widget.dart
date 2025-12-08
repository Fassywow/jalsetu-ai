import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageRotationWidget extends StatefulWidget {
  const LanguageRotationWidget({super.key});

  @override
  State<LanguageRotationWidget> createState() => _LanguageRotationWidgetState();
}

class _LanguageRotationWidgetState extends State<LanguageRotationWidget> {
  final List<Map<String, String>> _languages = [
    {'text': 'Select Language', 'code': 'en'}, // Default/Hint
    {'text': 'भाषा चुनें', 'code': 'hi'},
    {'text': 'ભાષા પસંદ કરો', 'code': 'gu'},
    {'text': 'மொழி தேர்வு', 'code': 'ta'},
    {'text': 'ভাষা নির্বাচন করুন', 'code': 'bn'},
    {'text': 'ഭാഷ തിരഞ്ഞെടുക്കുക', 'code': 'ml'},
    {'text': 'భాషను ఎంచుకోండి', 'code': 'te'},
    {'text': 'ಭಾಷೆಯನ್ನು ಆರಿಸಿ', 'code': 'kn'},
  ];

  // List for the dropdown items (excluding the "Select Language" animation items if needed,
  // but here we want the full list of selectable languages)
  final List<Map<String, String>> _selectableLanguages = [
    {'text': 'English', 'code': 'en'},
    {'text': 'हिंदी (Hindi)', 'code': 'hi'},
    {'text': 'ગુજરાતી (Gujarati)', 'code': 'gu'},
    {'text': 'தமிழ் (Tamil)', 'code': 'ta'},
    {'text': 'বাংলা (Bengali)', 'code': 'bn'},
    {'text': 'മലയാളം (Malayalam)', 'code': 'ml'},
    {'text': 'తెలుగు (Telugu)', 'code': 'te'},
    {'text': 'ಕನ್ನಡ (Kannada)', 'code': 'kn'},
  ];

  String? _selectedValue;
  int _currentIndex = 0;
  late Timer _timer;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startRotation();
  }

  void _startRotation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_selectedValue != null) return; // Stop rotating if selected

      if (_currentIndex < _languages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              const Icon(
                Icons.language,
                size: 22,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 30, // Fixed height for the rotating text
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _languages[index]['text']!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          items: _selectableLanguages
              .map((Map<String, String> item) => DropdownMenuItem<String>(
                    value: item['code'],
                    child: Text(
                      item['text']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: _selectedValue,
          onChanged: (String? value) {
            setState(() {
              _selectedValue = value;
            });
            // TODO: Implement actual localization logic here
            print("Selected Language Code: $value");
          },
          buttonStyleData: ButtonStyleData(
            height: 60,
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            offset: const Offset(0, -5),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
