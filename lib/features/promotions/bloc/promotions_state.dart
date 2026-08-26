import 'package:equatable/equatable.dart';
import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/promotions/data/promotion_counts.dart';
import 'package:noq_business/features/promotions/data/promotion_model.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';

enum PromotionsTabStatus { initial, loading, success, failure }

/// Loading state of a single tab - each tab paginates independently.
class PromotionsTabState extends Equatable {
  final PromotionsTabStatus status;
  final List<PromotionModel> promotions;
  final PaginationModel pagination;

  /// True while the next page is being appended.
  final bool isLoadingMore;
  final String message;

  const PromotionsTabState({
    this.status = PromotionsTabStatus.initial,
    this.promotions = const [],
    this.pagination = const PaginationModel(),
    this.isLoadingMore = false,
    this.message = '',
  });

  bool get hasMore => pagination.hasMore;

  PromotionsTabState copyWith({
    PromotionsTabStatus? status,
    List<PromotionModel>? promotions,
    PaginationModel? pagination,
    bool? isLoadingMore,
    String? message,
  }) {
    return PromotionsTabState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    promotions,
    pagination,
    isLoadingMore,
    message,
  ];
}

class PromotionsState extends Equatable {
  final Map<PromotionStatus, PromotionsTabState> tabs;
  final PromotionCounts counts;

  const PromotionsState({
    this.tabs = const {},
    this.counts = const PromotionCounts(),
  });

  PromotionsTabState tabFor(PromotionStatus status) =>
      tabs[status] ?? const PromotionsTabState();

  PromotionsState copyWithTab(
    PromotionStatus status,
    PromotionsTabState tab, {
    PromotionCounts? counts,
  }) {
    return PromotionsState(
      tabs: {...tabs, status: tab},
      counts: counts ?? this.counts,
    );
  }

  @override
  List<Object?> get props => [tabs, counts];
}
