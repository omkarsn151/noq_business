import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Outlined card showing a metric label with a growth chip and its value.
class RevenueCard extends StatelessWidget {
  final String label;
  final String value;

  /// Null hides the chip - there is nothing to compare against.
  final String? growthLabel;
  final bool isPositive;

  const RevenueCard({
    super.key,
    required this.label,
    required this.value,
    required this.growthLabel,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final growth = growthLabel;
    // AppColors has no light red, so the destructive pill borrows the same
    // primaryLight background used for delete affordances elsewhere.
    final growthColor = isPositive ? AppColors.success : AppColors.error;
    final growthBackground = isPositive
        ? AppColors.successLight
        : AppColors.primaryLight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.1.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (growth != null) ...[
                SizedBox(width: 1.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: growthBackground,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 15.sp,
                        color: growthColor,
                      ),
                      Text(
                        growth,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: growthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(value, style: Theme.of(context).textTheme.headlineLarge),
        ],
      ),
    );
  }
}
