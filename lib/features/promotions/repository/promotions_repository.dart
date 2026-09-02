import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/promotions/data/promotion_details_model.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';
import 'package:noq_business/features/promotions/data/promotions_page_model.dart';

class PromotionsRepository {
  static const int pageSize = 10;

  final DioClient _dioClient;

  PromotionsRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<PromotionsPageModel> getPromotions({
    required PromotionStatus status,
    int page = 1,
    int limit = pageSize,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getPromotions,
      queryParameters: {
        'tab': status.value,
        'page': page,
        'page_size': limit,
      },
    );

    return PromotionsPageModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PromotionDetailsModel> getPromotionDetails(String id) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.getPromotionDetails}$id',
    );

    return PromotionDetailsModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createPromotion({
    required String code,
    required String title,
    String? description,
    String? bannerUploadId,
    required DiscountType discountType,
    required num discountValue,
    num? minBookingAmount,
    num? maxDiscountAmount,
    required DateTime validFrom,
    required DateTime validUntil,
    int? totalRedemptionLimit,
    int? perCustomerLimit,
    required bool publish,
  }) async {
    await _dioClient.post(
      ApiEndpoints.createPromotion,
      data: {
        'code': code,
        'title': title,
        'description': ?description,
        'banner_upload_id': ?bannerUploadId,
        'discount_type': discountType.value,
        'discount_value': discountValue,
        'min_booking_amount': ?minBookingAmount,
        'max_discount_amount': ?maxDiscountAmount,
        'valid_from': validFrom.toUtc().toIso8601String(),
        'valid_until': validUntil.toUtc().toIso8601String(),
        'total_redemption_limit': ?totalRedemptionLimit,
        'per_customer_limit': ?perCustomerLimit,
        'publish': publish,
      },
    );
  }

  /// Full edit from the create/edit form. The optional fields are sent
  /// explicitly (not omitted) so clearing one in the form erases it
  /// server-side, matching how [ServiceRepository.editService] behaves.
  ///
  /// The code is read-only once a promo exists, so it is never part of this
  /// request.
  Future<void> updatePromotion({
    required String id,
    required String title,
    String? description,
    String? bannerUploadId,
    required DiscountType discountType,
    required num discountValue,
    num? minBookingAmount,
    num? maxDiscountAmount,
    required DateTime validFrom,
    required DateTime validUntil,
    int? totalRedemptionLimit,
    int? perCustomerLimit,
    bool? publish,
    bool? isActive,
  }) async {
    await _dioClient.put(
      '${ApiEndpoints.updatePromotion}$id',
      data: {
        'title': title,
        'description': description,
        'banner_upload_id': bannerUploadId,
        'discount_type': discountType.value,
        'discount_value': discountValue,
        'min_booking_amount': minBookingAmount,
        'max_discount_amount': maxDiscountAmount,
        'valid_from': validFrom.toUtc().toIso8601String(),
        'valid_until': validUntil.toUtc().toIso8601String(),
        'total_redemption_limit': totalRedemptionLimit,
        'per_customer_limit': perCustomerLimit,
        'publish': ?publish,
        'is_active': ?isActive,
      },
    );
  }

  /// Quick pause / resume / publish — sends only the touched keys so every
  /// other field keeps its stored value.
  Future<void> setPromotionState({
    required String id,
    bool? isActive,
    bool? publish,
  }) async {
    await _dioClient.put(
      '${ApiEndpoints.updatePromotion}$id',
      data: {
        'is_active': ?isActive,
        'publish': ?publish,
      },
    );
  }
}
