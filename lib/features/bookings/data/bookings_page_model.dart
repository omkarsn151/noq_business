import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/bookings/data/booking_counts.dart';
import 'package:noq_business/features/bookings/data/booking_model.dart';

/// One page of bookings plus the meta returned alongside it.
class BookingsPageModel {
  final List<BookingModel> bookings;
  final PaginationModel pagination;
  final BookingCounts counts;

  const BookingsPageModel({
    required this.bookings,
    required this.pagination,
    required this.counts,
  });

  factory BookingsPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return BookingsPageModel(
      bookings: data
          .whereType<Map<String, dynamic>>()
          .map(BookingModel.fromJson)
          .toList(),
      pagination: PaginationModel.fromJson(
        meta?['pagination'] as Map<String, dynamic>?,
      ),
      counts: BookingCounts.fromJson(meta?['counts'] as Map<String, dynamic>?),
    );
  }
}
