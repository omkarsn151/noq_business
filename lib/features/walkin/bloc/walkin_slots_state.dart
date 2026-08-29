import 'package:equatable/equatable.dart';
import 'package:noq_business/features/walkin/data/walkin_slot_math.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

enum WalkinSlotsStatus { initial, loading, success, failure }

/// Sentinel so copyWith can tell "leave as is" from "set to null".
const Object _unset = Object();

class WalkinSlotsState extends Equatable {
  final WalkinSlotsStatus status;
  final WalkinSlotsModel? model;

  /// Local calendar day currently shown, `YYYY-MM-DD`.
  final String selectedDate;

  /// A date switch is in flight - the date strip stays up, the grid spins.
  final bool isTimesLoading;
  final String message;

  /// UTC start of the first chip in the highlighted run.
  final DateTime? selectedStart;

  const WalkinSlotsState({
    this.status = WalkinSlotsStatus.initial,
    this.model,
    this.selectedDate = '',
    this.isTimesLoading = false,
    this.message = '',
    this.selectedStart,
  });

  List<WalkinTime> get times => model?.times ?? const [];

  WalkinOperations get operations =>
      model?.operations ?? const WalkinOperations();

  /// Chips this visit needs, from the shop's block and buffer.
  int get requiredSlots => requiredSlotCount(
    totalDurationMinutes: model?.summary.totalDurationMinutes ?? 0,
    blockMinutes: operations.blockMinutes,
    bufferMinutes: operations.bufferMinutes,
  );

  bool get isDayClosed {
    final dates = model?.window.dates ?? const <WalkinDate>[];
    for (final date in dates) {
      if (date.date == selectedDate) return date.isClosed;
    }
    return false;
  }

  /// Index of the first chip in the highlighted run, or -1.
  int get selectedStartIndex {
    if (selectedStart == null) return -1;
    return times.indexWhere((slot) => slot.start == selectedStart);
  }

  /// Indexes to paint as selected.
  Set<int> get selectedIndexes {
    final start = selectedStartIndex;
    if (start < 0) return const {};
    return runIndexes(start, requiredSlots).toSet();
  }

  /// The chip starts to post as `slots`.
  List<DateTime> get selectedStarts {
    final start = selectedStartIndex;
    if (start < 0) return const [];
    return runIndexes(start, requiredSlots)
        .where((index) => index < times.length)
        .map((index) => times[index].start)
        .whereType<DateTime>()
        .toList();
  }

  /// End of the visit - the last highlighted chip already includes the buffer.
  DateTime? get selectedEnd {
    final indexes = selectedIndexes;
    if (indexes.isEmpty) return null;
    final last = indexes.reduce((a, b) => a > b ? a : b);
    return last < times.length ? times[last].end : null;
  }

  WalkinSlotsState copyWith({
    WalkinSlotsStatus? status,
    WalkinSlotsModel? model,
    String? selectedDate,
    bool? isTimesLoading,
    String? message,
    Object? selectedStart = _unset,
  }) {
    return WalkinSlotsState(
      status: status ?? this.status,
      model: model ?? this.model,
      selectedDate: selectedDate ?? this.selectedDate,
      isTimesLoading: isTimesLoading ?? this.isTimesLoading,
      message: message ?? this.message,
      selectedStart: selectedStart == _unset
          ? this.selectedStart
          : selectedStart as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    model,
    selectedDate,
    isTimesLoading,
    message,
    selectedStart,
  ];
}
