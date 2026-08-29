import 'package:flutter_test/flutter_test.dart';
import 'package:noq_business/features/walkin/data/walkin_slot_math.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

WalkinTime _slot(String start, {WalkinTimeStatus status = WalkinTimeStatus.available}) {
  final parsed = DateTime.parse(start);
  return WalkinTime(
    start: parsed,
    end: parsed.add(const Duration(minutes: 45)),
    status: status,
  );
}

void main() {
  group('requiredSlotCount', () {
    int count(int total, {int block = 30, int buffer = 15}) =>
        requiredSlotCount(
          totalDurationMinutes: total,
          blockMinutes: block,
          bufferMinutes: buffer,
        );

    test('block 30 / buffer 15 - the buffer applies once per booking', () {
      expect(count(15), 1);
      expect(count(30), 1);
      expect(count(40), 1);
      expect(count(45), 1);
      expect(count(46), 2);
      expect(count(60), 2);
      expect(count(70), 2);
      expect(count(75), 2);
      expect(count(80), 3);
      expect(count(90), 3);
      expect(count(105), 3);
      expect(count(106), 4);
    });

    test('no buffer falls back to plain ceil(total / block)', () {
      expect(count(30, buffer: 0), 1);
      expect(count(31, buffer: 0), 2);
      expect(count(60, buffer: 0), 2);
      expect(count(61, buffer: 0), 3);
    });

    test('shorter blocks need more chips', () {
      expect(count(45, block: 15, buffer: 15), 2);
      expect(count(60, block: 15, buffer: 15), 3);
    });

    test('never returns less than one chip', () {
      expect(count(0), 1);
      expect(count(10, buffer: 60), 1);
      expect(count(60, block: 0), 1);
    });
  });

  group('canStartRunAt', () {
    final times = [
      _slot('2026-08-27T09:00:00Z'),
      _slot('2026-08-27T09:30:00Z'),
      _slot('2026-08-27T10:00:00Z', status: WalkinTimeStatus.full),
      _slot('2026-08-27T10:30:00Z'),
      // 11:00 - 12:00 is lunch and is simply absent from the grid.
      _slot('2026-08-27T12:00:00Z'),
    ];

    test('accepts a run of available back-to-back chips', () {
      expect(canStartRunAt(times, 0, 1, 30), isTrue);
      expect(canStartRunAt(times, 0, 2, 30), isTrue);
    });

    test('rejects a run containing a full chip', () {
      expect(canStartRunAt(times, 1, 2, 30), isFalse);
      expect(canStartRunAt(times, 2, 1, 30), isFalse);
    });

    test('rejects a run that spans a gap in the grid', () {
      // 10:30 then 12:00 are adjacent in the list but 90 minutes apart.
      expect(canStartRunAt(times, 3, 2, 30), isFalse);
      expect(canStartRunAt(times, 3, 1, 30), isTrue);
    });

    test('rejects a run that overruns the end of the day', () {
      expect(canStartRunAt(times, 4, 2, 30), isFalse);
      expect(canStartRunAt(times, 0, 6, 30), isFalse);
    });

    test('rejects past chips', () {
      final withPast = [
        _slot('2026-08-27T09:00:00Z', status: WalkinTimeStatus.past),
        _slot('2026-08-27T09:30:00Z'),
      ];
      expect(canStartRunAt(withPast, 0, 2, 30), isFalse);
      expect(canStartRunAt(withPast, 1, 1, 30), isTrue);
    });

    test('rejects out of range and non-positive counts', () {
      expect(canStartRunAt(times, -1, 1, 30), isFalse);
      expect(canStartRunAt(times, 0, 0, 30), isFalse);
    });
  });

  group('runIndexes', () {
    test('covers count chips from the start index', () {
      expect(runIndexes(2, 3), [2, 3, 4]);
      expect(runIndexes(0, 1), [0]);
    });
  });
}
