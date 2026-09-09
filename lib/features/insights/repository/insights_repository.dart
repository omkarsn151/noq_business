import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';

class InsightsRepository {
  final DioClient _dioClient;

  InsightsRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// The whole Insights screen in one read call - header, hero cards, queue
  /// performance chart and the customer flow breakdown for [period].
  Future<InsightsModel> getInsights({
    InsightsPeriod period = InsightsPeriod.thisWeek,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getInsights,
      queryParameters: {'period': period.value},
    );
    return InsightsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
