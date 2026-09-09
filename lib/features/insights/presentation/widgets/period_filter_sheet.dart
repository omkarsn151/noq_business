import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/insights/data/insights_model.dart';

class PeriodFilterSheet {
  PeriodFilterSheet._();

  static Future<InsightsPeriod?> show(
    BuildContext context,
    InsightsPeriod current,
  ) {
    return showModalBottomSheet<InsightsPeriod>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (_) => _PeriodFilterSheetBody(current: current),
    );
  }
}

class _PeriodFilterSheetBody extends StatelessWidget {
  final InsightsPeriod current;

  const _PeriodFilterSheetBody({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.5.w, 1.5.h, 4.5.w, 2.5.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(0.5.w),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text('Select period', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 0.5.h),
            Text(
              'Choose the window your insights cover',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 2.h),
            for (final period in InsightsPeriod.values) ...[
              _PeriodOption(
                label: period.label,
                isSelected: period == current,
                onTap: () => Navigator.pop(context, period),
              ),
              if (period != InsightsPeriod.values.last)
                SizedBox(height: 1.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.08.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.textfieldFilledColor,
          borderRadius: BorderRadius.circular(3.08.w),
          border: Border.all(
            color: isSelected ? AppColors.chartPrimary : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 17.sp,
              color: isSelected
                  ? AppColors.chartPrimary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: 3.6.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.chartPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 19.sp,
                color: AppColors.chartPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
