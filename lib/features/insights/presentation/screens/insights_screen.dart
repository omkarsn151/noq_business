import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/insights/bloc/insights_bloc.dart';
import 'package:noq_business/features/insights/bloc/insights_event.dart';
import 'package:noq_business/features/insights/bloc/insights_state.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';
import 'package:noq_business/features/insights/presentation/widgets/customer_actions_card.dart';
import 'package:noq_business/features/insights/presentation/widgets/insight_stat_card.dart';
import 'package:noq_business/features/insights/presentation/widgets/performance_line_chart.dart';
import 'package:noq_business/features/insights/presentation/widgets/period_filter_sheet.dart';
import 'package:noq_business/features/insights/presentation/widgets/period_selector.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<InsightsBloc>().add(const InsightsRequested(refresh: true));
  }

  Future<void> _pickPeriod(InsightsPeriod current) async {
    final picked = await PeriodFilterSheet.show(context, current);
    if (picked == null || !mounted) return;
    context.read<InsightsBloc>().add(InsightsPeriodChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<InsightsBloc, InsightsState>(
          builder: (context, state) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  period: state.period,
                  onPeriodTap: () => _pickPeriod(state.period),
                ),
                SizedBox(height: 2.5.h),
                Expanded(child: _body(state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(InsightsState state) {
    if (state is InsightsInitial || state is InsightsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is InsightsFailure) {
      return _InsightsMessage(message: state.message, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: _InsightsContent(
        insights: (state as InsightsSuccess).insights,
        period: state.period,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InsightsPeriod period;
  final VoidCallback onPeriodTap;

  const _Header({required this.period, required this.onPeriodTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              Text(
                'See how customers move through your queue',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 3.w),
        PeriodSelector(label: period.label, onTap: onPeriodTap),
      ],
    );
  }
}

class _InsightsContent extends StatelessWidget {
  final InsightsModel insights;
  final InsightsPeriod period;

  const _InsightsContent({required this.insights, required this.period});

  /// Weekday initials read better for the short windows; the month long ones
  /// need the date, and only every few labels fit across the axis.
  List<String> _xLabels(List<InsightsChartPoint> points) {
    if (points.length <= 7) {
      return [for (final p in points) p.weekdayLabel];
    }

    // Roughly six labels across, the rest blanked so they do not overlap.
    final step = (points.length / 6).ceil();
    return [
      for (var i = 0; i < points.length; i++)
        i % step == 0 || i == points.length - 1 ? points[i].dayMonthLabel : '',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cards = insights.cards;
    final comparison = insights.header.comparisonPeriod;
    final flow = insights.customerFlow;
    final points = insights.chart.points;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Both rows are flexible inside one IntrinsicHeight, so every
          // card takes the height of the tallest one.
          IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InsightStatCard(
                          icon: Icons.people_outline,
                          label: 'Customers Served',
                          value: cards.customersServed.displayValue,
                          footnote: cards.customersServed.changeLabel(
                            comparison,
                          ),
                          isFootnotePositive: cards.customersServed
                              .isImprovement(),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: InsightStatCard(
                          icon: Icons.schedule_outlined,
                          label: 'Avg Wait Time',
                          value: cards.avgWaitTime.displayValue,
                          footnote: cards.avgWaitTime.changeLabel(comparison),
                          // A shorter wait is the good outcome.
                          isFootnotePositive: cards.avgWaitTime.isImprovement(
                            lowerIsBetter: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InsightStatCard(
                          icon: Icons.timer_outlined,
                          label: 'Avg Service Time',
                          value: cards.avgServiceTime.displayValue,
                          footnote: cards.avgServiceTime.changeLabel(
                            comparison,
                          ),
                          isFootnotePositive: cards.avgServiceTime
                              .isImprovement(lowerIsBetter: true),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: InsightStatCard(
                          icon: Icons.trending_up_rounded,
                          label: 'Queue Efficiency',
                          value: cards.queueEfficiency.displayValue,
                          footnote: cards.queueEfficiency.changeLabel(
                            comparison,
                          ),
                          isFootnotePositive: cards.queueEfficiency
                              .isImprovement(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),
          _SectionCard(
            title: 'Queue Performance',
            subtitle: insights.header.rangeLabel,
            child: SizedBox(
              height: 22.h,
              child: PerformanceLineChart(
                xLabels: _xLabels(points),
                yTicks: _yTicksFor([
                  ...insights.chart.joined,
                  ...insights.chart.served,
                  ...insights.chart.waiting,
                ]),
                yLabelBuilder: _yLabel,
                series: [
                  ChartSeries(
                    label: 'Joined',
                    color: AppColors.chartPrimary,
                    values: insights.chart.joined,
                    fillArea: true,
                  ),
                  ChartSeries(
                    label: 'Served',
                    color: AppColors.chartSecondary,
                    values: insights.chart.served,
                  ),
                  ChartSeries(
                    label: 'Waiting',
                    color: AppColors.blue,
                    values: insights.chart.waiting,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          _SectionCard(
            title: 'Customer Flow',
            subtitle: 'How customers moved through the queue',
            child: Column(
              children: [
                CustomerActionRow(
                  icon: Icons.login_rounded,
                  label: 'Joined Queue',
                  value: '${flow.joinedQueue}',
                ),
                const _FlowDivider(),
                CustomerActionRow(
                  icon: Icons.hourglass_empty_rounded,
                  label: 'Currently Waiting',
                  value: '${flow.currentlyWaiting}',
                ),
                const _FlowDivider(),
                CustomerActionRow(
                  icon: Icons.check_circle_outline,
                  label: 'Served',
                  value: '${flow.served}',
                ),
                const _FlowDivider(),
                CustomerActionRow(
                  icon: Icons.cancel_outlined,
                  label: 'Cancelled',
                  value: '${flow.cancelled}',
                ),
                const _FlowDivider(),
                CustomerActionRow(
                  icon: Icons.person_off_outlined,
                  label: 'No Show',
                  value: '${flow.noShow}',
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

/// Five gridlines from zero up to a round number above the tallest series. A
/// quiet period still gets a sensible axis rather than five zeroes.
List<double> _yTicksFor(List<double> values) {
  const tickCount = 4;
  const minimumTop = 20.0;

  final peak = values.isEmpty
      ? 0.0
      : values.reduce((a, b) => a > b ? a : b);
  final target = math.max(peak, minimumTop);

  // Round the per-gridline step up to the next 1 / 2 / 5 x 10^n.
  final rawStep = target / tickCount;
  final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor())
      .toDouble();
  final normalised = rawStep / magnitude;
  final niceStep =
      (normalised <= 1
          ? 1
          : normalised <= 2
          ? 2
          : normalised <= 5
          ? 5
          : 10) *
      magnitude;

  return [for (var i = 0; i <= tickCount; i++) niceStep * i];
}

/// '1.2K' above a thousand, plain digits below.
String _yLabel(double value) {
  if (value >= 1000) {
    final thousands = value / 1000;
    final text = thousands == thousands.roundToDouble()
        ? thousands.toStringAsFixed(0)
        : thousands.toStringAsFixed(1);
    return '${text}K';
  }
  return value.toStringAsFixed(0);
}

class _FlowDivider extends StatelessWidget {
  const _FlowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderLight,
    );
  }
}

class _InsightsMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InsightsMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          if (subtitle != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}
