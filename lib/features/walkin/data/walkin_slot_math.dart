import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

/// How many consecutive chips a visit needs.
///
/// One chip covers `blockMinutes`. The buffer is slack on the booking as a
/// whole, not per chip, so N chips can absorb `N * block + buffer` minutes of
/// service time. The smallest N that fits is `ceil((total - buffer) / block)`.
///
/// With block 30 / buffer 15: 30 -> 1, 45 -> 1, 46 -> 2, 70 -> 2, 80 -> 3.
int requiredSlotCount({
  required int totalDurationMinutes,
  required int blockMinutes,
  required int bufferMinutes,
}) {
  if (blockMinutes <= 0) return 1;
  final needed = totalDurationMinutes - bufferMinutes;
  if (needed <= 0) return 1;
  return (needed + blockMinutes - 1) ~/ blockMinutes;
}

/// Whether a visit of [count] chips can start at [index].
///
/// The run has to exist, every chip in it has to be available, and each chip
/// has to start exactly `blockMinutes` after the one before it - lunch breaks
/// are omitted from `times` rather than sent as full, so neighbouring entries
/// in the list are not necessarily back-to-back on the clock.
bool canStartRunAt(
  List<WalkinTime> times,
  int index,
  int count,
  int blockMinutes,
) {
  if (count <= 0 || index < 0 || index + count > times.length) return false;

  for (var i = index; i < index + count; i++) {
    final slot = times[i];
    if (!slot.isAvailable || slot.start == null) return false;
    if (i > index) {
      final previous = times[i - 1].start;
      if (previous == null) return false;
      if (slot.start!.difference(previous).inMinutes != blockMinutes) {
        return false;
      }
    }
  }
  return true;
}

/// Every index a selection starting at [startIndex] covers, for highlighting.
List<int> runIndexes(int startIndex, int count) =>
    List<int>.generate(count, (offset) => startIndex + offset);
