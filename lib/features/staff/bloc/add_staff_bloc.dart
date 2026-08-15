import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/staff/bloc/add_staff_event.dart';
import 'package:noq_business/features/staff/bloc/add_staff_state.dart';
import 'package:noq_business/features/staff/repository/staff_repository.dart';

class AddStaffBloc extends Bloc<AddStaffEvent, AddStaffState> {
  final StaffRepository _repository;

  AddStaffBloc(this._repository) : super(const AddStaffInitial()) {
    on<AddStaffSubmitted>(_onAddStaffSubmitted);
    on<EditStaffSubmitted>(_onEditStaffSubmitted);
  }

  Future<void> _onAddStaffSubmitted(
    AddStaffSubmitted event,
    Emitter<AddStaffState> emit,
  ) async {
    emit(const AddStaffLoading());
    try {
      await _repository.addStaff(
        name: event.name,
        photoId: event.photoId,
        worksFrom: event.worksFrom,
        worksTo: event.worksTo,
        breakStart: event.breakStart,
        breakEnd: event.breakEnd,
        isActive: event.isActive,
        serviceIds: event.serviceIds,
      );
      emit(const AddStaffSuccess());
    } on ApiException catch (e) {
      emit(AddStaffFailure(message: e.message));
    } catch (e) {
      emit(AddStaffFailure(message: e.toString()));
    }
  }

  Future<void> _onEditStaffSubmitted(
    EditStaffSubmitted event,
    Emitter<AddStaffState> emit,
  ) async {
    emit(const AddStaffLoading());
    try {
      await _repository.editStaff(
        id: event.staffId,
        name: event.name,
        photoId: event.photoId,
        worksFrom: event.worksFrom,
        worksTo: event.worksTo,
        breakStart: event.breakStart,
        breakEnd: event.breakEnd,
        isActive: event.isActive,
        serviceIds: event.serviceIds,
      );
      emit(const AddStaffSuccess());
    } on ApiException catch (e) {
      emit(AddStaffFailure(message: e.message));
    } catch (e) {
      emit(AddStaffFailure(message: e.toString()));
    }
  }
}
