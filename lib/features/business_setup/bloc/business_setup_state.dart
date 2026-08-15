import 'package:equatable/equatable.dart';

abstract class BusinessSetupState extends Equatable {
  const BusinessSetupState();

  @override
  List<Object?> get props => [];
}

class BusinessSetupInitial extends BusinessSetupState {
  const BusinessSetupInitial();
}

class BusinessSetupLoading extends BusinessSetupState {
  const BusinessSetupLoading();
}

class BusinessSetupSuccess extends BusinessSetupState {
  const BusinessSetupSuccess();
}

class BusinessSetupFailure extends BusinessSetupState {
  final String message;

  const BusinessSetupFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
