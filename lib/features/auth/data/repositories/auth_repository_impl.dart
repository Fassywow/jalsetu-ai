import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required ApiService apiService,
    FirebaseFirestore? firestore,
  })  : _apiService = apiService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<String> sendOtp(String phoneNumber) async {
    final response = await _apiService.sendOTP(phoneNumber);
    // Assuming the API returns a verificationId or we use the phone number as ID for this specific API flow if it doesn't return one.
    // Looking at the API usage in the prompt, verifyOTP takes verificationId.
    // Let's assume the response data contains it.
    final data = response.data;
    if (data['data'] != null && data['data']['verificationId'] != null) {
      return data['data']['verificationId'];
    }
    throw Exception('Failed to get verification ID');
  }

  @override
  Future<bool> verifyOtp(
      String phoneNumber, String otp, String verificationId) async {
    final response =
        await _apiService.verifyOTP(phoneNumber, otp, verificationId);
    final data = response.data;
    // Check response for success
    if (data['data'] != null && data['data']['responseCode'] == '200') {
      return true;
    }
    return false;
  }

  @override
  Future<void> registerUser({
    required String phoneNumber,
    required String name,
    required int age,
    required int experience,
    required String location,
  }) async {
    // Save to Firestore
    await _firestore.collection('users').doc(phoneNumber).set({
      'phoneNumber': phoneNumber,
      'customerId': 'C-576DF782F1F24FD',
      'name': name,
      'age': age,
      'experience': experience,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Save to SharedPreferences for offline access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setInt('user_experience', experience);
    await prefs.setString('user_location', location);
  }

  @override
  Future<bool> isUserRegistered(String phoneNumber) async {
    final doc = await _firestore.collection('users').doc(phoneNumber).get();
    return doc.exists;
  }

  @override
  Future<void> login(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phoneNumber);

    // Fetch user data from Firestore and store locally
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      if (doc.exists) {
        final data = doc.data()!;
        await prefs.setString('user_name', data['name'] ?? '');
        await prefs.setInt('user_age', data['age'] ?? 0);
        await prefs.setInt('user_experience', data['experience'] ?? 0);
        await prefs.setString('user_location', data['location'] ?? '');
        if (data.containsKey('profilePicUrl')) {
          await prefs.setString('profile_pic_url', data['profilePicUrl']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data during login: $e");
      // Continue anyway - user might be offline
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_phone');
  }

  @override
  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone');
  }

  @override
  Future<void> saveVerifiedPhone(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verified_phone', phoneNumber);
  }

  @override
  Future<String?> getVerifiedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('verified_phone');
  }

  @override
  Future<void> clearVerifiedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('verified_phone');
  }
}
