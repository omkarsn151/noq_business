const monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 'Aug 26'
String formatDayMonth(DateTime date) {
  final local = date.toLocal();
  return '${monthNames[local.month - 1]} ${local.day}';
}

/// 'Aug 26, 2026'
String formatDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  return '${formatDayMonth(local)}, ${local.year}';
}

/// '10 Aug 2026'
String formatDayMonthYear(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  return '${local.day} ${monthNames[local.month - 1]} ${local.year}';
}

/// '4:30 PM'
String formatTime(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// 'Aug 26, 2026, 4:30 PM'
String formatDateTime(DateTime? date) {
  if (date == null) return '—';
  return '${formatDate(date)}, ${formatTime(date)}';
}

/// How many days [date] is away from today, in local time.
int _daysFromToday(DateTime local) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  return day.difference(today).inDays;
}

/// 'Today, 4:00 PM' / 'Tomorrow, 4:00 PM' / 'Jul 01, 6:00 PM'
String formatRelativeDateTime(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();

  final label = switch (_daysFromToday(local)) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ =>
      '${monthNames[local.month - 1]} ${local.day.toString().padLeft(2, '0')}',
  };

  return '$label, ${formatTime(local)}';
}

/// 'Today' / 'Tomorrow' / 'Yesterday' / '23 Jun'
String formatRelativeDay(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();

  return switch (_daysFromToday(local)) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    _ => '${local.day} ${monthNames[local.month - 1]}',
  };
}

/// 'Today, 23 Jun' / 'Tomorrow, 23 Jun' / '23 Jun'
String formatRelativeDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final dayMonth = '${local.day} ${monthNames[local.month - 1]}';

  return switch (_daysFromToday(local)) {
    0 => 'Today, $dayMonth',
    1 => 'Tomorrow, $dayMonth',
    -1 => 'Yesterday, $dayMonth',
    _ => dayMonth,
  };
}
