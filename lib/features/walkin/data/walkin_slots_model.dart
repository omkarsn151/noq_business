/// Status of a single time chip on the walk-in slots grid.
///
/// Lunch-break and off-hours cells are omitted from `times` altogether, so
/// there is no "closed" member here - a gap in the grid is an absent chip.
enum WalkinTimeStatus {
  available('available'),
  full('full'),
  past('past');

  final String value;

  const WalkinTimeStatus(this.value);

  static WalkinTimeStatus fromString(String? value) {
    return WalkinTimeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WalkinTimeStatus.full,
    );
  }
}

/// One time chip. `start` and `end` come off the wire as UTC.
class WalkinTime {
  final DateTime? start;
  final DateTime? end;
  final WalkinTimeStatus status;

  const WalkinTime({
    required this.start,
    required this.end,
    required this.status,
  });

  factory WalkinTime.fromJson(Map<String, dynamic> json) {
    return WalkinTime(
      start: DateTime.tryParse(json['start']?.toString() ?? ''),
      end: DateTime.tryParse(json['end']?.toString() ?? ''),
      status: WalkinTimeStatus.fromString(json['status']?.toString()),
    );
  }

  bool get isAvailable => status == WalkinTimeStatus.available;

  /// past and full chips are both rendered greyed out and are not tappable.
  bool get isDisabled => !isAvailable;
}

/// One date chip in the booking window.
class WalkinDate {
  /// Local calendar day in the shop's timezone, `YYYY-MM-DD`.
  final String date;
  final String weekday;
  final bool isToday;
  final bool isClosed;

  const WalkinDate({
    required this.date,
    required this.weekday,
    required this.isToday,
    required this.isClosed,
  });

  factory WalkinDate.fromJson(Map<String, dynamic> json) {
    return WalkinDate(
      date: json['date']?.toString() ?? '',
      weekday: json['weekday']?.toString() ?? '',
      isToday: json['is_today'] as bool? ?? false,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  /// '27' from '2026-08-27' - the number shown inside the date chip.
  String get dayNumber => date.length >= 2 ? date.substring(date.length - 2) : date;
}

class WalkinWindow {
  final String timezone;
  final String selectedDate;
  final List<WalkinDate> dates;

  const WalkinWindow({
    this.timezone = '',
    this.selectedDate = '',
    this.dates = const [],
  });

  factory WalkinWindow.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalkinWindow();
    return WalkinWindow(
      timezone: json['timezone']?.toString() ?? '',
      selectedDate: json['selected_date']?.toString() ?? '',
      dates: (json['dates'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WalkinDate.fromJson)
          .toList(),
    );
  }
}

/// Scheduling rules of the shop. `blockMinutes` is the length of one chip and
/// `bufferMinutes` is the slack allowed on the booking as a whole - see
/// `requiredSlotCount` in walkin_slot_math.dart.
class WalkinOperations {
  final int blockMinutes;
  final int bufferMinutes;
  final int bookingLimitPerSlot;
  final int bookingWindowDays;

  const WalkinOperations({
    this.blockMinutes = 0,
    this.bufferMinutes = 0,
    this.bookingLimitPerSlot = 0,
    this.bookingWindowDays = 0,
  });

  factory WalkinOperations.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalkinOperations();
    return WalkinOperations(
      blockMinutes: (json['block_minutes'] as num?)?.toInt() ?? 0,
      bufferMinutes: (json['buffer_minutes'] as num?)?.toInt() ?? 0,
      bookingLimitPerSlot: (json['booking_limit_per_slot'] as num?)?.toInt() ?? 0,
      bookingWindowDays: (json['booking_window_days'] as num?)?.toInt() ?? 0,
    );
  }
}

class WalkinBusiness {
  final String id;
  final String name;
  final WalkinOperations operations;

  const WalkinBusiness({
    this.id = '',
    this.name = '',
    this.operations = const WalkinOperations(),
  });

  factory WalkinBusiness.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalkinBusiness();
    return WalkinBusiness(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      operations: WalkinOperations.fromJson(
        json['operations'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Server-computed totals for the ticked services.
class WalkinSummary {
  final String currencyCode;
  final int servicesCount;
  final int totalDurationMinutes;
  final String totalPayable;

  const WalkinSummary({
    this.currencyCode = '',
    this.servicesCount = 0,
    this.totalDurationMinutes = 0,
    this.totalPayable = '0.00',
  });

  factory WalkinSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalkinSummary();
    return WalkinSummary(
      currencyCode: json['currency_code']?.toString() ?? '',
      servicesCount: (json['services_count'] as num?)?.toInt() ?? 0,
      totalDurationMinutes:
          (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
      totalPayable: json['total_payable']?.toString() ?? '0.00',
    );
  }

  /// '₹998.00' - INR is the only symbol we special-case today.
  String get priceLabel =>
      currencyCode == 'INR' ? '₹$totalPayable' : '$currencyCode $totalPayable';
}

/// `data` of GET /v1/business/walk-ins/slots.
class WalkinSlotsModel {
  final WalkinBusiness business;
  final WalkinWindow window;
  final List<WalkinTime> times;
  final WalkinSummary summary;

  const WalkinSlotsModel({
    this.business = const WalkinBusiness(),
    this.window = const WalkinWindow(),
    this.times = const [],
    this.summary = const WalkinSummary(),
  });

  factory WalkinSlotsModel.fromJson(Map<String, dynamic> json) {
    return WalkinSlotsModel(
      business: WalkinBusiness.fromJson(
        json['business'] as Map<String, dynamic>?,
      ),
      window: WalkinWindow.fromJson(json['window'] as Map<String, dynamic>?),
      times: (json['times'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WalkinTime.fromJson)
          .toList(),
      summary: WalkinSummary.fromJson(json['summary'] as Map<String, dynamic>?),
    );
  }

  WalkinOperations get operations => business.operations;
}
