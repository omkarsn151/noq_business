/// One row in the Walk In screen's "Current Bookings" strip - a visit still
/// ahead of now, today, in `confirmed` or `in_progress` status.
class TodayBookingItem {
  final String id;
  final String customerName;

  /// Always a list of names, even for a single service.
  final List<String> services;
  final int durationMinutes;

  /// Null when nobody was picked for the visit.
  final String? staffName;

  /// Sent as UTC; convert with the shop's timezone before printing.
  final DateTime? scheduledStart;

  /// 'confirmed' | 'in_progress'.
  final String status;

  const TodayBookingItem({
    this.id = '',
    this.customerName = '',
    this.services = const [],
    this.durationMinutes = 0,
    this.staffName,
    this.scheduledStart,
    this.status = '',
  });

  factory TodayBookingItem.fromJson(Map<String, dynamic> json) {
    return TodayBookingItem(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      services: (json['services'] as List? ?? [])
          .map((service) => service?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      staffName: json['staff_name']?.toString(),
      scheduledStart: DateTime.tryParse(
        json['scheduled_start']?.toString() ?? '',
      ),
      status: json['status']?.toString() ?? '',
    );
  }

  /// '30min'
  String get durationLabel => '${durationMinutes}min';

  /// 'Haircut' or 'Manicure + Hair Spa' when the visit covers several services.
  String get serviceLabel => services.join(' + ');

  /// The row's staff line - 'Any staff' when nobody was picked.
  String get staffLabel {
    final name = staffName?.trim();
    return name == null || name.isEmpty ? 'Any staff' : name;
  }
}

/// The strip's payload - at most 5 rows, plus the real total for "View All".
class TodaysBookingsModel {
  final List<TodayBookingItem> bookings;

  /// The real count of qualifying visits today - can exceed [bookings].
  final int totalToday;

  const TodaysBookingsModel({this.bookings = const [], this.totalToday = 0});

  factory TodaysBookingsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;

    return TodaysBookingsModel(
      bookings: data
          .whereType<Map<String, dynamic>>()
          .map(TodayBookingItem.fromJson)
          .toList(),
      totalToday: (meta?['total_today'] as num?)?.toInt() ?? 0,
    );
  }

  /// "View All" is only useful once the strip is not already showing
  /// everything.
  bool get hasMoreThanShown => totalToday > bookings.length;
}
