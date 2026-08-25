import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Gradient highlight card showing today's booking count with a comparison
/// chip underneath.
class TodaysBookingCard extends StatelessWidget {
  final String title;
  final String count;
  final String comparisonLabel;

  const TodaysBookingCard({
    super.key,
    required this.title,
    required this.count,
    required this.comparisonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.background,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            count,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: AppColors.background),
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
            decoration: BoxDecoration(
              color: AppColors.overlayLight,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Text(
              comparisonLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.background,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
