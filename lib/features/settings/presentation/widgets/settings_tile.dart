import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// One settings row - rounded icon badge, title, subtitle and a chevron.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Renders the icon, badge and title in the destructive colour.
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? AppColors.error : AppColors.chartPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16.sp, color: accent),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDestructive ? AppColors.error : null,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 1.5.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
