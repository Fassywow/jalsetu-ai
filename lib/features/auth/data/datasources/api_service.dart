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
          'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLTU3NkRGNzgyRjFGMjRGRCIsImlhdCI6MTc2ODgzMjUyMywiZXhwIjoxOTI2NTEyNTIzfQ.opPyJ745vxB3RUqRc2MrmP0OsCEIxaTs5BSxITJiQB4pnF7PXL4p8sV70ZB9EJuRgBBdLh-K7iOdIpRIDrrclQ'
    };
  }

  Future<Response> sendOTP(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/verification/v3/send',
        queryParameters: {
          'countryCode': '91',
          'customerId': 'C-576DF782F1F24FD',
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
          'customerId': 'C-576DF782F1F24FD',
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
