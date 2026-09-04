import 'package:noq_business/core/utils/currency_format.dart';

/// The greeting block, plus the shop-local day every number below describes.
class DashboardHeader {
  final String businessId;
  final String businessName;

  /// The shop's own calendar day, worked out in [timezone] rather than UTC.
  final DateTime? date;

  /// IANA timezone of the shop, e.g. 'Asia/Kolkata'.
  final String timezone;

  /// Whether the shop is open right now, per its opening hours. Drives the
  /// OPEN / CLOSED pill on the Staff section header.
  final bool isOpen;

  const DashboardHeader({
    this.businessId = '',
    this.businessName = '',
    this.date,
    this.timezone = '',
    this.isOpen = false,
  });

  factory DashboardHeader.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardHeader();
    return DashboardHeader(
      businessId: json['business_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      timezone: json['timezone']?.toString() ?? '',
      isOpen: json['is_open'] == true,
    );
  }
}

/// The big gradient card - today's count and the "+3 vs yesterday" pill.
class DashboardTodaysBookings {
  final int count;

  /// Today minus yesterday. Negative means quieter than yesterday.
  final int changeVsYesterday;

  const DashboardTodaysBookings({this.count = 0, this.changeVsYesterday = 0});

  factory DashboardTodaysBookings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardTodaysBookings();
    return DashboardTodaysBookings(
      count: (json['count'] as num?)?.toInt() ?? 0,
      changeVsYesterday: (json['change_vs_yesterday'] as num?)?.toInt() ?? 0,
    );
  }

  String get countLabel => '$count';

  /// '+3 vs yesterday' / '-2 vs yesterday' / 'Same as yesterday'
  String get comparisonLabel {
    if (changeVsYesterday == 0) return 'Same as yesterday';
    final sign = changeVsYesterday > 0 ? '+' : '';
    return '$sign$changeVsYesterday vs yesterday';
  }
}

/// The "Revenue" card and its percentage pill.
class DashboardRevenue {
  /// Decimal string, e.g. '450.00'. Money expected from today's approved,
  /// running and finished bookings - there is no payments module yet.
  final String amount;
  final String currencyCode;

  /// Decimal string, e.g. '18.00' or '-5.50'. Null when yesterday earned
  /// nothing, because there is nothing to compare against.
  final String? changePercentVsYesterday;

  const DashboardRevenue({
    this.amount = '0',
    this.currencyCode = '',
    this.changePercentVsYesterday,
  });

  factory DashboardRevenue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardRevenue();
    return DashboardRevenue(
      amount: json['amount']?.toString() ?? '0',
      currencyCode: json['currency_code']?.toString() ?? '',
      changePercentVsYesterday: json['change_percent_vs_yesterday']?.toString(),
    );
  }

  /// '₹450'
  String get valueLabel => formatAmount(amount, currencyCode);

  double? get changePercent => double.tryParse(changePercentVsYesterday ?? '');

  /// '18%' / '5.5%' - the sign lives in the arrow, so this is the magnitude.
  /// Null when there is no comparison to show, and the pill is hidden.
  String? get growthLabel {
    final percent = changePercent?.abs();
    if (percent == null) return null;
    final text = percent == percent.roundToDouble()
        ? percent.toStringAsFixed(0)
        : percent.toString();
    return '$text%';
  }

  bool get isPositive => (changePercent ?? 0) >= 0;
}

/// One day's bar in the Revenue card's month-to-date graph.
class DashboardRevenueDay {
  /// The calendar day this bar stands for, in the shop's timezone.
  final DateTime? date;

  /// Decimal string, e.g. '450.00' or '0.00' on a day with no takings.
  final String amount;

  const DashboardRevenueDay({this.date, this.amount = '0'});

  factory DashboardRevenueDay.fromJson(Map<String, dynamic> json) {
    return DashboardRevenueDay(
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      amount: json['amount']?.toString() ?? '0',
    );
  }

  double get value => double.tryParse(amount) ?? 0;
}

/// The month-to-date revenue graph drawn inside the Revenue card. [days] runs
/// from the 1st of [month] to today, one entry per day including the empty ones.
class DashboardRevenueGraph {
  /// 'YYYY-MM' of the month being shown.
  final String month;
  final String currencyCode;

  /// Decimal string - the sum of every day in [days].
  final String total;
  final List<DashboardRevenueDay> days;

  const DashboardRevenueGraph({
    this.month = '',
    this.currencyCode = '',
    this.total = '0',
    this.days = const [],
  });

