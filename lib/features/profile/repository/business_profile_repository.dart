import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/data/business_settings_model.dart';

class BusinessProfileRepository {
  final DioClient _dioClient;

  BusinessProfileRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// The whole Business Profile screen in one read call - header, stats,
  /// reviews, services, gallery and verification.
  Future<BusinessOverviewModel> getBusinessOverview() async {
    final response = await _dioClient.get(ApiEndpoints.getBusinessOverview);
    return BusinessOverviewModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// The Operations settings that pre-fill the Business Settings screen.
  Future<BusinessSettingsModel> getBusinessSettings() async {
    final response = await _dioClient.get(ApiEndpoints.getBusinessSettings);
    return BusinessSettingsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// The whole form goes up on every save, so this partial-update endpoint is
  /// handed all eight fields and the full seven-day week. The response carries
  /// the saved settings back, which is what the screen re-seeds from, next to
  /// the message the screen shows in its snackbar.
  Future<({BusinessSettingsModel settings, String message})>
  updateBusinessSettings({
    required int blockMinutes,
    required int bufferMinutes,
    required int bookingLimitPerSlot,
    required int bookingWindowDays,
    required int cancellationCutoffHours,
    required int lateCancellationFeePercent,
    required bool autoApproveEnabled,
    required List<BusinessHourModel> hours,
  }) async {
    final response = await _dioClient.patch(
      ApiEndpoints.updateBusinessSettings,
      data: {
        'block_minutes': blockMinutes,
        'buffer_minutes': bufferMinutes,
        'booking_limit_per_slot': bookingLimitPerSlot,
        'booking_window_days': bookingWindowDays,
        'cancellation_cutoff_hours': cancellationCutoffHours,
        // The API reads and writes this one as a decimal string.
        'late_cancellation_fee_percent': lateCancellationFeePercent.toString(),
        'auto_approve_enabled': autoApproveEnabled,
        'hours': hours.map((hour) => hour.toJson()).toList(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (
      settings: BusinessSettingsModel.fromJson(data),
      message: data['message'] as String? ?? '',
    );
  }
}
