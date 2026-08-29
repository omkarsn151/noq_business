import 'package:equatable/equatable.dart';
import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/bookings/data/booking_counts.dart';
import 'package:noq_business/features/bookings/data/booking_model.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';

enum BookingsTabStatus { initial, loading, success, failure }

/// Loading state of a single tab - each tab paginates independently.
class BookingsTabState extends Equatable {
  final BookingsTabStatus status;
  final List<BookingModel> bookings;
  final PaginationModel pagination;

  /// True while the next page is being appended.
  final bool isLoadingMore;
  final String message;

  const BookingsTabState({
    this.status = BookingsTabStatus.initial,
    this.bookings = const [],
    this.pagination = const PaginationModel(),
    this.isLoadingMore = false,
    this.message = '',
  });

  bool get hasMore => pagination.hasMore;

  BookingsTabState copyWith({
    BookingsTabStatus? status,
    List<BookingModel>? bookings,
    PaginationModel? pagination,
    bool? isLoadingMore,
    String? message,
  }) {
    return BookingsTabState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    pagination,
    isLoadingMore,
    message,
  ];
}

class BookingsState extends Equatable {
  final Map<BookingStatus, BookingsTabState> tabs;
  final BookingCounts counts;

  const BookingsState({
    this.tabs = const {},
    this.counts = const BookingCounts(),
  });

  BookingsTabState tabFor(BookingStatus status) =>
      tabs[status] ?? const BookingsTabState();

  BookingsState copyWithTab(
    BookingStatus status,
    BookingsTabState tab, {
    BookingCounts? counts,
  }) {
    return BookingsState(
      tabs: {...tabs, status: tab},
      counts: counts ?? this.counts,
    );
  }

  @override
  List<Object?> get props => [tabs, counts];
}
