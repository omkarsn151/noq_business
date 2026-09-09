import 'package:noq_business/core/utils/date_formats.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// The window the Insights screen measures. Sent as the `period` query param.
enum InsightsPeriod {
  today('today', 'Today'),
  yesterday('yesterday', 'Yesterday'),
  thisWeek('this_week', 'This week'),
  lastWeek('last_week', 'Last week'),
  thisMonth('this_month', 'This month'),
  lastMonth('last_month', 'Last month');

  /// What the API expects.
  final String value;

  /// What the pill and the filter sheet show.
  final String label;

  const InsightsPeriod(this.value, this.label);
}

/// Everything the Insights screen needs, in one payload.
class InsightsModel {
  final InsightsHeader header;
  final InsightsCards cards;
  final InsightsChart chart;
  final InsightsCustomerFlow customerFlow;

  const InsightsModel({
    this.header = const InsightsHeader(),
    this.cards = const InsightsCards(),
    this.chart = const InsightsChart(),
    this.customerFlow = const InsightsCustomerFlow(),
  });

  /// Reads the `{ success, message, data }` envelope the API wraps every
  /// payload in.
  factory InsightsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return InsightsModel(
      header: InsightsHeader.fromJson(data?['header'] as Map<String, dynamic>?),
      cards: InsightsCards.fromJson(data?['cards'] as Map<String, dynamic>?),
      chart: InsightsChart.fromJson(data?['chart'] as Map<String, dynamic>?),
      customerFlow: InsightsCustomerFlow.fromJson(
        data?['customer_flow'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Which period the numbers cover, in the shop's own timezone.
class InsightsHeader {
  /// Human label for the selected filter, e.g. 'This Week'.
  final String period;

  final DateTime? periodStart;
  final DateTime? periodEnd;

  /// Label for the window the change pills compare against, e.g. 'Last Week'.
  final String comparisonPeriod;

  /// IANA timezone of the shop - day boundaries use this, not UTC.
  final String timezone;

  const InsightsHeader({
    this.period = '',
    this.periodStart,
    this.periodEnd,
    this.comparisonPeriod = '',
    this.timezone = '',
  });

  factory InsightsHeader.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InsightsHeader();
    return InsightsHeader(
      period: json['period']?.toString() ?? '',
      periodStart: DateTime.tryParse(json['period_start']?.toString() ?? ''),
      periodEnd: DateTime.tryParse(json['period_end']?.toString() ?? ''),
      comparisonPeriod: json['comparison_period']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
    );
  }

  /// 'Sep 1 - Sep 7' - the span the numbers below describe.
  String get rangeLabel {
    if (periodStart == null || periodEnd == null) return period;
    if (periodStart == periodEnd) return formatDayMonth(periodStart!);
    return '${formatDayMonth(periodStart!)} - ${formatDayMonth(periodEnd!)}';
  }
}

/// The four hero tiles at the top of the screen.
class InsightsCards {
  final InsightsCard customersServed;
  final InsightsCard avgWaitTime;
  final InsightsCard avgServiceTime;
  final InsightsCard queueEfficiency;

  const InsightsCards({
    this.customersServed = const InsightsCard(),
    this.avgWaitTime = const InsightsCard(),
    this.avgServiceTime = const InsightsCard(),
    this.queueEfficiency = const InsightsCard(),
  });

  factory InsightsCards.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InsightsCards();
    return InsightsCards(
      customersServed: InsightsCard.fromJson(
        json['customers_served'] as Map<String, dynamic>?,
      ),
      avgWaitTime: InsightsCard.fromJson(
        json['avg_wait_time'] as Map<String, dynamic>?,
      ),
      avgServiceTime: InsightsCard.fromJson(
        json['avg_service_time'] as Map<String, dynamic>?,
      ),
      queueEfficiency: InsightsCard.fromJson(
        json['queue_efficiency'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// Which way a metric moved against the comparison period.
enum InsightsChangeDirection { up, down, same }

/// One hero tile, with an optional comparison against the previous period.
class InsightsCard {
  /// Counts arrive as integers, times and efficiency as decimal strings. Null
  /// means there was nothing to measure - it must not be shown as zero.
  final String? value;

  /// 'min' for the time cards, '%' for efficiency, null for plain counts.
  final String? unit;

  /// Percent change as a decimal string ('14.00'), or null when the previous
  /// period had nothing to compare against.
  final String? changePercent;

  final InsightsChangeDirection? changeDirection;

  const InsightsCard({
    this.value,
    this.unit,
    this.changePercent,
    this.changeDirection,
  });

  factory InsightsCard.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InsightsCard();
    return InsightsCard(
      value: json['value']?.toString(),
      unit: json['unit']?.toString(),
      changePercent: json['change_percent']?.toString(),
      changeDirection: switch (json['change_direction']?.toString()) {
        'up' => InsightsChangeDirection.up,
        'down' => InsightsChangeDirection.down,
        'same' => InsightsChangeDirection.same,
        _ => null,
      },
    );
  }

  /// '986' / '18.0 min' / '93.4%' / '—' when the API had nothing to report.
  String get displayValue {
    final raw = value;
    if (raw == null || raw.isEmpty) return '—';

    final number = double.tryParse(raw);
    return switch (unit) {
      '%' => '${number == null ? raw : _trimZero(number.toStringAsFixed(1))}%',
      null || '' => number == null ? raw : _withSeparators(number),
      _ => '$raw $unit',
    };
  }

  /// '↑ 14% vs Last Week', or null when there is no comparison to show.
  String? changeLabel(String comparisonPeriod) {
    final percent = double.tryParse(changePercent ?? '');
    if (percent == null || changeDirection == null) return null;

    final arrow = switch (changeDirection!) {
      InsightsChangeDirection.up => '↑ ',
      InsightsChangeDirection.down => '↓ ',
      InsightsChangeDirection.same => '',
    };
    final magnitude = _trimZero(percent.abs().toStringAsFixed(1));
    final against = comparisonPeriod.isEmpty
        ? ''
        : ' vs $comparisonPeriod';

    if (changeDirection == InsightsChangeDirection.same) {
      return 'No change$against';
    }
    return '$arrow$magnitude%$against';
  }

  /// True when the movement is worth celebrating. For the wait and service
  /// time cards a drop is the good outcome, so they pass [lowerIsBetter].
  bool isImprovement({bool lowerIsBetter = false}) {
    return switch (changeDirection) {
      InsightsChangeDirection.up => !lowerIsBetter,
      InsightsChangeDirection.down => lowerIsBetter,
      _ => false,
    };
  }
}

/// Queue Performance - one point per shop-local day in the period.
class InsightsChart {
  final List<InsightsChartPoint> points;

  const InsightsChart({this.points = const []});

  factory InsightsChart.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InsightsChart();
    return InsightsChart(
      points: (json['points'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(InsightsChartPoint.fromJson)
          .toList(),
    );
  }

  List<double> get joined => [for (final p in points) p.joined.toDouble()];
  List<double> get served => [for (final p in points) p.served.toDouble()];
  List<double> get waiting => [for (final p in points) p.waiting.toDouble()];
}

/// One day on the Queue Performance chart.
class InsightsChartPoint {
  final DateTime? date;
  final int joined;
  final int served;

  /// Live count for the current day; always 0 for past days.
  final int waiting;

  const InsightsChartPoint({
    this.date,
    this.joined = 0,
    this.served = 0,
    this.waiting = 0,
  });

  factory InsightsChartPoint.fromJson(Map<String, dynamic> json) {
    return InsightsChartPoint(
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      joined: (json['joined'] as num?)?.toInt() ?? 0,
      served: (json['served'] as num?)?.toInt() ?? 0,
      waiting: (json['waiting'] as num?)?.toInt() ?? 0,
    );
  }

  /// 'Mon' - used when the period spans a week or less.
  String get weekdayLabel =>
      date == null ? '' : _weekdayNames[date!.weekday - 1];

  /// 'Sep 1' - used for the month long periods.
  String get dayMonthLabel => date == null ? '' : formatDayMonth(date!);
}

/// The five row Customer Flow breakdown.
class InsightsCustomerFlow {
  final int joinedQueue;

  /// Always the live queue - this one ignores the selected period.
  final int currentlyWaiting;

  final int served;
  final int cancelled;
  final int noShow;

  const InsightsCustomerFlow({
    this.joinedQueue = 0,
    this.currentlyWaiting = 0,
    this.served = 0,
    this.cancelled = 0,
    this.noShow = 0,
  });

  factory InsightsCustomerFlow.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const InsightsCustomerFlow();
    return InsightsCustomerFlow(
      joinedQueue: (json['joined_queue'] as num?)?.toInt() ?? 0,
      currentlyWaiting: (json['currently_waiting'] as num?)?.toInt() ?? 0,
      served: (json['served'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      noShow: (json['no_show'] as num?)?.toInt() ?? 0,
    );
  }
}

/// '93.0' -> '93', '93.4' -> '93.4'
String _trimZero(String value) =>
    value.endsWith('.0') ? value.substring(0, value.length - 2) : value;

/// 1248 -> '1,248'
String _withSeparators(double value) {
  final digits = value.truncate().abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
