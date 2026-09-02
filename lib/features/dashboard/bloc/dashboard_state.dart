import 'package:equatable/equatable.dart';
import 'package:noq_business/features/dashboard/data/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardSuccess extends DashboardState {
  final DashboardModel dashboard;

  const DashboardSuccess({required this.dashboard});

  @override
  List<Object?> get props => [dashboard];
}

class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
