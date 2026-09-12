import 'package:noq_business/features/bookings/data/booking_detail_status.dart';

/// A service attached to a booking.
class BookingService {
  final String id;
  final String name;

  const BookingService({required this.id, required this.name});

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// A single booking row returned by the bookings list endpoint.
class BookingModel {
  final String id;
  final String reference;
  final String customerName;
  final List<BookingService> services;
  final int durationMinutes;

  /// For a reschedule request this is the *original* slot, and the slot the
  /// customer asked for lives in [requestedStart] / [requestedEnd].
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;

  /// The row's own life stage. Note this is the item spelling the API uses
  /// (`confirmed`, `in_progress`, ...), which is wider than the four list
  /// tabs - the card needs it to tell a confirmed booking from one already in
  /// progress.
  final BookingDetailStatus status;
  final String bookingType;

  /// True when this row is a customer reschedule request rather than a plain
  /// booking. Reschedule requests show up in the Pending tab even though the
  /// booking itself is still confirmed.
  final bool isRescheduleRequest;
  final String? rescheduleRequestId;
  final DateTime? requestedStart;
  final DateTime? requestedEnd;

  const BookingModel({
    required this.id,
    required this.customerName,
    required this.services,
    required this.durationMinutes,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    required this.bookingType,
    this.reference = '',
    this.isRescheduleRequest = false,
    this.rescheduleRequestId,
    this.requestedStart,
    this.requestedEnd,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      services: (json['services'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BookingService.fromJson)
          .toList(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      scheduledStart: DateTime.tryParse(
        json['scheduled_start']?.toString() ?? '',
      ),
      scheduledEnd: DateTime.tryParse(json['scheduled_end']?.toString() ?? ''),
      status: BookingDetailStatus.fromString(json['status']?.toString()),
      bookingType: json['booking_type']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      isRescheduleRequest: json['is_reschedule_request'] == true,
      rescheduleRequestId: json['reschedule_request_id']?.toString(),
      requestedStart: DateTime.tryParse(
        json['requested_start']?.toString() ?? '',
      ),
      requestedEnd: DateTime.tryParse(json['requested_end']?.toString() ?? ''),
    );
  }

  /// '45 min'
  String get durationLabel => '$durationMinutes min';

  /// 'Coloring' or 'Coloring +2 more' when the booking covers several services.
  String get serviceLabel {
    if (services.isEmpty) return '';
    final first = services.first.name;
    return services.length > 1 ? '$first +${services.length - 1} more' : first;
  }

  bool get isWalkIn {
    final type = bookingType.toLowerCase();
    return type == 'walk_in' || type == 'walkin' || type == 'walk-in';
  }
}
