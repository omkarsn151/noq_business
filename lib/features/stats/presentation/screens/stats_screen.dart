import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/stats/presentation/widgets/customer_actions_card.dart';
import 'package:noq_business/features/stats/presentation/widgets/insight_stat_card.dart';
import 'package:noq_business/features/stats/presentation/widgets/performance_line_chart.dart';
import 'package:noq_business/features/stats/presentation/widgets/period_selector.dart';

// TODO: replace the hardcoded data below once the insights API is wired up.
const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _viewsByDay = [800.0, 900.0, 850.0, 1300.0, 700.0, 1000.0, 900.0];
const _actionsByDay = [300.0, 320.0, 280.0, 400.0, 250.0, 350.0, 300.0];
const _yTicks = [0.0, 400.0, 800.0, 1200.0, 1600.0];

const _customerActions = [
  (icon: Icons.calendar_month_outlined, label: 'Book now', value: '82'),
  (icon: Icons.directions_walk_rounded, label: 'Walk-in', value: '44'),
  (icon: Icons.location_on_outlined, label: 'Directions', value: '38'),
  (icon: Icons.call_outlined, label: 'Call', value: '22'),
];

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          'See how customers discover and interact with your business',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  PeriodSelector(label: 'This week', onTap: () {}),
                ],
              ),
              SizedBox(height: 2.5.h),
              // Both rows are flexible inside one IntrinsicHeight, so every
              // card takes the height of the tallest one.
              IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            child: InsightStatCard(
                              icon: Icons.visibility_outlined,
                              label: 'Profile Views',
                              value: '1,248',
                              footnote: '↑ 18% vs last week',
                              isFootnotePositive: true,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          const Expanded(
                            child: InsightStatCard(
                              icon: Icons.near_me_outlined,
                              label: 'Customer Actions',
                              value: '186',
                              footnote: 'book, walk-in, call',
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
                          const Expanded(
                            child: InsightStatCard(
                              icon: Icons.trending_up_rounded,
                              label: 'Conversion Rate',
                              value: '12.4%',
                              footnote: 'views to action',
                            ),
                          ),
                          SizedBox(width: 3.w),
                          const Expanded(
                            child: InsightStatCard(
                              icon: Icons.star_outline_rounded,
                              label: 'Top Service',
                              value: 'Standard Haircut',
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
                title: 'Performance',
                child: SizedBox(
                  height: 22.h,
                  child: PerformanceLineChart(
                    xLabels: _weekDays,
                    yTicks: _yTicks,
                    yLabelBuilder: _yLabel,
                    series: const [
                      ChartSeries(
                        label: 'Views',
                        color: AppColors.chartPrimary,
                        values: _viewsByDay,
                        fillArea: true,
                      ),
                      ChartSeries(
                        label: 'Actions',
                        color: AppColors.chartSecondary,
                        values: _actionsByDay,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              _SectionCard(
                title: 'Customer actions',
                subtitle: 'How customers interacted this week',
                child: Column(
                  children: [
                    for (var i = 0; i < _customerActions.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderLight,
                        ),
                      CustomerActionRow(
                        icon: _customerActions[i].icon,
                        label: _customerActions[i].label,
                        value: _customerActions[i].value,
                        showChevron: i == _customerActions.length - 1,
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
