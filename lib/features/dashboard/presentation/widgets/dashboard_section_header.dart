import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Section title with an optional action on the right - either a tappable
/// label such as "View All" or a live indicator.
class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool showLiveIndicator;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.showLiveIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        if (showLiveIndicator)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: const BoxDecoration(
                  color: AppColors.live,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.5.w),
              Text(
                'LIVE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.live,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        else if (actionLabel != null)
          InkWell(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
