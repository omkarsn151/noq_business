import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// One row of the customer actions breakdown.
class CustomerActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showChevron;
  final VoidCallback? onTap;

  const CustomerActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.chartPrimary),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
            if (showChevron) ...[
              SizedBox(width: 1.5.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
