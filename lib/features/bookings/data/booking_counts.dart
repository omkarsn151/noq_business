import 'package:noq_business/features/bookings/data/booking_status.dart';

/// Per tab totals returned in `meta.counts`.
class BookingCounts {
  final int pending;
  final int approved;
  final int completed;
  final int rejected;
  final int cancellations;
  final int dismissed;

  const BookingCounts({
    this.pending = 0,
    this.approved = 0,
    this.completed = 0,
    this.rejected = 0,
    this.cancellations = 0,
    this.dismissed = 0,
  });

  factory BookingCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingCounts();
    return BookingCounts(
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      cancellations: (json['cancellations'] as num?)?.toInt() ?? 0,
      dismissed: (json['dismissed'] as num?)?.toInt() ?? 0,
    );
  }

  int countFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return pending;
      case BookingStatus.approved:
        return approved;
      case BookingStatus.completed:
        return completed;
      case BookingStatus.rejected:
        return rejected;
      case BookingStatus.cancelled:
        return cancellations;
      case BookingStatus.dismissed:
        return dismissed;
    }
  }
}
