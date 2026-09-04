import 'package:equatable/equatable.dart';

abstract class TodaysBookingsEvent extends Equatable {
  const TodaysBookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the strip. Fired when the Walk In screen opens, on pull-to-refresh,
/// and again after a walk-in is added.
class TodaysBookingsRequested extends TodaysBookingsEvent {
  const TodaysBookingsRequested();
}
