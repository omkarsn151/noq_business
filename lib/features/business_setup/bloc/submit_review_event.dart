import 'package:equatable/equatable.dart';

abstract class SubmitReviewEvent extends Equatable {
  const SubmitReviewEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReviewSubmitted extends SubmitReviewEvent {
  final int blockMinutes;
  final int bufferMinutes;
  final int bookingLimitPerSlot;
  final int bookingWindowDays;
  final int cancellationCutoffHours;
  final int lateCancellationFeePercent;
  final bool autoApproveEnabled;

  const SubmitReviewSubmitted({
    required this.blockMinutes,
    required this.bufferMinutes,
    required this.bookingLimitPerSlot,
    required this.bookingWindowDays,
    required this.cancellationCutoffHours,
    required this.lateCancellationFeePercent,
    required this.autoApproveEnabled,
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
  ];
}
