import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/core/enums/business_status.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';
import 'package:noq_business/features/business_setup/bloc/submit_review_event.dart';
import 'package:noq_business/features/business_setup/bloc/submit_review_state.dart';
import 'package:noq_business/features/business_setup/repository/business_setup_repository.dart';

class SubmitReviewBloc extends Bloc<SubmitReviewEvent, SubmitReviewState> {
  final BusinessSetupRepository _repository;

  SubmitReviewBloc(this._repository) : super(const SubmitReviewInitial()) {
    on<SubmitReviewSubmitted>(_onSubmitReviewSubmitted);
  }

  Future<void> _onSubmitReviewSubmitted(
    SubmitReviewSubmitted event,
    Emitter<SubmitReviewState> emit,
  ) async {
    emit(const SubmitReviewLoading());
    try {
      await _repository.submitForReview(
        blockMinutes: event.blockMinutes,
        bufferMinutes: event.bufferMinutes,
        bookingLimitPerSlot: event.bookingLimitPerSlot,
        bookingWindowDays: event.bookingWindowDays,
        cancellationCutoffHours: event.cancellationCutoffHours,
        lateCancellationFeePercent: event.lateCancellationFeePercent,
        autoApproveEnabled: event.autoApproveEnabled,
      );
      await SecureStorageService().saveBusinessStatus(
        BusinessStatus.underReview,
      );
      emit(const SubmitReviewSuccess());
    } on ApiException catch (e) {
      emit(SubmitReviewFailure(message: e.message));
    } catch (e) {
      emit(SubmitReviewFailure(message: e.toString()));
    }
  }
}
