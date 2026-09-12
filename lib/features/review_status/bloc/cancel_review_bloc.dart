import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/review_status/bloc/cancel_review_event.dart';
import 'package:noq_business/features/review_status/bloc/cancel_review_state.dart';
import 'package:noq_business/features/review_status/repository/review_status_repository.dart';

class CancelReviewBloc extends Bloc<CancelReviewEvent, CancelReviewState> {
  final ReviewStatusRepository _repository;

  CancelReviewBloc(this._repository) : super(const CancelReviewInitial()) {
    on<CancelReviewRequested>(_onCancelReviewRequested);
  }

  Future<void> _onCancelReviewRequested(
    CancelReviewRequested event,
    Emitter<CancelReviewState> emit,
  ) async {
    emit(const CancelReviewLoading());
    try {
      await _repository.cancelReview();
      emit(const CancelReviewSuccess());
      // Reset so a second cancel in the same app session still triggers the
      // success listener. This bloc lives for the whole app lifetime and is
      // never disposed on logout.
      emit(const CancelReviewInitial());
    } on ApiException catch (e) {
      emit(CancelReviewFailure(message: e.message));
    } catch (e) {
      emit(CancelReviewFailure(message: e.toString()));
    }
  }
}
