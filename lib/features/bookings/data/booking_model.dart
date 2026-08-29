import 'package:noq_business/features/bookings/data/booking_status.dart';

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
  final String customerName;
  final List<BookingService> services;
  final int durationMinutes;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final BookingStatus? status;
  final String bookingType;

  const BookingModel({
    required this.id,
    required this.customerName,
    required this.services,
    required this.durationMinutes,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    required this.bookingType,
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
      status: BookingStatus.fromString(json['status']?.toString()),
      bookingType: json['booking_type']?.toString() ?? '',
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
