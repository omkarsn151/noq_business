import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String fullName;

  const RegisterSubmitted({required this.fullName});

  @override
  List<Object?> get props => [fullName];
}