  factory DashboardRevenueGraph.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardRevenueGraph();
    return DashboardRevenueGraph(
      month: json['month']?.toString() ?? '',
      currencyCode: json['currency_code']?.toString() ?? '',
      total: json['total']?.toString() ?? '0',
      days: (json['days'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardRevenueDay.fromJson)
          .toList(),
    );
  }

  /// Just the daily amounts, in calendar order - what the chart painter needs.
  List<double> get amounts => days.map((day) => day.value).toList();
}

/// The small strip - requests still waiting for the owner to answer. Covers
/// today and every day ahead, so it is not limited to today.
class DashboardPendingBookings {
  final int count;

  const DashboardPendingBookings({this.count = 0});

  factory DashboardPendingBookings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardPendingBookings();
    return DashboardPendingBookings(
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// '04' - zero padded to keep the strip a steady width.
  String get countLabel => count.toString().padLeft(2, '0');
}

/// All three number cards.
class DashboardSummary {
  final DashboardTodaysBookings todaysBookings;
  final DashboardRevenue revenue;
  final DashboardPendingBookings pendingBookings;

  const DashboardSummary({
    this.todaysBookings = const DashboardTodaysBookings(),
    this.revenue = const DashboardRevenue(),
    this.pendingBookings = const DashboardPendingBookings(),
  });

  factory DashboardSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardSummary();
    return DashboardSummary(
      todaysBookings: DashboardTodaysBookings.fromJson(
        json['todays_bookings'] as Map<String, dynamic>?,
      ),
      revenue: DashboardRevenue.fromJson(
        json['revenue'] as Map<String, dynamic>?,
      ),
      pendingBookings: DashboardPendingBookings.fromJson(
        json['pending_bookings'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// One avatar in the "Staff" row - a preview of the team, not the whole list.
/// The API also sends `booked_count`, which is on its way out and is
/// deliberately not parsed here.
class DashboardStaffItem {
  final String id;
  final String name;
  final String? photoUrl;

  const DashboardStaffItem({this.id = '', this.name = '', this.photoUrl});

  factory DashboardStaffItem.fromJson(Map<String, dynamic> json) {
    return DashboardStaffItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

/// The "Staff" section - [items] is capped at 10 by the API, [total] is the
/// full head count.
class DashboardStaff {
  final int total;
  final List<DashboardStaffItem> items;

  const DashboardStaff({this.total = 0, this.items = const []});

  factory DashboardStaff.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardStaff();
    return DashboardStaff(
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardStaffItem.fromJson)
          .toList(),
    );
  }
}

/// One row in the "Bookings" list. Only visits still ahead of now, soonest
/// first, capped at 5 by the API.
class DashboardBookingItem {
  final String id;
  final String customerName;

  /// Every service in this one visit, in the order they were added.
  final List<String> services;
  final int durationMinutes;

  /// Null when the customer did not ask for anyone, or when the visit spans
  /// several services with different people.
  final String? staffName;

  /// Sent as UTC; formatted with the device's local time like every other
  /// screen in the app.
  final DateTime? scheduledStart;

  /// 'pending' | 'confirmed' | 'in_progress'. Kept as a string because these
  /// values do not line up with the bookings list's `BookingStatus` tabs.
  final String status;

  const DashboardBookingItem({
    this.id = '',
    this.customerName = '',
    this.services = const [],
    this.durationMinutes = 0,
    this.staffName,
    this.scheduledStart,
    this.status = '',
  });

  factory DashboardBookingItem.fromJson(Map<String, dynamic> json) {
    return DashboardBookingItem(
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

/// Everything the Dashboard screen needs, in one call, grouped by section of
/// the screen.
class DashboardModel {
  final DashboardHeader header;
  final DashboardSummary summary;
  final DashboardRevenueGraph revenueGraph;
  final DashboardStaff staff;
  final List<DashboardBookingItem> upcomingBookings;

  const DashboardModel({
    this.header = const DashboardHeader(),
    this.summary = const DashboardSummary(),
    this.revenueGraph = const DashboardRevenueGraph(),
    this.staff = const DashboardStaff(),
    this.upcomingBookings = const [],
  });

  /// Takes the full response envelope and reads `data`.
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return DashboardModel(
      header: DashboardHeader.fromJson(
        data['header'] as Map<String, dynamic>?,
      ),
      summary: DashboardSummary.fromJson(
        data['summary'] as Map<String, dynamic>?,
      ),
      revenueGraph: DashboardRevenueGraph.fromJson(
        data['revenue_graph'] as Map<String, dynamic>?,
      ),
      staff: DashboardStaff.fromJson(data['staff'] as Map<String, dynamic>?),
      upcomingBookings: (data['upcoming_bookings'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardBookingItem.fromJson)
          .toList(),
    );
  }
}
