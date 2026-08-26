import 'package:equatable/equatable.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';

abstract class CreatePromotionEvent extends Equatable {
  const CreatePromotionEvent();

  @override
  List<Object?> get props => [];
}

class CreatePromotionSubmitted extends CreatePromotionEvent {
  final String code;
  final String title;
  final String? description;
  final String? bannerUploadId;
  final DiscountType discountType;
  final num discountValue;
  final num? minBookingAmount;
  final num? maxDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? totalRedemptionLimit;
  final int? perCustomerLimit;

  /// True publishes the promo, false saves it as a draft.
  final bool publish;

  const CreatePromotionSubmitted({
    required this.code,
    required this.title,
    this.description,
    this.bannerUploadId,
    required this.discountType,
    required this.discountValue,
    this.minBookingAmount,
    this.maxDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    this.totalRedemptionLimit,
    this.perCustomerLimit,
    required this.publish,
  });

  @override
  List<Object?> get props => [
    code,
    title,
    description,
    bannerUploadId,
    discountType,
    discountValue,
    minBookingAmount,
    maxDiscountAmount,
    validFrom,
    validUntil,
    totalRedemptionLimit,
    perCustomerLimit,
    publish,
  ];
}
