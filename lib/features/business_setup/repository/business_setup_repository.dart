import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';

class BusinessSetupRepository {
  final DioClient _dioClient;

  BusinessSetupRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<void> createBusiness({
    required String name,
    required String categoryId,
    required String addressLine,
    required String city,
    required String state,
    required String postalCode,
    required String description,
    required String gstNumber,
    required List<String> documentIds,
    required List<String> thumbnailUploadIds,
  }) async {
    await _dioClient.put(
      ApiEndpoints.createBusinesses,
      data: {
        'name': name,
        'category_id': categoryId,
        'currency_code': 'INR',
        'description': description,
        'address_line': addressLine,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'gst_number': gstNumber,
        'document_ids': documentIds,
        'thumbnail_upload_ids': thumbnailUploadIds,
      },
    );
  }

  Future<void> submitForReview({
    required int blockMinutes,
    required int bufferMinutes,
    required int bookingLimitPerSlot,
    required int bookingWindowDays,
    required int cancellationCutoffHours,
    required int lateCancellationFeePercent,
    required bool autoApproveEnabled,
  }) async {
    await _dioClient.post(
      ApiEndpoints.submitBusinessForReview,
      data: {
        'block_minutes': blockMinutes,
        'buffer_minutes': bufferMinutes,
        'booking_limit_per_slot': bookingLimitPerSlot,
        'booking_window_days': bookingWindowDays,
        'cancellation_cutoff_hours': cancellationCutoffHours,
        'late_cancellation_fee_percent': lateCancellationFeePercent,
        'auto_approve_enabled': autoApproveEnabled,
      },
    );
  }
}
