import 'package:noq_business/core/utils/date_formats.dart';

/// What the slot bottom sheet hands back to the walk-in form.
///
/// [starts] are the UTC chip starts to post as `slots`; [end] is only used to
/// build the label the clerk reads back.
class WalkinSlotSelection {
  final List<DateTime> starts;

  /// Local calendar day of the visit, `YYYY-MM-DD`.
  final String date;
  final DateTime? end;

  const WalkinSlotSelection({
    required this.starts,
    required this.date,
    required this.end,
  });

  int get slotCount => starts.length;

  /// 'Aug 28, 9:30 AM - 11:00 AM'
  String get label {
    if (starts.isEmpty) return '';
    final first = starts.first;
    return '${formatDayMonth(first)}, '
        '${formatTime(first)} - ${formatTime(end)}';
  }
}
