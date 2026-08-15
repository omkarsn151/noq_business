import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/business/data/business_model.dart';

class BusinessRepository {
  final DioClient _dioClient;

  BusinessRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<BusinessModel> getBusiness() async {
    final response = await _dioClient.get(ApiEndpoints.getBusinessData);
    final data = response.data['data'] as Map<String, dynamic>;
    return BusinessModel.fromJson(data);
  }
}
