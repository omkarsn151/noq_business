import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/service/bloc/add_service_event.dart';
import 'package:noq_business/features/service/bloc/add_service_state.dart';
import 'package:noq_business/features/service/repository/service_repository.dart';

class AddServiceBloc extends Bloc<AddServiceEvent, AddServiceState> {
  final ServiceRepository _repository;

  AddServiceBloc(this._repository) : super(const AddServiceInitial()) {
    on<AddServiceSubmitted>(_onAddServiceSubmitted);
    on<EditServiceSubmitted>(_onEditServiceSubmitted);
  }

  Future<void> _onAddServiceSubmitted(
    AddServiceSubmitted event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(const AddServiceLoading());
    try {
      await _repository.addService(
        name: event.name,
        durationMinutes: event.durationMinutes,
        price: event.price,
        subCategoryId: event.subCategoryId,
        description: event.description,
        isActive: event.isActive,
        thumbnailIds: event.thumbnailIds,
        bannerIds: event.bannerIds,
      );
      emit(const AddServiceSuccess());
    } on ApiException catch (e) {
      emit(AddServiceFailure(message: e.message));
    } catch (e) {
      emit(AddServiceFailure(message: e.toString()));
    }
  }

  Future<void> _onEditServiceSubmitted(
    EditServiceSubmitted event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(const AddServiceLoading());
    try {
      await _repository.editService(
        id: event.serviceId,
        name: event.name,
        durationMinutes: event.durationMinutes,
        price: event.price,
        subCategoryId: event.subCategoryId,
        description: event.description,
        isActive: event.isActive,
        thumbnailIds: event.thumbnailIds,
        bannerIds: event.bannerIds,
      );
      emit(const AddServiceSuccess());
    } on ApiException catch (e) {
      emit(AddServiceFailure(message: e.message));
    } catch (e) {
      emit(AddServiceFailure(message: e.toString()));
    }
  }
}
