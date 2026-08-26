import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';

class PromotionLimits {
  final int totalRedemptionLimit;
  final int perCustomerLimit;

  const PromotionLimits({
    this.totalRedemptionLimit = 0,
    this.perCustomerLimit = 0,
  });

  factory PromotionLimits.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PromotionLimits();
    return PromotionLimits(
      totalRedemptionLimit:
          (json['total_redemption_limit'] as num?)?.toInt() ?? 0,
      perCustomerLimit: (json['per_customer_limit'] as num?)?.toInt() ?? 0,
    );
  }
}

class PromotionPerformance {
  final int usedByCustomers;
  final int totalBookings;
  final String conversionRate;
  final String totalDiscountGiven;

  const PromotionPerformance({
    this.usedByCustomers = 0,
    this.totalBookings = 0,
    this.conversionRate = '0',
    this.totalDiscountGiven = '0',
  });

  factory PromotionPerformance.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PromotionPerformance();
    return PromotionPerformance(
      usedByCustomers: (json['used_by_customers'] as num?)?.toInt() ?? 0,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      conversionRate: json['conversion_rate']?.toString() ?? '0',
      totalDiscountGiven: json['total_discount_given']?.toString() ?? '0',
    );
  }
}

/// A single promo with the extra fields the details endpoint returns on top of
/// what the list gives back.
class PromotionDetailModel {
  final String id;
  final String code;
  final String title;
  final String? description;
  final PromotionBanner? banner;
  final PromotionDiscount discount;
  final PromotionValidity validity;
  final PromotionLimits limits;
  final PromotionStatus status;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PromotionDetailModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.banner,
    required this.discount,
    required this.validity,
    this.limits = const PromotionLimits(),
    required this.status,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PromotionDetailModel.fromJson(Map<String, dynamic> json) {
    return PromotionDetailModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      banner: PromotionBanner.fromJson(json['banner'] as Map<String, dynamic>?),
      discount: PromotionDiscount.fromJson(
        json['discount'] as Map<String, dynamic>?,
      ),
      validity: PromotionValidity.fromJson(
        json['validity'] as Map<String, dynamic>?,
      ),
      limits: PromotionLimits.fromJson(json['limits'] as Map<String, dynamic>?),
      status: PromotionStatus.fromValue(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class PromotionDetailsModel {
  final PromotionDetailModel promo;
  final PromotionPerformance performance;

  const PromotionDetailsModel({
    required this.promo,
    required this.performance,
  });

  factory PromotionDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return PromotionDetailsModel(
      promo: PromotionDetailModel.fromJson(
        data['promo'] as Map<String, dynamic>? ?? const {},
      ),
      performance: PromotionPerformance.fromJson(
        data['performance'] as Map<String, dynamic>?,
      ),
    );
  }
}
