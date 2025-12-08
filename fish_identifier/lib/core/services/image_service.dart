import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  final Dio _dio = Dio();
  final String _uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
  // NOTE: In a production app, the private key should NEVER be stored on the client.
  // Uploads should be signed by a backend server.
  // Using private key here strictly as per user request for this specific implementation.
  final String _privateKey = 'private_S1zsD6d5OIkhWjf9+ZeZNVhUK7w=';

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'fileName': fileName,
        'useUniqueFileName': true,
        'folder': '/fish_detections', // Optional: organize in folder
      });

      // ImageKit API requires Basic Auth with private key as username and empty password
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}';

      Response response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': basicAuth,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'];
      } else {
        debugPrint(
            'Image upload failed: ${response.statusCode} - ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
