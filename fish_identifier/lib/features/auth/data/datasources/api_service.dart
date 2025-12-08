import 'package:dio/dio.dart';
import 'dart:developer';

class ApiService {
  static const String baseUrl = 'https://cpaas.messagecentral.com';

  // Dio client for OTP API
  final Dio _dio;

  ApiService() : _dio = Dio() {
    // Initialize OTP client
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'authToken':
          'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLThEMDY2RDQ2RkI1RjRDMyIsImlhdCI6MTczNTE5ODQ0NCwiZXhwIjoxODkyODc4NDQ0fQ.9DDsWKugNq_aqJiksZgyL8sFK154EWnln59-cKkK9isijA0GsGdC7pEt0yoo9j7QF8KEw1ogSJMvn_mY_xky_Q'
    };
  }

  Future<Response> sendOTP(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/verification/v3/send',
        queryParameters: {
          'countryCode': '91',
          'customerId': 'C-8D066D46FB5F4C3',
          'flowType': 'SMS',
          'mobileNumber': phoneNumber,
        },
      );
      log('Send OTP Response: ${response.data}');
      return response;
    } catch (e) {
      log('API Error: $e');
      rethrow;
    }
  }

  Future<Response> verifyOTP(
      String phoneNumber, String otp, String verificationId) async {
    try {
      final response = await _dio.get(
        '/verification/v3/validateOtp',
        queryParameters: {
          'countryCode': '91',
          'customerId': 'C-8D066D46FB5F4C3',
          'mobileNumber': phoneNumber,
          'verificationId': verificationId,
          'code': otp,
        },
      );
      log('Verify OTP Response: ${response.data}');
      return response;
    } catch (e) {
      log('API Error: $e');
      rethrow;
    }
  }
}
