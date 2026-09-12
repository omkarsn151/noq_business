import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/bookings/bloc/bookings_event.dart';
import 'package:noq_business/features/bookings/bloc/bookings_state.dart';
import 'package:noq_business/features/bookings/data/bookings_page_model.dart';
import 'package:noq_business/features/bookings/repository/bookings_repository.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final BookingsRepository _repository;

  BookingsBloc(this._repository) : super(const BookingsState()) {
    on<BookingsRequested>(_onBookingsRequested);
    on<BookingsRefreshRequested>(_onRefreshRequested);
    on<BookingsNextPageRequested>(_onNextPageRequested);
  }

  Future<void> _onRefreshRequested(
    BookingsRefreshRequested event,
    Emitter<BookingsState> emit,
  ) async {
    emit(BookingsState(counts: state.counts));
    add(BookingsRequested(status: event.status, refresh: true));
  }

  Future<void> _onBookingsRequested(
    BookingsRequested event,
    Emitter<BookingsState> emit,
  ) async {
    final tab = state.tabFor(event.status);

    // Tabs keep their bookings once loaded, so switching back is instant.
    // A load already under way is left alone too, so a tab that asks for
    // itself while it is filling does not fetch the same page twice.
    if (!event.refresh &&
        (tab.status == BookingsTabStatus.success ||
            tab.status == BookingsTabStatus.loading)) {
      return;
    }

    emit(
      state.copyWithTab(
        event.status,
        tab.copyWith(status: BookingsTabStatus.loading, message: ''),
      ),
    );

    try {
      final page = await _repository.getBookings(status: event.status);
      emit(
        state.copyWithTab(
          event.status,
          BookingsTabState(
            status: BookingsTabStatus.success,
            bookings: page.bookings,
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
            status: BookingsTabStatus.failure,
            message: _messageOf(e),
          ),
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    BookingsNextPageRequested event,
    Emitter<BookingsState> emit,
  ) async {
    final tab = state.tabFor(event.status);
    if (tab.isLoadingMore ||
        !tab.hasMore ||
        tab.status != BookingsTabStatus.success) {
      return;
    }

    emit(state.copyWithTab(event.status, tab.copyWith(isLoadingMore: true)));

    try {
      final BookingsPageModel page = await _repository.getBookings(
        status: event.status,
        page: tab.pagination.page + 1,
      );
      emit(
        state.copyWithTab(
          event.status,
          tab.copyWith(
            bookings: [...tab.bookings, ...page.bookings],
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
