import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class StatStripCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const StatStripCard({
    super.key,
    required this.label,
    required this.value,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.75.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 1.25.w,
              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2.w)              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(value, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
