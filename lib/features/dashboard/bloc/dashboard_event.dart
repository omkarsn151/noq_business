import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardRequested extends DashboardEvent {
  /// Set on a pull to refresh, so the loaded content stays on screen while the
  /// new payload is fetched.
  final bool refresh;

  const DashboardRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}
