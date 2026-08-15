import 'package:equatable/equatable.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class StaffSuccess extends StaffState {
  final List<StaffModel> staff;

  const StaffSuccess({required this.staff});

  @override
  List<Object?> get props => [staff];
}

class StaffFailure extends StaffState {
  final String message;

  const StaffFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
