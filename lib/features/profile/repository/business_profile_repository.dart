import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';

class BusinessProfileRepository {
  final DioClient _dioClient;

  BusinessProfileRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// The whole Business Profile screen in one read call - header, stats,
  /// reviews, services, gallery and verification.
  Future<BusinessOverviewModel> getBusinessOverview() async {
    final response = await _dioClient.get(ApiEndpoints.getBusinessOverview);
    return BusinessOverviewModel.fromJson(response.data as Map<String, dynamic>);
  }
}
