const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
