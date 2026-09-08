import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/profile/bloc/business_settings_event.dart';
import 'package:noq_business/features/profile/bloc/business_settings_state.dart';
import 'package:noq_business/features/profile/repository/business_profile_repository.dart';

class BusinessSettingsBloc
    extends Bloc<BusinessSettingsEvent, BusinessSettingsState> {
  final BusinessProfileRepository _repository;

  BusinessSettingsBloc(this._repository)
    : super(const BusinessSettingsState()) {
    on<BusinessSettingsRequested>(_onRequested);
    on<BusinessSettingsSaveRequested>(_onSaveRequested);
  }

  Future<void> _onRequested(
    BusinessSettingsRequested event,
    Emitter<BusinessSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BusinessSettingsStatus.loading,
        message: '',
        saveStatus: BusinessSettingsSaveStatus.idle,
        saveMessage: '',
      ),
    );

    try {
      final model = await _repository.getBusinessSettings();
      emit(
        state.copyWith(status: BusinessSettingsStatus.success, model: model),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BusinessSettingsStatus.failure,
          message: _messageOf(e),
        ),
      );
    }
  }

  Future<void> _onSaveRequested(
    BusinessSettingsSaveRequested event,
    Emitter<BusinessSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        saveStatus: BusinessSettingsSaveStatus.saving,
        saveMessage: '',
      ),
    );

    try {
      // The endpoint answers with the saved settings, so the form re-seeds from
      // the server rather than from what was typed.
      final result = await _repository.updateBusinessSettings(
        blockMinutes: event.blockMinutes,
        bufferMinutes: event.bufferMinutes,
        bookingLimitPerSlot: event.bookingLimitPerSlot,
        bookingWindowDays: event.bookingWindowDays,
        cancellationCutoffHours: event.cancellationCutoffHours,
        lateCancellationFeePercent: event.lateCancellationFeePercent,
        autoApproveEnabled: event.autoApproveEnabled,
        hours: event.hours,
      );
      emit(
        state.copyWith(
          saveStatus: BusinessSettingsSaveStatus.success,
          model: result.settings,
          saveMessage: result.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: BusinessSettingsSaveStatus.failure,
          saveMessage: _messageOf(e),
        ),
      );
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
