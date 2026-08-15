import 'package:equatable/equatable.dart';
import 'package:noq_business/features/service/data/service_model.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceSuccess extends ServiceState {
  final List<ServiceModel> services;

  const ServiceSuccess({required this.services});

  @override
  List<Object?> get props => [services];
}

class ServiceFailure extends ServiceState {
  final String message;

  const ServiceFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
