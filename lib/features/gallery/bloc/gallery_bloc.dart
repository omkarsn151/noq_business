import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/gallery/bloc/gallery_event.dart';
import 'package:noq_business/features/gallery/bloc/gallery_state.dart';
import 'package:noq_business/features/gallery/data/gallery_page_model.dart';
import 'package:noq_business/features/gallery/repository/gallery_repository.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository _repository;

  GalleryBloc(this._repository) : super(const GalleryState()) {
    on<GalleryRequested>(_onGalleryRequested);
    on<GalleryRefreshRequested>(_onRefreshRequested);
    on<GalleryNextPageRequested>(_onNextPageRequested);
  }

  Future<void> _onRefreshRequested(
    GalleryRefreshRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(state.copyWithTab(event.source, const GalleryTabState()));
    add(GalleryRequested(source: event.source, refresh: true));
  }

  Future<void> _onGalleryRequested(
    GalleryRequested event,
    Emitter<GalleryState> emit,
  ) async {
    final tab = state.tabFor(event.source);

    // Tabs keep their pictures once loaded, so switching back is instant.
    if (!event.refresh && tab.status == GalleryTabStatus.success) return;

    emit(
      state.copyWithTab(
        event.source,
        tab.copyWith(
          status: GalleryTabStatus.loading,
          message: '',
          businessNotFound: false,
        ),
      ),
    );

    try {
      final page = await _repository.getGallery(source: event.source);
      emit(
        state.copyWithTab(
          event.source,
          GalleryTabState(
            status: GalleryTabStatus.success,
            images: page.images,
            pagination: page.pagination,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWithTab(
          event.source,
          tab.copyWith(
            status: GalleryTabStatus.failure,
            message: _messageOf(e),
            businessNotFound: e is ApiException && e.statusCode == 404,
          ),
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    GalleryNextPageRequested event,
    Emitter<GalleryState> emit,
  ) async {
    final tab = state.tabFor(event.source);
    if (tab.isLoadingMore ||
        !tab.hasMore ||
        tab.status != GalleryTabStatus.success) {
      return;
    }

    emit(state.copyWithTab(event.source, tab.copyWith(isLoadingMore: true)));

    try {
      final GalleryPageModel page = await _repository.getGallery(
        source: event.source,
        page: tab.pagination.page + 1,
      );
      emit(
        state.copyWithTab(
          event.source,
          tab.copyWith(
            images: [...tab.images, ...page.images],
            pagination: page.pagination,
            isLoadingMore: false,
          ),
        ),
      );
    } catch (e) {
      // Keep the loaded pages on screen and surface the message inline.
      emit(
        state.copyWithTab(
          event.source,
          tab.copyWith(isLoadingMore: false, message: _messageOf(e)),
        ),
      );
    }
  }

  String _messageOf(Object error) =>
      error is ApiException ? error.message : error.toString();
}
