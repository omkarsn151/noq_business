import 'package:equatable/equatable.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object?> get props => [];
}

class VerifyOtpSubmitted extends VerifyOtpEvent {
  final String phone;
  final String code;

  const VerifyOtpSubmitted({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}
