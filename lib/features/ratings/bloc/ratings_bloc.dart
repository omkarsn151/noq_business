import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/ratings/bloc/ratings_event.dart';
import 'package:noq_business/features/ratings/bloc/ratings_state.dart';
import 'package:noq_business/features/ratings/data/reviews_page_model.dart';
import 'package:noq_business/features/ratings/repository/ratings_repository.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  final RatingsRepository _repository;

  RatingsBloc(this._repository) : super(const RatingsState()) {
    on<RatingsRequested>(_onRequested);
    on<RatingsRefreshRequested>(_onRefreshRequested);
    on<RatingsNextPageRequested>(_onNextPageRequested);
  }

  Future<void> _onRefreshRequested(
    RatingsRefreshRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(const RatingsState());
    add(const RatingsRequested());
  }

  Future<void> _onRequested(
    RatingsRequested event,
    Emitter<RatingsState> emit,
  ) async {
    emit(state.copyWith(status: RatingsStatus.loading, message: ''));

    try {
      final page = await _repository.getReviews();
      emit(
        RatingsState(
          status: RatingsStatus.success,
          reviews: page.reviews,
          pagination: page.pagination,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RatingsStatus.failure,
          message: _messageOf(e),
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    RatingsNextPageRequested event,
    Emitter<RatingsState> emit,
  ) async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.status != RatingsStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, message: ''));

    try {
      final ReviewsPageModel page = await _repository.getReviews(
        page: state.pagination.page + 1,
      );
      emit(
        state.copyWith(
          reviews: [...state.reviews, ...page.reviews],
          pagination: page.pagination,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Keep the loaded pages on screen and surface the message inline.
      emit(state.copyWith(isLoadingMore: false, message: _messageOf(e)));
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
