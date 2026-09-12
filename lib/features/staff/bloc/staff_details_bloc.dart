import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/staff/bloc/staff_details_event.dart';
import 'package:noq_business/features/staff/bloc/staff_details_state.dart';
import 'package:noq_business/features/staff/data/staff_profile_model.dart';
import 'package:noq_business/features/staff/repository/staff_repository.dart';

class StaffDetailsBloc extends Bloc<StaffDetailsEvent, StaffDetailsState> {
  final StaffRepository _repository;

  StaffDetailsBloc(this._repository) : super(const StaffDetailsInitial()) {
    on<StaffDetailsRequested>(_onStaffDetailsRequested);
    on<StaffActiveToggled>(_onStaffActiveToggled);
  }

  Future<void> _onStaffDetailsRequested(
    StaffDetailsRequested event,
    Emitter<StaffDetailsState> emit,
  ) async {
    emit(const StaffDetailsLoading());
    try {
      final profile = await _repository.getStaffDetails(event.staffId);
      emit(StaffDetailsSuccess(profile: profile));
    } on ApiException catch (e) {
      emit(StaffDetailsFailure(message: e.message));
    } catch (e) {
      emit(StaffDetailsFailure(message: e.toString()));
    }
  }

  Future<void> _onStaffActiveToggled(
    StaffActiveToggled event,
    Emitter<StaffDetailsState> emit,
  ) async {
    final profile = _profileOf(state);
    if (profile == null) return;

    // Move the switch straight away - the PATCH is a single boolean and the
    // owner should not watch a spinner for it.
    final optimistic = profile.withActive(event.isActive);
    emit(StaffDetailsSuccess(profile: optimistic, isTogglingActive: true));

    try {
      await _repository.setStaffActive(
        id: event.staffId,
        isActive: event.isActive,
      );
      emit(StaffDetailsSuccess(profile: optimistic));
    } catch (e) {
      // Put the switch back where it was and let the screen surface why.
      emit(StaffDetailsFailure(message: _messageOf(e), profile: profile));
    }
  }

  StaffProfileModel? _profileOf(StaffDetailsState state) {
    if (state is StaffDetailsSuccess) return state.profile;
    if (state is StaffDetailsFailure) return state.profile;
    return null;
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
