import 'package:flutter/material.dart';

/// Opening hours for a single day of the week.
///
/// [dayOfWeek] follows the API's convention: Sunday is 0 through Saturday is 6.
class BusinessHourModel {
  final int dayOfWeek;
  final bool isClosed;
  final TimeOfDay? opensAt;
  final TimeOfDay? closesAt;
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;

  const BusinessHourModel({
    required this.dayOfWeek,
    this.isClosed = false,
    this.opensAt,
    this.closesAt,
    this.breakStart,
    this.breakEnd,
  });

  factory BusinessHourModel.fromJson(Map<String, dynamic> json) {
    return BusinessHourModel(
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
      isClosed: json['is_closed'] as bool? ?? false,
      opensAt: _parseTime(json['opens_at']),
      closesAt: _parseTime(json['closes_at']),
      breakStart: _parseTime(json['break_start']),
      breakEnd: _parseTime(json['break_end']),
    );
  }

  static const List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> shortDayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  static const TimeOfDay defaultOpensAt = TimeOfDay(hour: 10, minute: 0);
  static const TimeOfDay defaultClosesAt = TimeOfDay(hour: 19, minute: 0);
  static const TimeOfDay defaultBreakStart = TimeOfDay(hour: 13, minute: 0);
  static const TimeOfDay defaultBreakEnd = TimeOfDay(hour: 14, minute: 0);

  /// The starting week: open Monday–Saturday on default hours, closed Sunday.
  static List<BusinessHourModel> initialWeek() {
    return List.generate(7, (day) {
      if (day == 0) return const BusinessHourModel(dayOfWeek: 0, isClosed: true);
      return BusinessHourModel(
        dayOfWeek: day,
        opensAt: defaultOpensAt,
        closesAt: defaultClosesAt,
      );
    });
  }

  String get dayName => dayNames[dayOfWeek];

  String get shortDayName => shortDayNames[dayOfWeek];

  bool get hasBreak => breakStart != null || breakEnd != null;

  /// Whether this day is fully filled in — a closed day always is.
  bool get isComplete {
    if (isClosed) return true;
    if (opensAt == null || closesAt == null) return false;
    if (hasBreak && (breakStart == null || breakEnd == null)) return false;
    return true;
  }

  /// The first problem with this day, or null when it is valid.
  String? get error {
    if (isClosed) return null;
    if (opensAt == null) return 'Set an opening time';
    if (closesAt == null) return 'Set a closing time';

    final opens = _minutesOf(opensAt!);
    final closes = _minutesOf(closesAt!);
    if (closes <= opens) return 'Closing time must be after opening time';

    if (!hasBreak) return null;
    if (breakStart == null) return 'Set a break start time';
    if (breakEnd == null) return 'Set a break end time';

    final start = _minutesOf(breakStart!);
    final end = _minutesOf(breakEnd!);
    if (end <= start) return 'Break end must be after break start';
    if (start < opens || end > closes) {
      return 'Break must fall within opening hours';
    }
    return null;
  }

  BusinessHourModel copyWith({
    bool? isClosed,
    TimeOfDay? opensAt,
    TimeOfDay? closesAt,
    TimeOfDay? breakStart,
    TimeOfDay? breakEnd,
    bool clearBreak = false,
  }) {
    return BusinessHourModel(
      dayOfWeek: dayOfWeek,
      isClosed: isClosed ?? this.isClosed,
      opensAt: opensAt ?? this.opensAt,
      closesAt: closesAt ?? this.closesAt,
      breakStart: clearBreak ? null : (breakStart ?? this.breakStart),
      breakEnd: clearBreak ? null : (breakEnd ?? this.breakEnd),
    );
  }

  /// Copies [other]'s timings onto this day, keeping this day's [dayOfWeek].
  BusinessHourModel withTimingsOf(BusinessHourModel other) {
    return BusinessHourModel(
      dayOfWeek: dayOfWeek,
      isClosed: other.isClosed,
      opensAt: other.opensAt,
      closesAt: other.closesAt,
      breakStart: other.breakStart,
      breakEnd: other.breakEnd,
    );
  }

  Map<String, dynamic> toJson() {
    if (isClosed) {
      return {'day_of_week': dayOfWeek, 'is_closed': true};
    }
    return {
      'day_of_week': dayOfWeek,
      'is_closed': false,
      'opens_at': _formatTime(opensAt),
      'closes_at': _formatTime(closesAt),
      'break_start': _formatTime(breakStart),
      'break_end': _formatTime(breakEnd),
    };
  }

  static int _minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Parses the API's `HH:mm:ss` clock strings. Null on a closed day, and on
  /// anything that does not read as a time.
  static TimeOfDay? _parseTime(Object? value) {
    if (value == null) return null;
    final parts = value.toString().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}
