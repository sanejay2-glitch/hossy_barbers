import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CloudinaryUploadService {
  const CloudinaryUploadService();

  static const _cloudName = 'hz4lgpzt';
  static const _uploadPreset = 'hossy_barbers_gallery';

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
    String? folder,
  }) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
            ),
          )
          ..fields['upload_preset'] = _uploadPreset
          ..fields.addAll({if (folder?.isNotEmpty == true) 'folder': folder!})
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename),
          );

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(seconds: 60));
      final body = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CloudinaryUploadException(
          body['error'] is Map
              ? body['error']['message'] as String? ??
                    'Cloudinary rejected the upload.'
              : 'Cloudinary rejected the upload.',
        );
      }
      final secureUrl = body['secure_url'] as String?;
      if (secureUrl == null || !secureUrl.startsWith('https://')) {
        throw const CloudinaryUploadException(
          'Cloudinary did not return a secure image URL.',
        );
      }
      return secureUrl;
    } on CloudinaryUploadException {
      rethrow;
    } on TimeoutException {
      throw const CloudinaryUploadException(
        'Image upload timed out. Check your connection and try again.',
      );
    } on Exception {
      throw const CloudinaryUploadException(
        'Image upload failed. Check your connection and try again.',
      );
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }
}
