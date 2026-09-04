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

  /// Caption shown next to the dot when [showLiveIndicator] is set, e.g. 'LIVE'
  /// or the shop's 'OPEN' / 'CLOSED' state.
  final String indicatorLabel;

  /// Dot and caption colour for the indicator above.
  final Color indicatorColor;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.showLiveIndicator = false,
    this.indicatorLabel = 'LIVE',
    this.indicatorColor = AppColors.live,
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
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.5.w),
              Text(
                indicatorLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: indicatorColor,
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
