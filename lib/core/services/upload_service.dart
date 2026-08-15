import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/core/models/upload_model.dart';

class UploadService {
  final DioClient _dioClient;

  UploadService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  String? validateSize(File file, {int maxBytes = maxFileSizeBytes}) {
    if (file.lengthSync() > maxBytes) {
      return 'File must be 5MB or smaller.';
    }
    return null;
  }

  Future<UploadModel> upload({
    required File file,
    required String purpose,
  }) async {
    final fileName = file.uri.pathSegments.last;
    final mimeType = lookupMimeType(file.path);

    final formData = FormData.fromMap({
      'purpose': purpose,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
    });
    print("purpose: $purpose");

    final response = await _dioClient.post(
      ApiEndpoints.upload,
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return UploadModel.fromJson(data);
  }

  Future<void> deleteUpload(String id) async {
    await _dioClient.delete('${ApiEndpoints.deleteUpload}$id');
  }
}
