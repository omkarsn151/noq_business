import 'package:equatable/equatable.dart';

abstract class AddServiceState extends Equatable {
  const AddServiceState();

  @override
  List<Object?> get props => [];
}

class AddServiceInitial extends AddServiceState {
  const AddServiceInitial();
}

class AddServiceLoading extends AddServiceState {
  const AddServiceLoading();
}

class AddServiceSuccess extends AddServiceState {
  const AddServiceSuccess();
}

class AddServiceFailure extends AddServiceState {
  final String message;

  const AddServiceFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
