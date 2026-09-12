import 'package:equatable/equatable.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';

abstract class BookingActionEvent extends Equatable {
  const BookingActionEvent();

  @override
  List<Object?> get props => [];
}

/// Runs one action against one booking. Only the fields that belong to
/// [action] should be filled in - see [BookingAction].
class BookingActionRequested extends BookingActionEvent {
  final String bookingId;
  final BookingAction action;

  /// `reject` / `cancel` / `reject_reschedule` only. Null when the owner left
  /// it blank.
  final String? reason;

  /// `start` on an online booking only. Null for walk-ins.
  final String? verificationCode;

  /// `reschedule` only - the chip starts of the new run.
  final List<DateTime>? slots;

  /// `reschedule` only - the team member the owner picked. Null is 'Anyone'.
  final String? staffId;

  const BookingActionRequested({
    required this.bookingId,
    required this.action,
    this.reason,
    this.verificationCode,
    this.slots,
    this.staffId,
  });

  @override
  List<Object?> get props => [
    bookingId,
    action,
    reason,
    verificationCode,
    slots,
    staffId,
  ];
}
