import 'package:noq_business/features/promotions/data/promotion_status.dart';

/// Per tab totals returned in `meta.counts`.
class PromotionCounts {
  final int active;
  final int expired;
  final int inactive;
  final int drafts;

  const PromotionCounts({
    this.active = 0,
    this.expired = 0,
    this.inactive = 0,
    this.drafts = 0,
  });

  factory PromotionCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PromotionCounts();
    return PromotionCounts(
      active: (json['active'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      inactive: (json['inactive'] as num?)?.toInt() ?? 0,
      drafts: (json['drafts'] as num?)?.toInt() ?? 0,
    );
  }

  int countFor(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.active:
        return active;
      case PromotionStatus.expired:
        return expired;
      case PromotionStatus.inactive:
        return inactive;
      case PromotionStatus.draft:
        return drafts;
    }
  }
}
