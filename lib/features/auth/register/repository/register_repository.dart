import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';

class RegisterRepository {
  final DioClient _dioClient;

  RegisterRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<void> updateName(String fullName) async {
    await _dioClient.patch(
      ApiEndpoints.updateName,
      data: {'full_name': fullName},
    );
  }
}
