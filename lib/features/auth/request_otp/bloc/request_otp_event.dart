import 'package:equatable/equatable.dart';

abstract class RequestOtpEvent extends Equatable {
  const RequestOtpEvent();

  @override
  List<Object?> get props => [];
}

class RequestOtpSubmitted extends RequestOtpEvent {
  final String phone;

  const RequestOtpSubmitted({required this.phone});

  @override
  List<Object?> get props => [phone];
}
