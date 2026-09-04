import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Simple entry point on the Business Profile overview that opens the full
/// Staff screen. Staff are managed on their own screen rather than inline,
/// so this is a single tappable row instead of a data-bearing section.
class OverviewManageStaffCard extends StatelessWidget {
  final VoidCallback? onTap;

  const OverviewManageStaffCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Staff',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    'View and manage your team',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
