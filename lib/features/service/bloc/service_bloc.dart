import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/bloc/service_state.dart';
import 'package:noq_business/features/service/repository/service_repository.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _repository;

  ServiceBloc(this._repository) : super(const ServiceInitial()) {
    on<ServicesRequested>(_onServicesRequested);
    on<ServiceDeleteRequested>(_onServiceDeleteRequested);
  }

  Future<void> _onServicesRequested(
    ServicesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());
    try {
      final services = await _repository.getServices();
      emit(ServiceSuccess(services: services));
    } on ApiException catch (e) {
      emit(ServiceFailure(message: e.message));
    } catch (e) {
      emit(ServiceFailure(message: e.toString()));
    }
  }

  Future<void> _onServiceDeleteRequested(
    ServiceDeleteRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());
    try {
      await _repository.deleteService(event.serviceId);
      final services = await _repository.getServices();
      emit(ServiceSuccess(services: services));
    } on ApiException catch (e) {
      emit(ServiceFailure(message: e.message));
    } catch (e) {
      emit(ServiceFailure(message: e.toString()));
    }
  }
}
