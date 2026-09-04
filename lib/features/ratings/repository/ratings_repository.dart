import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/ratings/data/reviews_page_model.dart';

class RatingsRepository {
  static const int pageSize = 20;

  final DioClient _dioClient;

  RatingsRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// One page of the shop's customer reviews, newest first.
  Future<ReviewsPageModel> getReviews({
    int page = 1,
    int limit = pageSize,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getRatingsAndReviews,
      queryParameters: {'page': page, 'page_size': limit},
    );

    return ReviewsPageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
