import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/staff/bloc/staff_details_event.dart';
import 'package:noq_business/features/staff/bloc/staff_details_state.dart';
import 'package:noq_business/features/staff/repository/staff_repository.dart';

class StaffDetailsBloc extends Bloc<StaffDetailsEvent, StaffDetailsState> {
  final StaffRepository _repository;

  StaffDetailsBloc(this._repository) : super(const StaffDetailsState()) {
    on<StaffDetailsRequested>(_onStaffDetailsRequested);
    on<StaffActiveToggled>(_onStaffActiveToggled);
  }

  Future<void> _onStaffDetailsRequested(
    StaffDetailsRequested event,
    Emitter<StaffDetailsState> emit,
  ) async {
    emit(state.copyWith(status: StaffDetailsStatus.loading, message: ''));
    try {
      final profile = await _repository.getStaffDetails(event.staffId);
      emit(
        state.copyWith(status: StaffDetailsStatus.success, profile: profile),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StaffDetailsStatus.failure,
          message: _messageOf(e),
        ),
      );
    }
  }

  Future<void> _onStaffActiveToggled(
    StaffActiveToggled event,
    Emitter<StaffDetailsState> emit,
  ) async {
    final profile = state.profile;
    if (profile == null) return;

    // Move the switch straight away - the PATCH is a single boolean and the
    // owner should not watch a spinner for it.
    emit(
      state.copyWith(
        status: StaffDetailsStatus.success,
        profile: profile.withActive(event.isActive),
        isTogglingActive: true,
        message: '',
      ),
    );

    try {
      await _repository.setStaffActive(
        id: event.staffId,
        isActive: event.isActive,
      );
      emit(state.copyWith(isTogglingActive: false));
    } catch (e) {
      // Put the switch back where it was and let the screen surface why.
      emit(
        StaffDetailsState(
          status: StaffDetailsStatus.failure,
          profile: profile,
          message: _messageOf(e),
        ),
      );
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
