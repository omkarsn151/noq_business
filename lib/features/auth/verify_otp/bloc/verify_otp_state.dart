import 'package:equatable/equatable.dart';
import 'package:noq_business/core/enums/business_status.dart';

abstract class VerifyOtpState extends Equatable {
  const VerifyOtpState();

  @override
  List<Object?> get props => [];
}

class VerifyOtpInitial extends VerifyOtpState {
  const VerifyOtpInitial();
}

class VerifyOtpLoading extends VerifyOtpState {
  const VerifyOtpLoading();
}

class VerifyOtpSuccess extends VerifyOtpState {
  final String? fullName;
  final BusinessStatus? businessStatus;

  const VerifyOtpSuccess({this.fullName, this.businessStatus});

  @override
  List<Object?> get props => [fullName, businessStatus];
}

class VerifyOtpFailure extends VerifyOtpState {
  final String message;

  const VerifyOtpFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
