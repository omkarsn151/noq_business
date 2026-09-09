import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Small metric card - round icon, label, value and an optional footnote.
class InsightStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? footnote;

  /// Renders [footnote] in the success colour, for growth figures.
  final bool isFootnotePositive;

  const InsightStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.footnote,
    this.isFootnotePositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.25.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 9.w,
            height: 9.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15.sp, color: AppColors.chartPrimary),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                if (footnote != null) ...[
                  SizedBox(height: 0.4.h),
                  Text(
                    footnote!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isFootnotePositive
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
