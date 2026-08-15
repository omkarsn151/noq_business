import 'package:equatable/equatable.dart';

abstract class RequestOtpState extends Equatable {
  const RequestOtpState();

  @override
  List<Object?> get props => [];
}

class RequestOtpInitial extends RequestOtpState {
  const RequestOtpInitial();
}

class RequestOtpLoading extends RequestOtpState {
  const RequestOtpLoading();
}

class RequestOtpSuccess extends RequestOtpState {
  final String expiresAt;
  final String phone;

  const RequestOtpSuccess({required this.expiresAt, required this.phone});

  @override
  List<Object?> get props => [expiresAt, phone];
}

class RequestOtpFailure extends RequestOtpState {
  final String message;

  const RequestOtpFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
