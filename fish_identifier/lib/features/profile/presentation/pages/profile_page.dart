import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../config/di/injection.dart';
import '../../../session/domain/repositories/session_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'terms_conditions_page.dart';
import 'privacy_policy_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LocalizationManager _loc = LocalizationManager();
  String _userName = "Angler";
  String _userPhone = "";
  int _userAge = 0;
  int _userExperience = 0;
  String _userLocation = "";
  String? _profilePicUrl;
  int _totalCatches = 0;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _calculateTotalCatches();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final authRepo = getIt<AuthRepository>();
    final userId = await authRepo.getLoggedInUser();

    if (mounted) {
      setState(() {
        _userPhone = userId ?? 'guest_user';
        _userName = prefs.getString('user_name') ?? 'Angler';
        _userAge = prefs.getInt('user_age') ?? 0;
        _userExperience = prefs.getInt('user_experience') ?? 0;
        _userLocation = prefs.getString('user_location') ?? '';
        _profilePicUrl = prefs.getString('profile_pic_url');
      });
    }
  }

  Future<void> _calculateTotalCatches() async {
    try {
      final authRepo = getIt<AuthRepository>();
      final userId = await authRepo.getLoggedInUser() ?? 'guest_user';
      final sessionRepo = getIt<SessionRepository>();

      // Get all sessions from local storage
      final sessions = await sessionRepo.getUserSessions(userId);

      int total = 0;
      // Sum up approximate counts from all detections in all sessions
      for (var session in sessions) {
        final detections = await sessionRepo.getSessionDetections(session.id);
        for (var detection in detections) {
          final count = detection['approximateCount'];
          if (count != null) {
            total += count is int ? count : int.tryParse(count.toString()) ?? 1;
          } else {
            total += 1; // Default count if not specified
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalCatches = total;
        });
      }
    } catch (e) {
      debugPrint("Error calculating total catches: $e");
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loc.translate('select_language'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption('English', 'en'),
              _buildLanguageOption('Hindi', 'hi'),
              _buildLanguageOption('Gujarati', 'gu'),
              _buildLanguageOption('Tamil', 'ta'),
              _buildLanguageOption('Bengali', 'bn'),
              _buildLanguageOption('Malayalam', 'ml'),
              _buildLanguageOption('Telugu', 'te'),
              _buildLanguageOption('Kannada', 'kn'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    final isSelected = _loc.currentLanguageCode == code;
    return ListTile(
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () async {
        await _loc.setLanguage(code);
        if (mounted) {
          Navigator.pop(context);
          setState(() {}); // Rebuild to apply language
        }
      },
    );
  }

  Future<void> _showManageProfileSheet() async {
    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You are currently offline. Please connect to the internet to update your profile.",
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: _userName);
    final ageController =
        TextEditingController(text: _userAge > 0 ? '$_userAge' : '');
    final expController = TextEditingController(
        text: _userExperience > 0 ? '$_userExperience' : '');
    final locationController = TextEditingController(text: _userLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Update Profile",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: _profilePicUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profilePicUrl!),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/images/logo.png'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploadProfilePicture,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.cake),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: expController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Experience (yrs)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.work),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveProfile(
                      nameController.text,
                      int.tryParse(ageController.text) ?? 0,
                      int.tryParse(expController.text) ?? 0,
                      locationController.text,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    // TODO: Implement ImageKit upload
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile picture upload coming soon!",
            style: GoogleFonts.outfit()),
      ),
    );
  }

  Future<void> _saveProfile(
      String name, int age, int experience, String location) async {
    final prefs = await SharedPreferences.getInstance();

    // Save locally
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setInt('user_experience', experience);
    await prefs.setString('user_location', location);

    // Update state
    setState(() {
      _userName = name;
      _userAge = age;
      _userExperience = experience;
      _userLocation = location;
    });

    // Save to Firestore
    try {
      final authRepo = getIt<AuthRepository>();
      final userId = await authRepo.getLoggedInUser();

      if (userId != null && userId != 'guest_user') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'name': name,
          'age': age,
          'experience': experience,
          'location': location,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loc.translate('profile_updated'),
                style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loc.translate('profile_update_local'),
                style: GoogleFonts.outfit()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _loc.translate('profile_logout_title'),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _loc.translate('profile_logout_msg'),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loc.translate('common_cancel'),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loc.translate('profile_logout'),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Future<void> _performLogout() async {
    try {
      final authRepo = getIt<AuthRepository>();
      await authRepo.logout();

      if (mounted) {
        // Navigate to onboarding page and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logout failed. Please try again.",
                style: GoogleFonts.outfit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            image: _profilePicUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_profilePicUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage('assets/images/logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_userLocation.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      _userLocation,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              if (_userAge > 0 || _userExperience > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${_userAge > 0 ? '$_userAge yrs' : ''} ${_userExperience > 0 ? '⋅ $_userExperience yrs exp' : ''}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     _buildStat("232", "Following"),
                    //     _buildStat("232", "Followers"),
                    //   ],
                    // ),
                    // const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showManageProfileSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Blue theme
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _loc.translate('profile_manage'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: OutlinedButton(
                        //     onPressed: () {},
                        //     style: OutlinedButton.styleFrom(
                        //       side: const BorderSide(
                        //           color: Colors.blue), // Blue theme
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(30),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(vertical: 12),
                        //     ),
                        //     child: Text(
                        //       "Detail",
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.blue, // Blue theme
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.phishing, "$_totalCatches",
                        _loc.translate('profile_total_catches'), Colors.blue),
                    _buildVerticalDivider(),
                    _buildStatItem(Icons.monetization_on, "\$1,400k",
                        _loc.translate('profile_approx_income'), Colors.green),
                    // _buildVerticalDivider(),
                    // _buildStatItem(Icons.visibility, "83,923", "Total Views",
                    //     Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Other Information",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // _buildSwitchTile(
                    //   Icons.notifications_outlined,
                    //   "Notification",
                    //   _notificationsEnabled,
                    //   (val) => setState(() => _notificationsEnabled = val),
                    // ),
                    // _buildDivider(),
                    _buildListTile(
                      Icons.translate,
                      "Language",
                      onTap: _showLanguageSelector,
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      Icons.dark_mode_outlined,
                      "Dark Mode",
                      _darkModeEnabled,
                      (val) => setState(() => _darkModeEnabled = val),
                    ),
                    _buildDivider(),
                    _buildListTile(Icons.description_outlined,
                        _loc.translate('profile_terms'), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsConditionsPage(),
                        ),
                      );
                    }),
                    _buildDivider(),
                    _buildListTile(Icons.security_outlined,
                        _loc.translate('profile_privacy'), onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Text(
              //   "Finances",
              //   style: GoogleFonts.poppins(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(24),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.05),
              //         blurRadius: 20,
              //         offset: const Offset(0, 10),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       _buildListTile(Icons.payment_outlined, "Payment & Payout"),
              //       _buildDivider(),
              //       _buildListTile(
              //           Icons.home_work_outlined, "Compare Mortgage Rates"),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutConfirmation,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    _loc.translate('profile_logout'),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, color: Colors.grey[100], indent: 56, endIndent: 24);
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}
