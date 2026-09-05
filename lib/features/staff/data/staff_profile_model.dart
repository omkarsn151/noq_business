import 'package:noq_business/core/models/upload_model.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';

/// '09:00:00' -> '9:00 AM'. Null for anything that is not an 'HH:mm' prefix.
String? _formatClock(String? value) {
  final parts = (value ?? '').split(':');
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;

  final display = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'AM' : 'PM';
  return '$display:${minute.toString().padLeft(2, '0')} $period';
}

/// One service this person can perform. Richer than the `{id, name}` refs on
/// the staff list - the profile endpoint is the only one that sends pictures.
class StaffProfileService {
  final String id;
  final String name;

  /// Small pictures for lists and cards, in the owner's order. Can be empty.
  final List<String> thumbnails;

  /// Wide pictures for the service detail screen. Not drawn on this screen.
  final List<String> banners;

  const StaffProfileService({
    this.id = '',
    this.name = '',
    this.thumbnails = const [],
    this.banners = const [],
  });

  factory StaffProfileService.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;

    return StaffProfileService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      thumbnails: _urls(images?['thumbnails']),
      banners: _urls(images?['banners']),
    );
  }

  static List<String> _urls(Object? value) {
    return (value as List? ?? [])
        .map((url) => url?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String? get thumbnailUrl => thumbnails.isEmpty ? null : thumbnails.first;
}

/// The person themselves. Same shape as a staff list row, except the hours are
/// nullable here and each service carries its picture URLs.
class StaffProfileStaff {
  final String id;
  final String name;
  final UploadModel? photo;

  /// 'HH:mm:ss' in the shop's timezone, or null when never set.
  final String? worksFrom;
  final String? worksTo;
  final String? breakStart;
  final String? breakEnd;

  final bool isActive;
  final List<StaffProfileService> services;

  const StaffProfileStaff({
    this.id = '',
    this.name = '',
    this.photo,
    this.worksFrom,
    this.worksTo,
    this.breakStart,
    this.breakEnd,
    this.isActive = false,
    this.services = const [],
  });

  factory StaffProfileStaff.fromJson(Map<String, dynamic> json) {
    final photo = json['photo'];

    return StaffProfileStaff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photo: photo is Map<String, dynamic>
          ? UploadModel.fromJson(photo)
          : null,
      worksFrom: json['works_from']?.toString(),
      worksTo: json['works_to']?.toString(),
      breakStart: json['break_start']?.toString(),
      breakEnd: json['break_end']?.toString(),
      isActive: json['is_active'] as bool? ?? false,
      services: (json['services'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StaffProfileService.fromJson)
          .toList(),
    );
  }

  String? get photoUrl {
    final url = photo?.url;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// '9:00 AM - 6:00 PM', or 'Not set' when either end is missing.
  String get hoursLabel {
    final from = _formatClock(worksFrom);
    final to = _formatClock(worksTo);
    if (from == null || to == null) return 'Not set';
    return '$from - $to';
  }

  /// '1:00 PM - 1:30 PM', or null when they take no break.
  String? get breakLabel {
    final from = _formatClock(breakStart);
    final to = _formatClock(breakEnd);
    if (from == null || to == null) return null;
    return '$from - $to';
  }

  /// The shape [AddStaffScreen] expects when opened for editing.
  StaffModel toStaffModel() {
    return StaffModel(
      id: id,
      name: name,
      photo: photo,
      worksFrom: worksFrom ?? '',
      worksTo: worksTo ?? '',
      breakStart: breakStart,
      breakEnd: breakEnd,
      isActive: isActive,
      services: services
          .map((service) => StaffServiceRef(id: service.id, name: service.name))
          .toList(),
    );
  }
}

/// One visit that asked for this person today.
class StaffTodayBooking {
  final String id;
  final String customerName;

  /// Always a list of names, even for a single service.
  final List<String> services;
  final int durationMinutes;

  /// Sent as UTC; formatted with the device's local time like every other
  /// screen in the app.
  final DateTime? scheduledStart;

  /// 'confirmed' | 'in_progress'.
  final String status;

  const StaffTodayBooking({
    this.id = '',
    this.customerName = '',
    this.services = const [],
    this.durationMinutes = 0,
    this.scheduledStart,
    this.status = '',
  });

  factory StaffTodayBooking.fromJson(Map<String, dynamic> json) {
    return StaffTodayBooking(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      services: (json['services'] as List? ?? [])
          .map((service) => service?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      scheduledStart: DateTime.tryParse(
        json['scheduled_start']?.toString() ?? '',
      ),
      status: json['status']?.toString() ?? '',
    );
  }

  /// '20 min'
  String get durationLabel => '$durationMinutes min';

  /// 'Haircut' or 'Manicure + Hair Spa' when the visit covers several services.
  String get serviceLabel => services.join(' + ');
}

/// The three Today Status tiles.
///
/// These count visits that *asked for* this person - a visit booked as
/// "Anyone" belongs to nobody and shows on no profile.
class StaffTodayStatus {
  /// The visit already started, or null when they are free.
  final StaffTodayBooking? currentBooking;

  /// The soonest visit still ahead of the clock, or null when none is left.
  final StaffTodayBooking? nextBooking;

  /// The one in the chair plus every unfinished one after it.
  final int visitsLeft;

  const StaffTodayStatus({
    this.currentBooking,
    this.nextBooking,
    this.visitsLeft = 0,
  });

  factory StaffTodayStatus.fromJson(Map<String, dynamic> json) {
    final current = json['current_booking'];
    final next = json['next_booking'];

    return StaffTodayStatus(
      currentBooking: current is Map<String, dynamic>
          ? StaffTodayBooking.fromJson(current)
          : null,
      nextBooking: next is Map<String, dynamic>
          ? StaffTodayBooking.fromJson(next)
          : null,
      visitsLeft: (json['visits_left'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Everything the Staff Profile screen shows for one person, in one call.
class StaffProfileModel {
  final StaffProfileStaff staff;

  /// IANA timezone of the shop, e.g. 'Asia/Kolkata'. "Today" was worked out in
  /// this zone; times are still rendered in the device's local time like the
  /// rest of the app.
  final String timezone;

  final StaffTodayStatus today;

  /// The complete day, earliest first - empty on a free day, which is still a
  /// successful response.
  final List<StaffTodayBooking> todaysBookings;

  const StaffProfileModel({
    this.staff = const StaffProfileStaff(),
    this.timezone = '',
    this.today = const StaffTodayStatus(),
    this.todaysBookings = const [],
  });

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final staff = data['staff'] as Map<String, dynamic>?;
    final today = data['today'] as Map<String, dynamic>?;

    return StaffProfileModel(
      staff: staff == null
          ? const StaffProfileStaff()
          : StaffProfileStaff.fromJson(staff),
      timezone: data['timezone']?.toString() ?? '',
      today: today == null
          ? const StaffTodayStatus()
          : StaffTodayStatus.fromJson(today),
      todaysBookings: (data['todays_bookings'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StaffTodayBooking.fromJson)
          .toList(),
    );
  }

  /// Flips the active toggle without a round trip, for the optimistic update.
  StaffProfileModel withActive(bool isActive) {
    return StaffProfileModel(
      staff: StaffProfileStaff(
        id: staff.id,
        name: staff.name,
        photo: staff.photo,
        worksFrom: staff.worksFrom,
        worksTo: staff.worksTo,
        breakStart: staff.breakStart,
        breakEnd: staff.breakEnd,
        isActive: isActive,
        services: staff.services,
      ),
      timezone: timezone,
      today: today,
      todaysBookings: todaysBookings,
    );
  }
}
