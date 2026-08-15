import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class ServicesRequested extends ServiceEvent {
  const ServicesRequested();
}

class ServiceDeleteRequested extends ServiceEvent {
  final String serviceId;

  const ServiceDeleteRequested({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}
