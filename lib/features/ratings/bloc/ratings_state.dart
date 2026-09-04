import 'package:equatable/equatable.dart';
import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/ratings/data/review_model.dart';

enum RatingsStatus { initial, loading, success, failure }

class RatingsState extends Equatable {
  final RatingsStatus status;
  final List<ReviewModel> reviews;
  final PaginationModel pagination;

  /// True while the next page is being appended.
  final bool isLoadingMore;

  /// Fatal message for the failure state, or an inline next-page error.
  final String message;

  const RatingsState({
    this.status = RatingsStatus.initial,
    this.reviews = const [],
    this.pagination = const PaginationModel(),
    this.isLoadingMore = false,
    this.message = '',
  });

  bool get hasMore => pagination.hasMore;

  RatingsState copyWith({
    RatingsStatus? status,
    List<ReviewModel>? reviews,
    PaginationModel? pagination,
    bool? isLoadingMore,
    String? message,
  }) {
    return RatingsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reviews,
    pagination,
    isLoadingMore,
    message,
  ];
}
