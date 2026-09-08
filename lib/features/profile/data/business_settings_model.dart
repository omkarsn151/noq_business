import 'package:flutter/material.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';

/// The Operations settings behind the Business Settings screen - the slot grid,
/// the booking policy and the week of opening hours.
class BusinessSettingsModel {
  final int blockMinutes;
  final int bufferMinutes;
  final int bookingLimitPerSlot;
  final int bookingWindowDays;
  final int cancellationCutoffHours;

  /// Sent and returned as a decimal string on the wire; the form edits it as a
  /// whole percent, so it is rounded on the way in.
  final int lateCancellationFeePercent;
  final bool autoApproveEnabled;

  /// Seven days once Operations has been saved, Sunday first (`day_of_week` 0).
  final List<BusinessHourModel> hours;

  const BusinessSettingsModel({
    this.blockMinutes = 0,
    this.bufferMinutes = 0,
    this.bookingLimitPerSlot = 0,
    this.bookingWindowDays = 0,
    this.cancellationCutoffHours = 0,
    this.lateCancellationFeePercent = 0,
    this.autoApproveEnabled = false,
    this.hours = const [],
  });

  factory BusinessSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return BusinessSettingsModel(
      blockMinutes: (data['block_minutes'] as num?)?.toInt() ?? 0,
      bufferMinutes: (data['buffer_minutes'] as num?)?.toInt() ?? 0,
      bookingLimitPerSlot:
          (data['booking_limit_per_slot'] as num?)?.toInt() ?? 0,
      bookingWindowDays: (data['booking_window_days'] as num?)?.toInt() ?? 0,
      cancellationCutoffHours:
          (data['cancellation_cutoff_hours'] as num?)?.toInt() ?? 0,
      lateCancellationFeePercent:
          double.tryParse(
            data['late_cancellation_fee_percent']?.toString() ?? '',
          )?.round() ??
          0,
      autoApproveEnabled: data['auto_approve_enabled'] as bool? ?? false,
      hours: (data['hours'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BusinessHourModel.fromJson)
          .toList(),
    );
  }

  /// The settings screen shares one window across every working day, so these
  /// getters collapse the week back down for the form - the inverse of the
  /// per-day list the API is sent.
  Set<int> get workingDays => hours
      .where((hour) => !hour.isClosed)
      .map((hour) => hour.dayOfWeek)
      .toSet();

  BusinessHourModel? get _firstOpenDay {
    for (final hour in hours) {
      if (!hour.isClosed) return hour;
    }
    return null;
  }

  TimeOfDay? get opensAt => _firstOpenDay?.opensAt;

  TimeOfDay? get closesAt => _firstOpenDay?.closesAt;

  TimeOfDay? get breakStart => _firstOpenDay?.breakStart;

  TimeOfDay? get breakEnd => _firstOpenDay?.breakEnd;
}
