import 'package:equatable/equatable.dart';

abstract class AddStaffState extends Equatable {
  const AddStaffState();

  @override
  List<Object?> get props => [];
}

class AddStaffInitial extends AddStaffState {
  const AddStaffInitial();
}

class AddStaffLoading extends AddStaffState {
  const AddStaffLoading();
}

class AddStaffSuccess extends AddStaffState {
  const AddStaffSuccess();
}

class AddStaffFailure extends AddStaffState {
  final String message;

  const AddStaffFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
