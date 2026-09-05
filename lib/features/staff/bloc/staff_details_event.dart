import 'package:equatable/equatable.dart';

abstract class StaffDetailsEvent extends Equatable {
  const StaffDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the profile. Fired when the screen opens, on pull-to-refresh, on
/// retry, and again after returning from the edit screen.
class StaffDetailsRequested extends StaffDetailsEvent {
  final String staffId;

  const StaffDetailsRequested({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}

/// Flips the Active switch in the header. [isActive] is the value the owner
/// asked for, not the current one.
class StaffActiveToggled extends StaffDetailsEvent {
  final String staffId;
  final bool isActive;

  const StaffActiveToggled({required this.staffId, required this.isActive});

  @override
  List<Object?> get props => [staffId, isActive];
}
