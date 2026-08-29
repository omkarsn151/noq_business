import 'package:equatable/equatable.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of [status]. Already loaded tabs are served from the
/// cached state unless [refresh] is set.
class BookingsRequested extends BookingsEvent {
  final BookingStatus status;
  final bool refresh;

  const BookingsRequested({required this.status, this.refresh = false});

  @override
  List<Object?> get props => [status, refresh];
}

/// Drops every cached tab and reloads [status]. Used after a booking changes
/// state, since that moves rows between tabs and changes the counts.
class BookingsRefreshRequested extends BookingsEvent {
  final BookingStatus status;

  const BookingsRefreshRequested({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Appends the next page of [status] to the already loaded bookings.
class BookingsNextPageRequested extends BookingsEvent {
  final BookingStatus status;

  const BookingsNextPageRequested({required this.status});

  @override
  List<Object?> get props => [status];
}
