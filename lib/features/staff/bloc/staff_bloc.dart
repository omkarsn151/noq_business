import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/staff/bloc/staff_event.dart';
import 'package:noq_business/features/staff/bloc/staff_state.dart';
import 'package:noq_business/features/staff/repository/staff_repository.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _repository;

  StaffBloc(this._repository) : super(const StaffInitial()) {
    on<StaffRequested>(_onStaffRequested);
    on<StaffDeleteRequested>(_onStaffDeleteRequested);
  }

  Future<void> _onStaffRequested(
    StaffRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      final staff = await _repository.getStaff();
      emit(StaffSuccess(staff: staff));
    } on ApiException catch (e) {
      emit(StaffFailure(message: e.message));
    } catch (e) {
      emit(StaffFailure(message: e.toString()));
    }
  }

  Future<void> _onStaffDeleteRequested(
    StaffDeleteRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      await _repository.deleteStaff(event.staffId);
      final staff = await _repository.getStaff();
      emit(StaffSuccess(staff: staff));
    } on ApiException catch (e) {
      emit(StaffFailure(message: e.message));
    } catch (e) {
      emit(StaffFailure(message: e.toString()));
    }
  }
}
