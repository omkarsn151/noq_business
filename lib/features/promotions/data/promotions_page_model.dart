import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/promotions/data/promotion_counts.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';

/// One page of promotions plus the meta returned alongside it.
class PromotionsPageModel {
  final List<PromotionModel> promotions;
  final PaginationModel pagination;
  final PromotionCounts counts;

  const PromotionsPageModel({
    required this.promotions,
    required this.pagination,
    required this.counts,
  });

  factory PromotionsPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final meta = json['meta'] as Map<String, dynamic>?;

    return PromotionsPageModel(
      promotions: (data?['promos'] as List? ?? [])
          .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        meta?['pagination'] as Map<String, dynamic>?,
      ),
      counts: PromotionCounts.fromJson(meta?['counts'] as Map<String, dynamic>?),
    );
  }
}
