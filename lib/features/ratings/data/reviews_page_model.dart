import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/ratings/data/review_model.dart';

/// One page of reviews plus the pagination meta returned alongside it.
class ReviewsPageModel {
  final List<ReviewModel> reviews;
  final PaginationModel pagination;

  const ReviewsPageModel({
    required this.reviews,
    required this.pagination,
  });

  factory ReviewsPageModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;

    return ReviewsPageModel(
      reviews: (json['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList(),
      pagination: PaginationModel.fromJson(
        meta?['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}
