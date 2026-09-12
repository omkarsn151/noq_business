import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/review_status/data/review_status_model.dart';

class ReviewStatusRepository {
  final DioClient _dioClient;

  ReviewStatusRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<ReviewStatusModel> getReviewStatus() async {
    final response = await _dioClient.get(ApiEndpoints.getReviewStatus);
    final data = response.data['data'] as Map<String, dynamic>;
    return ReviewStatusModel.fromJson(data);
  }

  /// Takes the business out of review (`under_review` -> `draft`) so it can be
  /// edited again. Only legal while `actions.can_cancel_review` is true.
  Future<void> cancelReview() async {
    await _dioClient.post(ApiEndpoints.cancelReview);
  }
}
