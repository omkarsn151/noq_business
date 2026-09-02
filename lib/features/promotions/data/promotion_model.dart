import 'package:noq_business/features/promotions/data/promotion_status.dart';

enum DiscountType {
  percent('percent'),
  flat('flat');

  final String value;

  const DiscountType(this.value);

  static DiscountType fromValue(String? value) {
    return DiscountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DiscountType.percent,
    );
  }
}

class PromotionDiscount {
  final DiscountType type;
  final String value;

  /// Only returned by the promo details endpoint.
  final String? minBookingAmount;
  final String? maxDiscountAmount;

  const PromotionDiscount({
    required this.type,
    required this.value,
    this.minBookingAmount,
    this.maxDiscountAmount,
  });

  factory PromotionDiscount.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PromotionDiscount(type: DiscountType.percent, value: '0');
    }
    return PromotionDiscount(
      type: DiscountType.fromValue(json['type'] as String?),
      value: json['value']?.toString() ?? '0',
      minBookingAmount: json['min_booking_amount']?.toString(),
      maxDiscountAmount: json['max_discount_amount']?.toString(),
    );
  }

  /// '15%' for a percent discount, '₹15' for a flat one.
  String get label =>
      type == DiscountType.percent ? '$value%' : '\u20B9$value';
}

class PromotionValidity {
  final DateTime? from;
  final DateTime? until;

  const PromotionValidity({this.from, this.until});

  factory PromotionValidity.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PromotionValidity();
    return PromotionValidity(
      from: DateTime.tryParse(json['from']?.toString() ?? ''),
      until: DateTime.tryParse(json['until']?.toString() ?? ''),
    );
  }
}

class PromotionBanner {
  final String id;
  final String url;
  final String? fileName;

  const PromotionBanner({required this.id, required this.url, this.fileName});

  static PromotionBanner? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PromotionBanner(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileName: json['file_name']?.toString(),
    );
  }
}

class PromotionStats {
  final int usedByCustomers;
  final int totalRedemptions;

  const PromotionStats({this.usedByCustomers = 0, this.totalRedemptions = 0});

  factory PromotionStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PromotionStats();
    return PromotionStats(
      usedByCustomers: (json['used_by_customers'] as num?)?.toInt() ?? 0,
      totalRedemptions: (json['total_redemptions'] as num?)?.toInt() ?? 0,
    );
  }
}

class PromotionModel {
  final String id;
  final String code;
  final String title;
  final PromotionDiscount discount;
  final PromotionValidity validity;
  final PromotionStatus status;
  final bool isActive;
  final PromotionBanner? banner;
  final PromotionStats stats;
  final DateTime? createdAt;

  const PromotionModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discount,
    required this.validity,
    required this.status,
    required this.isActive,
    this.banner,
    this.stats = const PromotionStats(),
    this.createdAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    final validity = PromotionValidity.fromJson(
      json['validity'] as Map<String, dynamic>?,
    );
    final isActive = json['is_active'] as bool? ?? false;
    return PromotionModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      discount: PromotionDiscount.fromJson(
        json['discount'] as Map<String, dynamic>?,
      ),
      validity: validity,
      status: resolvePromotionStatus(
        rawStatus: json['status'] as String?,
        isActive: isActive,
        validUntil: validity.until,
      ),
      isActive: isActive,
      banner: PromotionBanner.fromJson(json['banner'] as Map<String, dynamic>?),
      stats: PromotionStats.fromJson(json['stats'] as Map<String, dynamic>?),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
