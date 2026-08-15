import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class StaffRequested extends StaffEvent {
  const StaffRequested();
}

class StaffDeleteRequested extends StaffEvent {
  final String staffId;

  const StaffDeleteRequested({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}
