import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  static final LocalizationManager _instance = LocalizationManager._internal();
  factory LocalizationManager() => _instance;
  LocalizationManager._internal();

  String _currentLanguageCode = 'en';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString('language_code') ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    _currentLanguageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  String get currentLanguageCode => _currentLanguageCode;

  String translate(String key) {
    String? translation = _localizedValues[_currentLanguageCode]?[key];

    if (translation == null) {
      translation = _localizedValues['en']?[key];
    }

    return translation ?? key;
  }

  /// Translate fish species names
  String translateFishName(String englishName) {
    // Convert English name to translation key
    final key =
        'fish_${englishName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}';
    final translation = translate(key);

    // If translation returns the key itself (not found), return original uppercase name
    if (translation == key) {
      return englishName.toUpperCase();
    }
    return translation;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Onboarding & Auth (existing)
      'welcome_title': 'Welcome to\nSmart Catch AI',
      'welcome_desc':
          'Identify fish species, check quality,\nestimate weight - all offline!',
      'features_title': 'Powerful Features',
      'features_desc': 'Everything you need for your catch',
      'permissions_title': 'We need a few permissions',
      'permissions_desc':
          'To provide the best experience, Smart Catch AI needs access to:',
      'continue_btn': 'Continue',
      'get_started_btn': 'Get Started',
      'skip_btn': 'Skip',
      'next_btn': 'Next',
      'select_language': 'Select Language',
      'camera_perm': 'Camera',
      'camera_desc': 'To take photos of your catch',
      'location_perm': 'Location',
      'location_desc': 'To geotag your catches',
      'storage_perm': 'Storage',
      'storage_desc': 'To save your analysis results',
      'grant_perm': 'Grant Permissions',
      'login_title': 'What\'s your\nnumber?',
      'login_desc':
          'We use this to verify your identity and keep the community safe.',
      'phone_hint': 'Mobile Number',
      'send_otp': 'Next',
      'otp_title': 'Enter the\ncode',
      'otp_desc': 'We sent a code to',
      'verify_btn': 'Verify',
      'resend_otp': 'Resend OTP',
      'register_title': 'Fisherman Registration',
      'register_desc': 'Tell us a bit about yourself',
      'name_hint': 'Full Name',
      'age_hint': 'Age',
      'experience_hint': 'Years of Experience',
      'location_hint': 'Home Port / Location',
      'submit_btn': 'Submit',
      'no_internet': 'No Internet Connection',
      'check_internet': 'Please check your connection and try again.',
      'offline_title': 'You are Offline',
      'offline_desc':
          'It seems you don\'t have an internet connection. You can continue using the app offline.',
      'continue_offline': 'Continue Offline',
      'retry_connection': 'Retry Connection',

      // Common
      'common_save': 'Save',
      'common_cancel': 'Cancel',
      'common_delete': 'Delete',
      'common_edit': 'Edit',
      'common_yes': 'Yes',
      'common_no': 'No',
      'common_ok': 'OK',
      'common_close': 'Close',
      'common_loading': 'Loading...',
      'common_error': 'Error',
      'common_success': 'Success',
      'common_retry': 'Retry',
      'common_back': 'Back',
      'common_later': 'Later',

      // Home Page
      'home_offline_msg': 'You are offline. Some features may be limited.',
      'home_back_online': 'You\'re Back Online!',
      'home_back_online_desc':
          'Internet connection restored. Login now to sync your offline catches with the cloud.',
      'home_login_now': 'Login Now',
      'home_start_session': 'Start New Session',
      'home_start_session_desc':
          'Record a full fishing event. Identify species, check freshness, and log catch details for your history.',
      'home_identify_species': 'Identify Species',
      'home_identify_desc':
          'Quick fish identification without saving to history.',
      'home_check_freshness': 'Check Freshness',
      'home_check_freshness_title': 'Check Freshness',
      'home_check_freshness_desc':
          'Analyze visual cues to determine if fish is fresh or stale.',
      'home_measure_weight': 'Measure Weight',
      'home_scan': 'Scan',
      'home_gallery': 'Gallery',

      // Home Welcome
      'home_welcome_back': 'Welcome Back,',
      'home_captain': ' Captain!',
      'home_identify_label': 'Identify Species',
      'home_freshness_label': 'Check Freshness',
      'home_start_fishing': 'Start Fishing',
      'home_new_session': 'New Session',
      'home_new_session_desc': 'Record a new fishing event',
      'home_recent_activity': 'Recent Activity',
      'home_last_session': 'Last Session',
      'home_catches_recorded': 'Catches Recorded',

      // Detection Page
      'detection_result': 'Detection Result',
      'detection_species': 'Species',
      'detection_confidence': 'Confidence',
      'detection_freshness': 'Freshness',
      'detection_fresh': 'Fresh',
      'detection_stale': 'Stale',
      'detection_weight': 'Weight (kg)',
      'detection_count': 'Count',
      'detection_location': 'Location',
      'detection_vessel': 'Vessel ID',
      'detection_save_catch': 'Save Catch',
      'detection_saved_to_session': 'Saved to Session',
      'detection_rescan': 'Rescan',
      'detection_saving': 'Saving...',
      'detection_saved': 'Catch saved successfully!',
      'detection_error': 'Error saving catch',
      'detection_enter_details': 'Enter Catch Details',
      'detection_use_gps': 'Use GPS',
      'detection_manual_location': 'Enter manually',
      'detection_getting_location': 'Getting location...',
      'detection_catch_details_title': 'Catch Details',
      'detection_species_id_title': 'Species Identification',
      'detection_identification_result': 'Identification Result',
      'detection_fresh_fish': 'Fresh Fish',
      'detection_stale_fish': 'Stale Fish',
      'detection_confidence_label': 'Confidence',
      'detection_measure_weigh': 'Measure & Weigh',
      'detection_measure_desc':
          'Estimate the length and weight of your catch using a reference object (like a coin or card) placed next to the fish. This helps in logging accurate catch data.',
      'detection_measure_button': 'Measure',
      'detection_additional_details': 'Additional Details',
      'detection_fill_all_details':
          'Please fill in all details (Count & Location)',
      'detection_discard_session': 'Discard Session?',
      'detection_discard_message':
          'Are you sure you want to discard this session and go back?',
      'detection_discard_exit': 'Discard & Exit',
      'detection_failed_save': 'Failed to save',
      'detection_check_freshness_title': 'Check Freshness',
      'detection_check_freshness_desc':
          'This feature analyzes visual cues such as the eye clarity, gill color, and skin texture to determine if the fish is fresh or stale. It uses a specialized AI model trained on fish quality indicators.',
      'detection_check_now': 'Check Now',
      'detection_count_label': 'Approximate Count',
      'detection_count_hint': 'e.g., 5',
      'detection_location_manual': 'Location Name (Manual)',
      'detection_location_gps': 'Location (GPS)',
      'detection_location_hint_manual': 'e.g., Off coast of Mumbai',
      'detection_location_hint_auto': 'Auto-detected',
      'detection_vessel_label': 'Vessel ID (Optional)',
      'detection_vessel_hint': 'e.g., VSL-1234',
      'detection_use_gps_tooltip': 'Use GPS',
      'detection_enter_manually_tooltip': 'Enter manually',

      // Fish Species Names
      'fish_gilt_head_bream': 'Gilt-Head Bream',
      'fish_red_sea_bream': 'Red sea bream',
      'fish_striped_red_mullet': 'Striped Red Mullet',
      'fish_black_sea_sprat': 'black sea sprat',
      'fish_house_mackerel': 'house mackerel',
      'fish_red_mullet': 'red mullet',
      'fish_sea_bass': 'sea bass',
      'fish_shrimp': 'shrimp',
      'fish_trout': 'trout',

      // Profile Page
      'profile_title': 'Profile',
      'profile_manage': 'Manage',
      'profile_total_catches': 'Total Catches',
      'profile_approx_income': 'Total Approx. Income',
      'profile_other_info': 'Other Information',
      'profile_language': 'Language',
      'profile_dark_mode': 'Dark Mode',
      'profile_terms': 'Terms and Conditions of Use',
      'profile_privacy': 'Protection Policy',
      'profile_logout': 'Logout',
      'profile_logout_title': 'Logout',
      'profile_logout_msg':
          'Are you sure you want to logout? Your offline data will remain on this device.',
      'profile_update_title': 'Update Profile',
      'profile_offline_edit':
          'You are currently offline. Please connect to the internet to update your profile.',
      'profile_updated': 'Profile updated successfully!',
      'profile_update_local': 'Profile updated locally. Will sync when online.',

      // Session Pages
      'session_history': 'Catch History',
      'session_details': 'Session Details',
      'session_no_history': 'No catch history yet',
      'session_start_fishing':
          'Start fishing and save your catches to see them here.',
      'session_date': 'Date',
      'session_details_title': 'Session Details',
      'session_no_detections': 'No detections found',
      'session_deleted': 'Session deleted',
      'session_loading': 'Loading sessions...',
      'session_fishing_history': 'Fishing History',
      'session_refresh': 'Refresh',
      'session_no_history_found':
          'No fishing history found.\nConnect to internet to check cloud.',
      'session_catches_label': 'Catches',

      // Navigation
      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_explore': 'Explore',
      'nav_profile': 'Profile',

      // Dialogs
      'dialog_choose_source': 'Choose Source',
      'dialog_camera': 'Camera',
      'dialog_gallery': 'Gallery',
      'dialog_permissions_required': 'Permissions Required',

      // Measurement Pages
      'measure_ar_title': 'AR Measurement',
      'measure_image_title': 'Image Measurement',
      'measure_length': 'Length',
      'measure_width': 'Width',
      'measure_height': 'Height',
      'measure_weight_estimate': 'Estimated Weight',
      'measure_instructions': 'Instructions',
      'measure_calibrate': 'Calibrate',
      'measure_start': 'Start Measuring',
      'measure_reset': 'Reset',
      'measure_save': 'Save Measurement',
      'measure_place_reference': 'Place a reference object',
      'measure_tap_to_measure': 'Tap to measure',

      // Terms & Privacy
      'terms_title': 'Terms & Conditions',
      'privacy_title': 'Privacy Policy',
      'terms_accept': 'Accept',
      'terms_decline': 'Decline',
      'terms_last_updated': 'Last Updated',

      // Explore Page
      'explore_title': 'Explore',
      'explore_species_library': 'Species Library',
      'explore_fishing_tips': 'Fishing Tips',
      'explore_regulations': 'Regulations',
      'explore_weather': 'Weather',
      'explore_search': 'Search species...',

      // Explore AI Page
      'explore_ai_jalsetu': 'JalSetu',
      'explore_ai_history': 'History',
      'explore_ai_new_chat': 'New Chat',
      'explore_ai_no_history': 'No history yet',
      'explore_ai_greetings': 'Greetings, Human!',
      'explore_ai_how_assist': 'How may I assist you today?',
      'explore_ai_ask_anything': 'Ask me anything...',
      'explore_ai_image_attached': 'Image attached',
      'explore_ai_select_language': 'Select Language',
      'explore_ai_identify_fish': 'Identify this fish 📸',
      'explore_ai_cook_hilsa': 'How to cook Hilsa? 🍳',
      'explore_ai_rohu_healthy': 'Is Rohu healthy? ❤️',
      'explore_ai_best_frying': 'Best fish for frying 🍤',
      'explore_ai_error_msg':
          'Sorry, I encountered an error. Please check your internet connection.',
      'explore_ai_unknown_fish_prompt':
          'Please identify this fish species. If the image is unclear or you need more angles, let me know what additional photos would help. Provide the common name, scientific name, and key identifying features.',

      // Fish Categories
      'fish_category_supported': 'Smart Catch Supported',
      'fish_category_supported_desc':
          'Fish species that our AI can instantly identify.',
      'fish_category_marine': 'Marine Fish (Sea Fish)',
      'fish_category_marine_desc':
          'Saltwater fishes found in the coastal regions of India.',
      'fish_category_freshwater': 'Freshwater Fish',
      'fish_category_freshwater_desc':
          'Fishes found in rivers, lakes, and ponds across India.',
      'fish_category_shellfish': 'Shellfish',
      'fish_category_shellfish_desc':
          'Crustaceans and mollusks popular in Indian cuisine.',

      // Misc
      'explore_coming_soon': 'Explore Coming Soon',

      // Error Messages
      'error_camera_permission': 'Camera permission denied',
      'error_location_permission': 'Location permission denied',
      'error_storage_permission': 'Storage permission denied',
      'error_no_image': 'No image selected',
      'error_detection_failed': 'Detection failed. Please try again.',
      'error_save_failed': 'Failed to save. Please try again.',
      'error_load_failed': 'Failed to load data.',
      'error_network': 'Network error. Please check your connection.',

      // Success Messages
      'success_saved': 'Saved successfully!',
      'success_deleted': 'Deleted successfully!',
      'success_updated': 'Updated successfully!',
      'success_synced': 'Synced with cloud!',

      // Loading States
      'loading_detecting': 'Detecting species...',
      'loading_analyzing': 'Analyzing freshness...',
      'loading_measuring': 'Measuring...',
      'loading_saving': 'Saving...',
      'loading_syncing': 'Syncing...',
      'loading_please_wait': 'Please wait...',

      // Freshness Specific
      'freshness_analyzing': 'Analyzing Freshness',
      'freshness_result': 'Freshness Result',
      'freshness_score': 'Freshness Score',
      'freshness_indicators': 'Quality Indicators',
      'freshness_recommendation': 'Recommendation',
      'freshness_tips': 'Storage Tips',

      // Inception/Advanced Detection
      'inception_title': 'Advanced Analysis',
      'inception_quality': 'Quality Analysis',
      'inception_features': 'Detected Features',
      'inception_processing': 'Processing with AI...',
    },
    'hi': {
      'welcome_title': 'स्मार्ट कैच एआई में\nआपका स्वागत है',
      'welcome_desc':
          'मछली की प्रजातियों की पहचान करें, गुणवत्ता की जांच करें,\nवजन का अनुमान लगाएं - सब कुछ ऑफलाइन!',
      'features_title': 'शक्तिशाली सुविधाएँ',
      'features_desc': 'आपकी पकड़ के लिए आपको जो कुछ भी चाहिए',
      'permissions_title': 'हमें कुछ अनुमतियों की आवश्यकता है',
      'permissions_desc':
          'सर्वोत्तम अनुभव प्रदान करने के लिए, स्मार्ट कैच एआई को इसकी आवश्यकता है:',
      'continue_btn': 'जारी रखें',
      'get_started_btn': 'शुरू करें',
      'skip_btn': 'छोड़ें',
      'next_btn': 'अगला',
      'select_language': 'भाषा चुनें',
      'camera_perm': 'कैमरा',
      'camera_desc': 'अपनी पकड़ की तस्वीरें लेने के लिए',
      'location_perm': 'स्थान',
      'location_desc': 'अपनी पकड़ को जियोटैग करने के लिए',
      'storage_perm': 'स्टोरेज',
      'storage_desc': 'अपने विश्लेषण परिणामों को सहेजने के लिए',
      'grant_perm': 'अनुमतियाँ दें',
      'login_title': 'आपका नंबर\nक्या है?',
      'login_desc': 'हम इसका उपयोग आपकी पहचान सत्यापित करने के लिए करते हैं।',
      'phone_hint': 'मोबाइल नंबर',
      'send_otp': 'आगे',
      'otp_title': 'कोड दर्ज\nकरें',
      'otp_desc': 'हमने कोड भेजा है',
      'verify_btn': 'सत्यापित करें',
      'resend_otp': 'ओटीपी पुनः भेजें',
      'register_title': 'मछुआरा पंजीकरण',
      'register_desc': 'अपने बारे में थोड़ा बताएं',
      'name_hint': 'पूरा नाम',
      'age_hint': 'उम्र',
      'experience_hint': 'अनुभव के वर्ष',
      'location_hint': 'होम पोर्ट / स्थान',
      'submit_btn': 'जमा करें',
      'no_internet': 'कोई इंटरनेट कनेक्शन नहीं',
      'check_internet': 'कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।',
      'offline_title': 'आप ऑफलाइन हैं',
      'offline_desc':
          'ऐसा लगता है कि आपके पास इंटरनेट कनेक्शन नहीं है। आप ऐप का उपयोग ऑफलाइन जारी रख सकते हैं।',
      'continue_offline': 'ऑफलाइन जारी रखें',
      'retry_connection': 'पुनः प्रयास करें',

      // Common
      'common_save': 'सहेजें',
      'common_cancel': 'रद्द करें',
      'common_delete': 'हटाएं',
      'common_edit': 'संपादित करें',
      'common_yes': 'हां',
      'common_no': 'नहीं',
      'common_ok': 'ठीक है',
      'common_close': 'बंद करें',
      'common_loading': 'लोड हो रहा है...',
      'common_error': 'त्रुटि',
      'common_success': 'सफलता',
      'common_retry': 'पुनः प्रयास करें',
      'common_back': 'वापस',
      'common_later': 'बाद में',

      // Home Page
      'home_offline_msg': 'आप ऑफलाइन हैं। कुछ सुविधाएं सीमित हो सकती हैं।',
      'home_back_online': 'आप वापस ऑनलाइन हैं!',
      'home_back_online_desc':
          'इंटरनेट कनेक्शन बहाल हो गया है। अपनी ऑफलाइन पकड़ को क्लाउड के साथ सिंक करने के लिए अभी लॉगिन करें।',
      'home_login_now': 'अभी लॉगिन करें',
      'home_start_session': 'नया सत्र शुरू करें',
      'home_start_session_desc':
          'पूरी मछली पकड़ने की घटना रिकॉर्ड करें। प्रजातियों की पहचान करें, ताजगी की जांच करें, और अपने इतिहास के लिए पकड़ का विवरण लॉग करें।',
      'home_identify_species': 'प्रजाति पहचानें',
      'home_identify_desc': 'इतिहास में सहेजे बिना त्वरित मछली पहचान।',
      'home_check_freshness': 'ताजगी जांचें',
      'home_check_freshness_title': 'ताजगी जांचें',
      'home_check_freshness_desc':
          'यह निर्धारित करने के लिए दृश्य संकेतों का विश्लेषण करें कि मछली ताजी है या बासी।',
      'home_measure_weight': 'वजन मापें',
      'home_scan': 'स्कैन करें',
      'home_gallery': 'गैलरी',

      // Home Welcome
      'home_welcome_back': 'आपका स्वागत है,',
      'home_captain': ' कप्तान!',
      'home_identify_label': 'प्रजाति पहचानें',
      'home_freshness_label': 'ताजगी जांचें',
      'home_start_fishing': 'मछली पकड़ना शुरू करें',
      'home_new_session': 'नया सत्र',
      'home_new_session_desc': 'नई मछली पकड़ने की घटना रिकॉर्ड करें',
      'home_recent_activity': 'हाल की गतिविधि',
      'home_last_session': 'अंतिम सत्र',
      'home_catches_recorded': 'पकड़ रिकॉर्ड की गई',

      // Detection Page
      'detection_result': 'पहचान परिणाम',
      'detection_species': 'प्रजाति',
      'detection_confidence': 'विश्वास',
      'detection_freshness': 'ताजगी',
      'detection_fresh': 'ताजा',
      'detection_stale': 'बासी',
      'detection_weight': 'वजन (किलो)',
      'detection_count': 'गिनती',
      'detection_location': 'स्थान',
      'detection_vessel': 'पोत आईडी',
      'detection_save_catch': 'पकड़ सहेजें',
      'detection_saved_to_session': 'सत्र में सहेजा गया',
      'detection_rescan': 'फिर से स्कैन करें',
      'detection_saving': 'सहeज रहा है...',
      'detection_saved': 'पकड़ सफलतापूर्वक सहेजी गई!',
      'detection_error': 'पकड़ सहेजने में त्रुटि',
      'detection_enter_details': 'पकड़ विवरण दर्ज करें',
      'detection_use_gps': 'GPS उपयोग करें',
      'detection_manual_location': 'मैन्युअल रूप से दर्ज करें',
      'detection_getting_location': 'स्थान प्राप्त कर रहे हैं...',
      'detection_catch_details_title': 'पकड़ का विवरण',
      'detection_species_id_title': 'प्रजाति पहचान',
      'detection_identification_result': 'पहचान परिणाम',
      'detection_fresh_fish': 'ताजी मछली',
      'detection_stale_fish': 'बासी मछली',
      'detection_confidence_label': 'विश्वास',
      'detection_measure_weigh': 'मापें और तौलें',
      'detection_measure_desc':
          'अपनी पकड़ की लंबाई और वजन का अनुमान संदर्भ वस्तु का उपयोग करके लगाएं।',
      'detection_measure_button': 'मापें',
      'detection_additional_details': 'अतिरिक्त विवरण',
      'detection_fill_all_details': 'कृपया सभी विवरण भरें (गिनती और स्थान)',
      'detection_discard_session': 'सत्र रद्द करें?',
      'detection_discard_message':
          'क्या आप वाकई इस सत्र को रद्द करके वापस जाना चाहते हैं?',
      'detection_discard_exit': 'रद्द करें और बाहर जाएं',
      'detection_failed_save': 'सहेजने में विफल',
      'detection_check_freshness_title': 'ताजगी जांचें',
      'detection_check_freshness_desc':
          'यह सुविधा आंख की स्पष्टता, गिल रंग और त्वचा की बनावट जैसे दृश्य संकेतों का विश्लेषण करती है ताकि यह निर्धारित किया जा सके कि मछली ताजी है या बासी।',
      'detection_check_now': 'अभी जांचें',
      'detection_count_label': 'अनुमानित गिनती',
      'detection_count_hint': 'जैसे, 5',
      'detection_location_manual': 'स्थान का नाम (मैन्युअल)',
      'detection_location_gps': 'स्थान (GPS)',
      'detection_location_hint_manual': 'जैसे, मुंबई के तट से दूर',
      'detection_location_hint_auto': 'स्वचालित पता लगाया',
      'detection_vessel_label': 'जहाज आईडी (वैकल्पिक)',
      'detection_vessel_hint': 'जैसे, VSL-1234',
      'detection_use_gps_tooltip': 'GPS उपयोग करें',
      'detection_enter_manually_tooltip': 'मैन्युअल रूप से दर्ज करें',

      // Session Details Page (Hindi)
      'session_details_title': 'सत्र विवरण',
      'session_no_detections': 'कोई पहचान नहीं मिली',
      'detection_unknown': 'अज्ञात',
      'detection_fresh_catch': 'ताजा पकड़',
      'detection_not_fresh': 'ताजा नहीं',
      'detection_count_prefix': 'गिनती: ',
      'detection_gps_prefix': 'जीपीएस: ',
      'detection_location_prefix': 'स्थान: ',
      'detection_vessel_prefix': 'पोत: ',

      // Fish Species Names (Hindi)
      'fish_gilt_head_bream': 'सुनहरी सिर वाली ब्रीम',
      'fish_red_sea_bream': 'लाल समुद्री ब्रीम',
      'fish_striped_red_mullet': 'धारीदार लाल मुलेट',
      'fish_black_sea_sprat': 'काला समुद्री स्प्रैट',
      'fish_house_mackerel': 'घरेलू मैकेरल',
      'fish_red_mullet': 'लाल मुलेट',
      'fish_sea_bass': 'समुद्री बास',
      'fish_shrimp': 'झींगा',
      'fish_trout': 'ट्राउट मछली',

      // Profile Page
      'profile_title': 'प्रोफाइल',
      'profile_manage': 'प्रबंधित करें',
      'profile_total_catches': 'कुल पकड़',
      'profile_approx_income': 'कुल अनुमानित आय',
      'profile_other_info': 'अन्य जानकारी',
      'profile_language': 'भाषा',
      'profile_dark_mode': 'डार्क मोड',
      'profile_terms': 'उपयोग की शर्तें',
      'profile_privacy': 'सुरक्षा नीति',
      'profile_logout': 'लॉगआउट',
      'profile_logout_title': 'लॉगआउट',
      'profile_logout_msg':
          'क्या आप वाकई लॉगआउट करना चाहते हैं? आपका ऑफलाइन डेटा इस डिवाइस पर रहेगा।',
      'profile_update_title': 'प्रोफाइल अपडेट करें',
      'profile_offline_edit':
          'आप वर्तमान में ऑफलाइन हैं। अपनी प्रोफाइल अपडेट करने के लिए कृपया इंटरनेट से कनेक्ट करें।',
      'profile_updated': 'प्रोफाइल सफलतापूर्वक अपडेट की गई!',
      'profile_update_local':
          'प्रोफाइल स्थानीय रूप से अपडेट की गई। ऑनलाइन होने पर सिंक होगी।',

      // Session Pages
      'session_history': 'पकड़ का इतिहास',
      'session_details': 'सत्र विवरण',
      'session_no_history': 'अभी तक कोई पकड़ का इतिहास नहीं',
      'session_start_fishing':
          'मछली पकड़ना शुरू करें और अपनी पकड़ को यहां देखने के लिए सहेजें।',
      'session_date': 'तारीख',
      'session_time': 'समय',
      'session_catches': 'पकड़',
      'session_delete_confirm': 'इस सत्र को हटाएं?',
      'session_deleted': 'सत्र हटा दिया गया',
      'session_loading': 'सत्र लोड हो रहे हैं...',
      'session_fishing_history': 'मछली पकड़ने का इतिहास',
      'session_refresh': 'रीफ्रेश करें',
      'session_no_history_found':
          'कोई मछली पकड़ने का इतिहास नहीं मिला।\nक्लाउड चेक करने के लिए इंटरनेट से कनेक्ट करें।',
      'session_catches_label': 'पकड़',

      // Navigation
      'nav_home': 'होम',
      'nav_history': 'इतिहास',
      'nav_explore': 'एक्सप्लोर करें',
      'nav_profile': 'प्रोफाइल',

      // Dialogs
      'dialog_choose_source': 'स्रोत चुनें',
      'dialog_camera': 'कैमरा',
      'dialog_gallery': 'गैलरी',
      'dialog_permissions_required': 'अनुमतियां आवश्यक हैं',

      // Measurement Pages
      'measure_ar_title': 'AR माप',
      'measure_image_title': 'छवि माप',
      'measure_length': 'लंबाई',
      'measure_width': 'चौड़ाई',
      'measure_height': 'ऊंचाई',
      'measure_weight_estimate': 'अनुमानित वजन',
      'measure_instructions': 'निर्देश',
      'measure_calibrate': 'कैलिब्रेट करें',
      'measure_start': 'माप शुरू करें',
      'measure_reset': 'रीसेट करें',
      'measure_save': 'माप सहेजें',
      'measure_place_reference': 'संदर्भ वस्तु रखें',
      'measure_tap_to_measure': 'मापने के लिए टैप करें',

      // Terms & Privacy
      'terms_title': 'नियम और शर्तें',
      'privacy_title': 'गोपनीयता नीति',
      'terms_accept': 'स्वीकार करें',
      'terms_decline': 'अस्वीकार करें',
      'terms_last_updated': 'अंतिम अपडेट',

      // Explore Page
      'explore_title': 'एक्सप्लोर करें',
      'explore_species_library': 'प्रजाति पुस्तकालय',
      'explore_fishing_tips': 'मछली पकड़ने की युक्तियाँ',
      'explore_regulations': 'नियम',
      'explore_weather': 'मौसम',
      'explore_search': 'प्रजाति खोजें...',

      // Explore AI Page
      'explore_ai_jalsetu': 'जलसेतु',
      'explore_ai_history': 'इतिहास',
      'explore_ai_new_chat': 'नई चैट',
      'explore_ai_no_history': 'अभी तक कोई इतिहास नहीं',
      'explore_ai_greetings': 'नमस्ते, मित्र!',
      'explore_ai_how_assist': 'आज मैं आपकी कैसे मदद कर सकता हूँ?',
      'explore_ai_ask_anything': 'मुझसे कुछ भी पूछें...',
      'explore_ai_image_attached': 'छवि संलग्न',
      'explore_ai_select_language': 'भाषा चुनें',
      'explore_ai_identify_fish': 'इस मछली की पहचान करें 📸',
      'explore_ai_cook_hilsa': 'इलिश कैसे बनाएं? 🍳',
      'explore_ai_rohu_healthy': 'क्या रोहू स्वस्थ है? ❤️',
      'explore_ai_best_frying': 'तलने के लिए सबसे अच्छी मछली 🍤',
      'explore_ai_error_msg':
          'क्षमा करें, कोई त्रुटि हुई। कृपया अपना इंटरनेट कनेक्शन जाँचें।',
      'explore_ai_unknown_fish_prompt':
          'कृपया इस मछली की प्रजाति की पहचान करें। यदि छवि स्पष्ट नहीं है या आपको और कोणों की आवश्यकता है, तो मुझे बताएं कि कौन सी अतिरिक्त तस्वीरें मदद करेंगी। सामान्य नाम, वैज्ञानिक नाम और मुख्य पहचान विशेषताएं प्रदान करें।',

      // Fish Categories
      'fish_category_supported': 'स्मार्ट कैच समर्थित',
      'fish_category_supported_desc':
          'मछली प्रजातियाँ जिन्हें हमारा AI तुरंत पहचान सकता है।',
      'fish_category_marine': 'समुद्री मछली',
      'fish_category_marine_desc':
          'भारत के तटीय क्षेत्रों में पाई जाने वाली खारे पानी की मछलियाँ।',
      'fish_category_freshwater': 'मीठे पानी की मछली',
      'fish_category_freshwater_desc':
          'भारत की नदियों, झीलों और तालाबों में पाई जाने वाली मछलियाँ।',
      'fish_category_shellfish': 'शंख मछली',
      'fish_category_shellfish_desc':
          'भारतीय व्यंजनों में लोकप्रिय क्रस्टेशियन और मोलस्क।',

      // Misc
      'explore_coming_soon': 'एक्सप्लोर जल्द आ रहा है',

      // Error Messages
      'error_camera_permission': 'कैमरा अनुमति अस्वीकृत',
      'error_location_permission': 'स्थान अनुमति अस्वीकृत',
      'error_storage_permission': 'स्टोरेज अनुमति अस्वीकृत',
      'error_no_image': 'कोई छवि चयनित नहीं',
      'error_detection_failed': 'पहचान विफल। कृपया पुनः प्रयास करें।',
      'error_save_failed': 'सहेजने में विफल। कृपया पुनः प्रयास करें।',
      'error_load_failed': 'डेटा लोड करने में विफल।',
      'error_network': 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।',

      // Success Messages
      'success_saved': 'सफलतापूर्वक सहेजा गया!',
      'success_deleted': 'सफलतापूर्वक हटाया गया!',
      'success_updated': 'सफलतापूर्वक अपडेट किया गया!',
      'success_synced': 'क्लाउड के साथ सिंक किया गया!',

      // Loading States
      'loading_detecting': 'प्रजाति पहचान रहे हैं...',
      'loading_analyzing': 'ताजगी का विश्लेषण कर रहे हैं...',
      'loading_measuring': 'माप रहे हैं...',
      'loading_saving': 'सहेज रहे हैं...',
      'loading_syncing': 'सिंक कर रहे हैं...',
      'loading_please_wait': 'कृपया प्रतीक्षा करें...',

      // Freshness Specific
      'freshness_analyzing': 'ताजगी का विश्लेषण',
      'freshness_result': 'ताजगी परिणाम',
      'freshness_score': 'ताजगी स्कोर',
      'freshness_indicators': 'गुणवत्ता संकेतक',
      'freshness_recommendation': 'सिफारिश',
      'freshness_tips': 'भंडारण युक्तियाँ',

      // Inception/Advanced Detection
      'inception_title': 'उन्नत विश्लेषण',
      'inception_quality': 'गुणवत्ता विश्लेषण',
      'inception_features': 'पहचाने गए फीचर्स',
      'inception_processing': 'AI के साथ प्रोसेसिंग...',
    },
    'gu': {
      'welcome_title': 'સ્માર્ટ કેચ AI માં\nસ્વાગત છે',
      'welcome_desc':
          'માછલીની પ્રજાતિઓ ઓળખો, ગુણવત્તા તપાસો,\nવજનનો અંદાજ લગાવો - બધું ઑફલાઇન!',
      'features_title': 'શક્તિશાળી સુવિધાઓ',
      'features_desc': 'તમારી પકડ માટે તમને જે જોઈએ છે તે બધું',
      'permissions_title': 'અમને થોડી પરવાનગીઓની જરૂર છે',
      'permissions_desc':
          'શ્રેષ્ઠ અનુભવ પ્રદાન કરવા માટે, સ્માર્ટ કેચ AI ને આની ઍક્સેસની જરૂર છે:',
      'continue_btn': 'ચાલુ રાખો',
      'get_started_btn': 'શરૂ કરો',
      'skip_btn': 'છોડી દો',
      'next_btn': 'આગળ',
      'select_language': 'ભાષા પસંદ કરો',
      'camera_perm': 'કેમેરા',
      'camera_desc': 'તમારી પકડના ફોટા લેવા માટે',
      'location_perm': 'સ્થાન',
      'location_desc': 'તમારી પકડને જિયોટેગ કરવા માટે',
      'storage_perm': 'સ્ટોરેજ',
      'storage_desc': 'તમારા વિશ્લેષણ પરિણામો સાચવવા માટે',
      'grant_perm': 'પરવાનગી આપો',
      'login_title': 'લૉગિન',
      'login_desc': 'ચાલુ રાખવા માટે તમારો મોબાઇલ નંબર દાખલ કરો',
      'phone_hint': 'મોબાઇલ નંબર',
      'send_otp': 'OTP મોકલો',
      'otp_title': 'OTP ચકાસો',
      'otp_desc': 'મોકલેલ OTP દાખલ કરો',
      'verify_btn': 'ચકાસો',
      'resend_otp': 'OTP ફરીથી મોકલો',
      'register_title': 'માછીમાર નોંધણી',
      'register_desc': 'તમારા વિશે થોડું જણાવો',
      'name_hint': 'પૂરું નામ',
      'age_hint': 'ઉંમર',
      'experience_hint': 'અનુભવના વર્ષો',
      'location_hint': 'હોમ પોર્ટ / સ્થાન',
      'submit_btn': 'સબમિટ કરો',
      'no_internet': 'ઇન્ટરનેટ કનેક્શન નથી',
      'check_internet': 'કૃપા કરીને તમારું કનેક્શન તપાસો અને ફરીથી પ્રયાસ કરો.',
      'offline_title': 'તમે ઑફલાઇન છો',
      'offline_desc':
          'તમારી પાસે ઇન્ટરનેટ કનેક્શન નથી. તમે ઍપનો ઑફલાઇન ઉપયોગ ચાલુ રાખી શકો છો.',
      'continue_offline': 'ઑફલાઇન ચાલુ રાખો',
      'retry_connection': 'ફરીથી પ્રયાસ કરો',

      // Common
      'common_save': 'સાચવો',
      'common_cancel': 'રદ કરો',
      'common_delete': 'કાઢી નાખો',
      'common_edit': 'સંપાદિત કરો',
      'common_yes': 'હા',
      'common_no': 'ના',
      'common_ok': 'બરાબર',
      'common_close': 'બંધ કરો',
      'common_loading': 'લોડ થઈ રહ્યું છે...',
      'common_error': 'ભૂલ',
      'common_success': 'સફળતા',
      'common_retry': 'ફરીથી પ્રયાસ કરો',
      'common_back': 'પાછળ',
      'common_later': 'પછી',

      // Home, Detection, Profile, Sessions (Gujarati translations)
      'home_offline_msg': 'તમે ઑફલાઇન છો. કેટલીક સુવિધાઓ મર્યાદિત હોઈ શકે છે.',
      'home_back_online': 'તમે પાછા ઑનલાઇન છો!',
      'home_back_online_desc':
          'ઇન્ટરનેટ કનેક્શન પુનઃસ્થાપિત થયું. તમારા ઑફલાઇન કેચને ક્લાઉડ સાથે સિંક કરવા માટે હવે લૉગિન કરો.',
      'home_login_now': 'હવે લૉગિન કરો',
      'home_start_session': 'નવો સત્ર શરૂ કરો',
      'home_start_session_desc':
          'સંપૂર્ણ માછીમારી ઘટના રેકૉર્ડ કરો. પ્રજાતિઓ ઓળખો, તાજગી તપાસો, અને તમારા ઇતિહાસ માટે કેચની વિગતો લોગ કરો.',
      'home_identify_species': 'પ્રજાતિ ઓળખો',
      'home_identify_desc': 'ઇતિહાસમાં સાચવ્યા વિના ઝડપી માછલી ઓળખ.',
      'home_check_freshness': 'તાજગી તપાસો',
      'home_check_freshness_title': 'તાજગી તપાસો',
      'home_check_freshness_desc':
          'માછલી તાજી છે કે બાસી તે નક્કી કરવા માટે દ્રશ્ય સંકેતોનું વિશ્લેષણ કરો.',
      'home_measure_weight': 'વજન માપો',
      'home_scan': 'સ્કેન કરો',
      'home_gallery': 'ગેલેરી',

      // Home Welcome
      'home_welcome_back': 'પાછા આવ્યા,',
      'home_captain': ' કેપ્ટન!',
      'home_identify_label': 'પ્રજાતિ ઓળખો',
      'home_freshness_label': 'તાજગી તપાસો',
      'home_start_fishing': 'માછીમારી શરૂ કરો',
      'home_new_session': 'નવો સત્ર',
      'home_new_session_desc': 'નવી માછીમારી ઘટના રેકૉર્ડ કરો',
      'home_recent_activity': 'હાલની ગતિવિધિ',
      'home_last_session': 'છેલ્લો સત્ર',
      'home_catches_recorded': 'કેચ રેકૉર્ડ કર્યા',

      'detection_result': 'પરિણામ',
      'detection_species': 'પ્રજાતિ',
      'detection_confidence': 'વિશ્વાસ',
      'detection_freshness': 'તાજગી',
      'detection_fresh': 'તાજી',
      'detection_stale': 'બાસી',
      'detection_weight': 'વજન (કિગ્રા)',
      'detection_count': 'ગણતરી',
      'detection_location': 'સ્થાન',
      'detection_vessel': 'જહાજ ID',
      'detection_save_catch': 'કેચ સાચવો',
      'detection_saved_to_session': 'સત્રમાં સાચવ્યું',
      'detection_rescan': 'ફરી સ્કેન કરો',
      'detection_saving': 'સાચવી રહ્યું છે...',
      'detection_saved': 'કેચ સફળતાપૂર્વક સાચવી!',
      'detection_error': 'કેચ સાચવવામાં ભૂલ',
      'detection_enter_details': 'કેચની વિગતો દાખલ કરો',
      'detection_use_gps': 'GPS વાપરો',
      'detection_manual_location': 'મેન્યુઅલી દાખલ કરો',
      'detection_getting_location': 'સ્થાન મેળવી રહ્યા છીએ...',
      'detection_catch_details_title': 'કેચની વિગતો',
      'detection_species_id_title': 'પ્રજાતિ ઓળખ',
      'detection_identification_result': 'ઓળખ પરિણામ',
      'detection_fresh_fish': 'તાજી માછલી',
      'detection_stale_fish': 'બાસી માછલી',
      'detection_confidence_label': 'વિશ્વાસ',
      'detection_measure_weigh': 'માપો અને તોલો',
      'detection_measure_desc':
          'સંદર્ભ વસ્તુનો ઉપયોગ કરીને તમારી કેચની લંબાઈ અને વજનનો અંદાજ લગાવો.',
      'detection_measure_button': 'માપો',
      'detection_additional_details': 'અતિરિક્ત વિગતો',
      'detection_fill_all_details':
          'કૃપા કરીને સબૈ વિગતો ભરો (ગણતરી અને સ્થાન)',
      'detection_discard_session': 'સત્ર રદ કરવો?',
      'detection_discard_message':
          'શું તમે ખરેખર આ સત્રને રદ કરીને પાછા જવા માંગો છો?',
      'detection_discard_exit': 'રદ કરો અને બાહર જાઓ',
      'detection_failed_save': 'સાચવવામાં વિફળ',
      'detection_check_freshness_title': 'તાજગી તપાસો',
      'detection_check_freshness_desc':
          'આ વિશેષતા આંખની સ્પષ્ટતા, ગિલ રંગ અને ત્વચાની રચના જેવા દ્રશ્ય સંકેતોનું વિશ્લેષણ કરે છે તે નક્કી કરવા માટે કે માછલી તાજી છે કે બાસી.',
      'detection_check_now': 'હવે તપાસો',
      'detection_count_label': 'અંદાજિત ગણતરી',
      'detection_count_hint': 'જેમ કે, 5',
      'detection_location_manual': 'સ્થાનનું નામ (મેન્યુઅલ)',
      'detection_location_gps': 'સ્થાન (GPS)',
      'detection_location_hint_manual': 'જેમ કે, મુંબઈના કિનારે',
      'detection_location_hint_auto': 'સ્વચાલિત શોધાયેલ',
      'detection_vessel_label': 'જહાજ ID (વૈકલ્પિક)',
      'detection_vessel_hint': 'જેમ કે, VSL-1234',
      'detection_use_gps_tooltip': 'GPS વાપરો',
      'detection_enter_manually_tooltip': 'મેન્યુઅલી દાખલ કરો',

      // Session Details Page (Gujarati)
      'session_details_title': 'સત્ર વિગતો',
      'session_no_detections': 'કોઈ ઓળખ મળી નથી',
      'detection_unknown': 'અજ્ઞાત',
      'detection_fresh_catch': 'તાજી કેચ',
      'detection_not_fresh': 'તાજી નથી',
      'detection_count_prefix': 'ગણતરી: ',
      'detection_gps_prefix': 'GPS: ',
      'detection_location_prefix': 'સ્થાન: ',
      'detection_vessel_prefix': 'જહાજ: ',

      // Fish Species Names (Gujarati)
      'fish_gilt_head_bream': 'ગોલ્ડન હેડ બ્રીમ',
      'fish_red_sea_bream': 'લાલ સમુદ્રી બ્રીમ',
      'fish_striped_red_mullet': 'પટ્ટાવાળી લાલ મુલેટ',
      'fish_black_sea_sprat': 'કાળી સમુદ્રી સ્પ્રેટ',
      'fish_house_mackerel': 'ઘરેલું મેકરેલ',
      'fish_red_mullet': 'લાલ મુલેટ',
      'fish_sea_bass': 'સમુદ્રી બાસ',
      'fish_shrimp': 'ઝીંગા',
      'fish_trout': 'ટ્રાઉટ માછલી',

      'profile_title': 'પ્રોફાઇલ',
      'profile_manage': 'સંચાલિત કરો',
      'profile_total_catches': 'કુલ કેચ',
      'profile_approx_income': 'કુલ અંદાજિત આવક',
      'profile_other_info': 'અન્ય માહિતી',
      'profile_language': 'ભાષા',
      'profile_dark_mode': 'ડાર્ક મોડ',
      'profile_terms': 'ઉપયોગની શરતો',
      'profile_privacy': 'ગોપનીયતા નીતિ',
      'profile_logout': 'લૉગઆઉટ',
      'profile_logout_title': 'લૉગઆઉટ',
      'profile_logout_msg':
          'શું તમે ખરેખર લૉગઆઉટ કરવા માંગો છો? તમારો ઑફલાઇન ડેટા આ ઉપકરણ પર રહેશે.',
      'profile_update_title': 'પ્રોફાઇલ અપડેટ કરો',
      'profile_offline_edit':
          'તમે હાલમાં ઑફલાઇન છો. તમારી પ્રોફાઇલ અપડેટ કરવા માટે કૃપા કરીને ઇન્ટરનેટ સાથે કનેક્ટ કરો.',
      'profile_updated': 'પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ!',
      'profile_update_local':
          'પ્રોફાઇલ સ્થાનિક રીતે અપડેટ થઈ. ઑનલાઇન હોય ત્યારે સિંક થશે.',

      'session_history': 'કેચ ઇતિહાસ',
      'session_details': 'સત્ર વિગતો',
      'session_no_history': 'હજી સુધી કોઈ કેચ ઇતિહાસ નથી',
      'session_start_fishing':
          'માછીમારી શરૂ કરો અને તમારી કેચને અહીં જોવા માટે સાચવો.',
      'session_date': 'તારીખ',
      'session_time': 'સમય',
      'session_catches': 'કેચ',
      'session_delete_confirm': 'આ સત્ર કાઢી નાખવો?',
      'session_deleted': 'સત્ર કાઢી નાખ્યો',
      'session_loading': 'સત્રો લોડ થઈ રહ્યા છે...',
      'session_fishing_history': 'માછીમારી ઇતિહાસ',
      'session_refresh': 'રીફ્રેશ કરો',
      'session_no_history_found':
          'માછીમારીનો કોઈ ઇતિહાસ મળ્યો નથી.\nક્લાઉડ તપાસવા માટે ઇન્ટરનેટ સાથે કનેક્ટ કરો.',
      'session_catches_label': 'કેચ',

      'nav_home': 'હોમ',
      'nav_history': 'ઇતિહાસ',
      'nav_explore': 'શોધો',
      'nav_profile': 'પ્રોફાઇલ',

      'dialog_choose_source': 'સ્રોત પસંદ કરો',
      'dialog_camera': 'કેમેરા',
      'dialog_gallery': 'ગેલેરી',
      'dialog_permissions_required': 'પરવાનગીઓ જરૂરી છે',

      'measure_ar_title': 'AR માપ',
      'measure_image_title': 'છબી માપ',
      'measure_length': 'લંબાઈ',
      'measure_width': 'પહોળાઈ',
      'measure_height': 'ઊંચાઈ',
      'measure_weight_estimate': 'અંદાજિત વજન',
      'measure_instructions': 'સૂચનાઓ',
      'measure_calibrate': 'કેલિબ્રેટ કરો',
      'measure_start': 'માપ શરૂ કરો',
      'measure_reset': 'રીસેટ કરો',
      'measure_save': 'માપ સાચવો',
      'measure_place_reference': 'સંદર્ભ વસ્તુ મૂકો',
      'measure_tap_to_measure': 'માપવા માટે ટૅપ કરો',

      'terms_title': 'નિયમો અને શરતો',
      'privacy_title': 'ગોપનીયતા નીતિ',
      'terms_accept': 'સ્વીકારો',
      'terms_decline': 'નકારો',
      'terms_last_updated': 'છેલ્લે અપડેટ કર્યું',

      'explore_title': 'શોધો',
      'explore_species_library': 'પ્રજાતિ લાઇબ્રેરી',
      'explore_fishing_tips': 'માછીમારી ટિપ્સ',
      'explore_regulations': 'નિયમો',
      'explore_weather': 'હવામાન',
      'explore_search': 'પ્રજાતિ શોધો...',

      // Explore AI Page
      'explore_ai_jalsetu': 'જલસેતુ',
      'explore_ai_history': 'ઇતિહાસ',
      'explore_ai_new_chat': 'નવી ચેટ',
      'explore_ai_no_history': 'હજી સુધી કોઈ ઇતિહાસ નથી',
      'explore_ai_greetings': 'નમસ્તે, મિત્ર!',
      'explore_ai_how_assist': 'આજે હું તમારી કેવી રીતે મદદ કરી શકું?',
      'explore_ai_ask_anything': 'મને કંઈપણ પૂછો...',
      'explore_ai_image_attached': 'છબી જોડાયેલ',
      'explore_ai_select_language': 'ભાષા પસંદ કરો',
      'explore_ai_identify_fish': 'આ માછલી ઓળખો 📸',
      'explore_ai_cook_hilsa': 'ઇલિશ કેવી રીતે બનાવવી? 🍳',
      'explore_ai_rohu_healthy': 'શું રોહુ સ્વસ્થ છે? ❤️',
      'explore_ai_best_frying': 'તળવા માટે શ્રેષ્ઠ માછલી 🍤',
      'explore_ai_error_msg':
          'માફ કરશો, કોઈ ભૂલ થઈ. કૃપા કરીને તમારું ઇન્ટરનેટ કનેક્શન તપાસો.',
      'explore_ai_unknown_fish_prompt':
          'કૃપા કરીને આ માછલીની પ્રજાતિ ઓળખો. જો છબી સ્પષ્ટ નથી અથવા તમને વધુ ખૂણાઓની જરૂર છે, તો મને જણાવો કે કઈ વધારાની તસવીરો મદદ કરશે. સામાન્ય નામ, વૈજ્ઞાનિક નામ અને મુખ્ય ઓળખ લક્ષણો પ્રદાન કરો.',

      // Fish Categories
      'fish_category_supported': 'સ્માર્ટ કેચ સપોર્ટેડ',
      'fish_category_supported_desc':
          'માછલીની પ્રજાતિઓ જેને અમારું AI તરત ઓળખી શકે છે.',
      'fish_category_marine': 'દરિયાઈ માછલી',
      'fish_category_marine_desc':
          'ભારતના દરિયાકિનારા વિસ્તારોમાં જોવા મળતી ખારા પાણીની માછલીઓ.',
      'fish_category_freshwater': 'તાજા પાણીની માછલી',
      'fish_category_freshwater_desc':
          'ભારતની નદીઓ, તળાવો અને તળાવોમાં જોવા મળતી માછલીઓ.',
      'fish_category_shellfish': 'શેલફિશ',
      'fish_category_shellfish_desc':
          'ભારતીય રસોઈમાં લોકપ્રિય ક્રસ્ટેશિયન અને મોલસ્ક.',

      // Misc
      'explore_coming_soon': 'શોધો શીઘ્ર આવી રહ્યું છે',

      'error_camera_permission': 'કેમેરા પરવાનગી નકારી',
      'error_location_permission': 'સ્થાન પરવાનગી નકારી',
      'error_storage_permission': 'સ્ટોરેજ પરવાનગી નકારી',
      'error_no_image': 'કોઈ છબી પસંદ કરી નથી',
      'error_detection_failed': 'શોધ નિષ્ફળ. કૃપા કરીને ફરીથી પ્રયાસ કરો.',
      'error_save_failed': 'સાચવવામાં નિષ્ફળ. કૃપા કરીને ફરીથી પ્રયાસ કરો.',
      'error_load_failed': 'ડેટા લોડ કરવામાં નિષ્ફળ.',
      'error_network': 'નેટવર્ક ભૂલ. કૃપા કરીને તમારું કનેક્શન તપાસો.',

      'success_saved': 'સફળતાપૂર્વક સાચવ્યું!',
      'success_deleted': 'સફળતાપૂર્વક કાઢી નાખ્યું!',
      'success_updated': 'સફળતાપૂર્વક અપડેટ કર્યું!',
      'success_synced': 'ક્લાઉડ સાથે સિંક થયું!',

      'loading_detecting': 'પ્રજાતિ શોધી રહ્યા છીએ...',
      'loading_analyzing': 'તાજગીનું વિશ્લેષણ કરી રહ્યા છીએ...',
      'loading_measuring': 'માપી રહ્યા છીએ...',
      'loading_saving': 'સાચવી રહ્યા છીએ...',
      'loading_syncing': 'સિંક કરી રહ્યા છીએ...',
      'loading_please_wait': 'કૃપા કરીને રાહ જુઓ...',

      'freshness_analyzing': 'તાજગીનું વિશ્લેષણ',
      'freshness_result': 'તાજગી પરિણામ',
      'freshness_score': 'તાજગી સ્કોર',
      'freshness_indicators': 'ગુણવત્તા સૂચકો',
      'freshness_recommendation': 'ભલામણ',
      'freshness_tips': 'સંગ્રહ ટિપ્સ',

      'inception_title': 'અદ્યતન વિશ્લેષણ',
      'inception_quality': 'ગુણવત્તા વિશ્લેષણ',
      'inception_features': 'શોધાયેલી વિશેષતાઓ',
      'inception_processing': 'AI સાથે પ્રોસેસિંગ...',
    },
    'ta': {
      'welcome_title': 'Smart Catch AI\nக்கு வரவேற்கிறோம்',
      'welcome_desc':
          'மீன் இனங்களை அடையாளம் காணவும், தரத்தை சரிபார்க்கவும்,\nஎடையை மதிப்பிடவும் - அனைத்தும் ஆஃப்லைனில்!',
      'features_title': 'சக்திவாய்ந்த அம்சங்கள்',
      'features_desc': 'உங்கள் பிடிப்புக்கு தேவையான அனைத்தும்',
      'permissions_title': 'எங்களுக்கு சில அனுமதிகள் தேவை',
      'permissions_desc':
          'சிறந்த அனுபவத்தை வழங்க, Smart Catch AI க்கு அணுகல் தேவை:',
      'continue_btn': 'தொடரவும்',
      'get_started_btn': 'தொடங்கவும்',
      'skip_btn': 'தவிர்',
      'next_btn': 'அடுத்து',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'camera_perm': 'கேமரா',
      'camera_desc': 'உங்கள் பிடிப்பின் புகைப்படங்களை எடுக்க',
      'location_perm': 'இடம்',
      'location_desc': 'உங்கள் பிடிப்புகளை ஜியோடேக் செய்ய',
      'storage_perm': 'சேமிப்பு',
      'storage_desc': 'உங்கள் பகுப்பாய்வு முடிவுகளை சேமிக்க',
      'grant_perm': 'அனுமதிகளை வழங்கவும்',
    },
    'bn': {
      'welcome_title': 'Smart Catch AI-তে\nস্বাগতম',
      'welcome_desc':
          'মাছের প্রজাতি শনাক্ত করুন, গুণমান পরীক্ষা করুন,\nওজন অনুমান করুন - সব অফলাইনে!',
      'features_title': 'শক্তিশালী বৈশিষ্ট্য',
      'features_desc': 'আপনার যা কিছু প্রয়োজন',
      'permissions_title': 'আমাদের কিছু অনুমতির প্রয়োজন',
      'permissions_desc':
          'সেরা অভিজ্ঞতা প্রদানের জন্য, Smart Catch AI-এর অ্যাক্সেস প্রয়োজন:',
      'continue_btn': 'চালিয়ে যান',
      'get_started_btn': 'শুরু করুন',
      'skip_btn': 'এড়িয়ে যান',
      'next_btn': 'পরবর্তী',
      'select_language': 'ভাষা নির্বাচন করুন',
      'camera_perm': 'ক্যামেরা',
      'camera_desc': 'আপনার মাছের ছবি তুলতে',
      'location_perm': 'অবস্থান',
      'location_desc': 'আপনার ক্যাচ জিওট্যাগ করতে',
      'storage_perm': 'স্টোরেজ',
      'storage_desc': 'আপনার বিশ্লেষণের ফলাফল সংরক্ষণ করতে',
      'grant_perm': 'অনুমতি দিন',
    },
    'ml': {
      'welcome_title': 'Smart Catch AI-യിലേക്ക്\nസ്വാഗതം',
      'welcome_desc':
          'മത്സ്യ ഇനങ്ങൾ തിരിച്ചറിയുക, ഗുണനിലവാരം പരിശോധിക്കുക,\nഭാരം കണക്കാക്കുക - എല്ലാം ഓഫ്‌ലൈനായി!',
      'features_title': 'ശക്തമായ സവിശേഷതകൾ',
      'features_desc': 'നിങ്ങൾക്ക് ആവശ്യമുള്ളതെല്ലാം',
      'permissions_title': 'ഞങ്ങൾക്ക് ചില അനുമതികൾ ആവശ്യമാണ്',
      'permissions_desc':
          'മികച്ച അനുഭവം നൽകുന്നതിന്, Smart Catch AI-ക്ക് ആക്‌സസ് ആവശ്യമാണ്:',
      'continue_btn': 'തുടരുക',
      'get_started_btn': 'തുടങ്ങുക',
      'skip_btn': 'ഒഴിവാക്കുക',
      'next_btn': 'അടുത്തത്',
      'select_language': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'camera_perm': 'ക്യാമറ',
      'camera_desc': 'ഫോട്ടോകൾ എടുക്കാൻ',
      'location_perm': 'സ്ഥലം',
      'location_desc': 'ലൊക്കേഷൻ ടാഗ് ചെയ്യാൻ',
      'storage_perm': 'സ്റ്റോറേജ്',
      'storage_desc': 'ഫലങ്ങൾ സേവ് ചെയ്യാൻ',
      'grant_perm': 'അനുമതികൾ നൽകുക',
    },
    'te': {
      'welcome_title': 'Smart Catch AIకి\nస్వాగతం',
      'welcome_desc':
          'చేప జాతులను గుర్తించండి, నాణ్యతను తనిఖీ చేయండి,\nబరువును అంచనా వేయండి - అన్నీ ఆఫ్‌లైన్‌లో!',
      'features_title': 'శక్తివంతమైన ఫీచర్లు',
      'features_desc': 'మీకు కావాల్సినవన్నీ',
      'permissions_title': 'మాకు కొన్ని అనుమతులు అవసరం',
      'permissions_desc':
          'ఉత్తమ అనుభవాన్ని అందించడానికి, Smart Catch AIకి యాక్సెస్ అవసరం:',
      'continue_btn': 'కొనసాగించు',
      'get_started_btn': 'ప్రారంభించు',
      'skip_btn': 'దాటవేయి',
      'next_btn': 'తరువాత',
      'select_language': 'భాషను ఎంచుకోండి',
      'camera_perm': 'కెమెరా',
      'camera_desc': 'ఫోటోలు తీయడానికి',
      'location_perm': 'స్థానం',
      'location_desc': 'లొకేషన్ ట్యాగ్ చేయడానికి',
      'storage_perm': 'స్టోరేజ్',
      'storage_desc': 'ఫలితాలను సేవ్ చేయడానికి',
      'grant_perm': 'అనుమతులు ఇవ్వండి',
    },
    'kn': {
      'welcome_title': 'Smart Catch AI ಗೆ\nಸ್ವಾಗತ',
      'welcome_desc':
          'ಮೀನಿನ ಜಾತಿಗಳನ್ನು ಗುರುತಿಸಿ, ಗುಣಮಟ್ಟವನ್ನು ಪರಿಶೀಲಿಸಿ,\nತೂಕವನ್ನು ಅಂದಾಜು ಮಾಡಿ - ಎಲ್ಲವೂ ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ!',
      'features_title': 'ಶಕ್ತಿಯುತ ವೈಶಿಷ್ಟ್ಯಗಳು',
      'features_desc': 'ನಿಮಗೆ ಬೇಕಾಗಿರುವುದೆಲ್ಲವೂ',
      'permissions_title': 'ನಮಗೆ ಕೆಲವು ಅನುಮತಿಗಳು ಬೇಕು',
      'permissions_desc':
          'ಉತ್ತಮ ಅನುಭವವನ್ನು ನೀಡಲು, Smart Catch AI ಗೆ ಪ್ರವೇಶದ ಅಗತ್ಯವಿದೆ:',
      'continue_btn': 'ಮುಂದುವರಿಸಿ',
      'get_started_btn': 'ಪ್ರಾರಂಭಿಸಿ',
      'skip_btn': 'ಸ್ಕಿಪ್ ಮಾಡಿ',
      'next_btn': 'ಮುಂದೆ',
      'select_language': 'ಭಾಷೆಯನ್ನು ಆರಿಸಿ',
      'camera_perm': 'ಕ್ಯಾಮೆರಾ',
      'camera_desc': 'ಫೋಟೋಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಲು',
      'location_perm': 'ಸ್ಥಳ',
      'location_desc': 'ಸ್ಥಳವನ್ನು ಟ್ಯಾಗ್ ಮಾಡಲು',
      'storage_perm': 'ಶೇಖರಣೆ',
      'storage_desc': 'ಫಲಿತಾಂಶಗಳನ್ನು ಉಳಿಸಲು',
      'grant_perm': 'ಅನುಮತಿಗಳನ್ನು ನೀಡಿ',
    },
  };
}
