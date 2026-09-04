import 'package:equatable/equatable.dart';
import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/gallery/data/gallery_image_model.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';

enum GalleryTabStatus { initial, loading, success, failure }

/// Loading state of a single tab - each tab paginates independently.
class GalleryTabState extends Equatable {
  final GalleryTabStatus status;
  final List<GalleryImageModel> images;
  final PaginationModel pagination;

  /// True while the next page is being appended.
  final bool isLoadingMore;
  final String message;

  /// The owner has no shop yet - send them to Business Setup instead of Retry.
  final bool businessNotFound;

  const GalleryTabState({
    this.status = GalleryTabStatus.initial,
    this.images = const [],
    this.pagination = const PaginationModel(),
    this.isLoadingMore = false,
    this.message = '',
    this.businessNotFound = false,
  });

  bool get hasMore => pagination.hasMore;

  GalleryTabState copyWith({
    GalleryTabStatus? status,
    List<GalleryImageModel>? images,
    PaginationModel? pagination,
    bool? isLoadingMore,
    String? message,
    bool? businessNotFound,
  }) {
    return GalleryTabState(
      status: status ?? this.status,
      images: images ?? this.images,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
      businessNotFound: businessNotFound ?? this.businessNotFound,
    );
  }

  @override
  List<Object?> get props => [
    status,
    images,
    pagination,
    isLoadingMore,
    message,
    businessNotFound,
  ];
}

class GalleryState extends Equatable {
  final Map<GallerySource, GalleryTabState> tabs;

  const GalleryState({this.tabs = const {}});

  GalleryTabState tabFor(GallerySource source) =>
      tabs[source] ?? const GalleryTabState();

  /// Photo count for the app bar subtitle, taken from the unfiltered tab.
  int get totalPhotos => tabFor(GallerySource.all).pagination.totalItems;

  GalleryState copyWithTab(GallerySource source, GalleryTabState tab) {
    return GalleryState(tabs: {...tabs, source: tab});
  }

  @override
  List<Object?> get props => [tabs];
}
