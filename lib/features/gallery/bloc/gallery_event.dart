import 'package:equatable/equatable.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of [source]. Already loaded tabs are served from the
/// cached state unless [refresh] is set.
class GalleryRequested extends GalleryEvent {
  final GallerySource source;
  final bool refresh;

  const GalleryRequested({required this.source, this.refresh = false});

  @override
  List<Object?> get props => [source, refresh];
}

/// Drops the cached [source] tab and reloads it - pull to refresh.
class GalleryRefreshRequested extends GalleryEvent {
  final GallerySource source;

  const GalleryRefreshRequested({required this.source});

  @override
  List<Object?> get props => [source];
}

/// Appends the next page of [source] to the already loaded pictures.
class GalleryNextPageRequested extends GalleryEvent {
  final GallerySource source;

  const GalleryNextPageRequested({required this.source});

  @override
  List<Object?> get props => [source];
}
