import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';

class RequestOtpRepository {
  final DioClient _dioClient;

  RequestOtpRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<String> requestOtp(String phone) async {
    final response = await _dioClient.post(
      ApiEndpoints.requestOtp,
      data: {'phone': phone},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return data['expires_at'] as String;
  }
}
