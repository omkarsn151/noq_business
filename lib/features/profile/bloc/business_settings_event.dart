import 'package:equatable/equatable.dart';
import 'package:noq_business/features/business_setup/data/business_hour_model.dart';

abstract class BusinessSettingsEvent extends Equatable {
  const BusinessSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the saved Operations settings to pre-fill the form.
class BusinessSettingsRequested extends BusinessSettingsEvent {
  const BusinessSettingsRequested();
}

class BusinessSettingsSaveRequested extends BusinessSettingsEvent {
  final int blockMinutes;
  final int bufferMinutes;
  final int bookingLimitPerSlot;
  final int bookingWindowDays;
  final int cancellationCutoffHours;
  final int lateCancellationFeePercent;
  final bool autoApproveEnabled;
  final List<BusinessHourModel> hours;

  const BusinessSettingsSaveRequested({
    required this.blockMinutes,
    required this.bufferMinutes,
    required this.bookingLimitPerSlot,
    required this.bookingWindowDays,
    required this.cancellationCutoffHours,
    required this.lateCancellationFeePercent,
    required this.autoApproveEnabled,
    required this.hours,
  });

  @override
  List<Object?> get props => [
    blockMinutes,
    bufferMinutes,
    bookingLimitPerSlot,
    bookingWindowDays,
    cancellationCutoffHours,
    lateCancellationFeePercent,
    autoApproveEnabled,
    hours,
  ];
}
