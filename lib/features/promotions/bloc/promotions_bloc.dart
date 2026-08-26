import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/promotions/bloc/promotions_event.dart';
import 'package:noq_business/features/promotions/bloc/promotions_state.dart';
import 'package:noq_business/features/promotions/data/promotions_page_model.dart';
import 'package:noq_business/features/promotions/repository/promotions_repository.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final PromotionsRepository _repository;

  PromotionsBloc(this._repository) : super(const PromotionsState()) {
    on<PromotionsRequested>(_onPromotionsRequested);
    on<PromotionsRefreshRequested>(_onRefreshRequested);
    on<PromotionsNextPageRequested>(_onNextPageRequested);
  }

  Future<void> _onRefreshRequested(
    PromotionsRefreshRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsState(counts: state.counts));
    add(PromotionsRequested(status: event.status, refresh: true));
  }

  Future<void> _onPromotionsRequested(
    PromotionsRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    final tab = state.tabFor(event.status);

    // Tabs keep their promotions once loaded, so switching back is instant.
    if (!event.refresh && tab.status == PromotionsTabStatus.success) return;

    emit(
      state.copyWithTab(
        event.status,
        tab.copyWith(status: PromotionsTabStatus.loading, message: ''),
      ),
    );

    try {
      final page = await _repository.getPromotions(status: event.status);
      emit(
        state.copyWithTab(
          event.status,
          PromotionsTabState(
            status: PromotionsTabStatus.success,
            promotions: page.promotions,
            pagination: page.pagination,
          ),
          counts: page.counts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWithTab(
          event.status,
          tab.copyWith(
            status: PromotionsTabStatus.failure,
            message: _messageOf(e),
          ),
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    PromotionsNextPageRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    final tab = state.tabFor(event.status);
    if (tab.isLoadingMore ||
        !tab.hasMore ||
        tab.status != PromotionsTabStatus.success) {
      return;
    }

    emit(
      state.copyWithTab(event.status, tab.copyWith(isLoadingMore: true)),
    );

    try {
      final PromotionsPageModel page = await _repository.getPromotions(
        status: event.status,
        page: tab.pagination.page + 1,
      );
      emit(
        state.copyWithTab(
          event.status,
          tab.copyWith(
            promotions: [...tab.promotions, ...page.promotions],
            pagination: page.pagination,
            isLoadingMore: false,
          ),
          counts: page.counts,
        ),
      );
    } catch (e) {
      // Keep the loaded pages on screen and surface the message inline.
      emit(
        state.copyWithTab(
          event.status,
          tab.copyWith(isLoadingMore: false, message: _messageOf(e)),
        ),
      );
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
