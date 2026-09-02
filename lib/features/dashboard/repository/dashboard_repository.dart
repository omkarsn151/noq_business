import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/dashboard/data/dashboard_model.dart';

class DashboardRepository {
  final DioClient _dioClient;

  DashboardRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// The whole dashboard in one read call - header, summary, staff row and
  /// upcoming bookings.
  Future<DashboardModel> getDashboard() async {
    final response = await _dioClient.get(ApiEndpoints.getDashboard);
    return DashboardModel.fromJson(response.data as Map<String, dynamic>);
  }
}
