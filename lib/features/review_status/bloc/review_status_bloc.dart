import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/review_status/bloc/review_status_event.dart';
import 'package:noq_business/features/review_status/bloc/review_status_state.dart';
import 'package:noq_business/features/review_status/repository/review_status_repository.dart';

class ReviewStatusBloc extends Bloc<ReviewStatusEvent, ReviewStatusState> {
  final ReviewStatusRepository _repository;

  ReviewStatusBloc(this._repository) : super(const ReviewStatusInitial()) {
    on<ReviewStatusRequested>(_onReviewStatusRequested);
  }

  Future<void> _onReviewStatusRequested(
    ReviewStatusRequested event,
    Emitter<ReviewStatusState> emit,
  ) async {
    emit(const ReviewStatusLoading());
    try {
      final data = await _repository.getReviewStatus();
      emit(ReviewStatusLoaded(data: data));
    } on ApiException catch (e) {
      emit(ReviewStatusFailure(message: e.message));
    } catch (e) {
      emit(ReviewStatusFailure(message: e.toString()));
    }
  }
}
