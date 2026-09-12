import 'package:equatable/equatable.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';

abstract class BookingActionState extends Equatable {
  const BookingActionState();

  @override
  List<Object?> get props => [];
}

class BookingActionInitial extends BookingActionState {
  const BookingActionInitial();
}

/// An action is in flight. [bookingId] lets a list show the spinner on the one
/// row that was tapped.
class BookingActionInProgress extends BookingActionState {
  final String bookingId;
  final BookingAction action;

  const BookingActionInProgress({
    required this.bookingId,
    required this.action,
  });

  @override
  List<Object?> get props => [bookingId, action];
}

class BookingActionSuccess extends BookingActionState {
  final String bookingId;
  final BookingAction action;

  /// Server copy for the snackbar.
  final String message;

  const BookingActionSuccess({
    required this.bookingId,
    required this.action,
    required this.message,
  });

  @override
  List<Object?> get props => [bookingId, action, message];
}

class BookingActionFailure extends BookingActionState {
  final String message;

  const BookingActionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
