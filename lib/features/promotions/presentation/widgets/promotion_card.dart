import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/promotions/data/promotion_status.dart';

/// Options in the promotion card's `⋮` menu.
enum PromotionCardAction { edit, pause, resume, publish }

/// Promotion card - banner thumbnail, title, schedule and a footer with the
/// usage and discount figures.
class PromotionCard extends StatelessWidget {
  final String title;
  final String schedule;
  final String usedBy;
  final String discount;

  /// Banner shown on the left; falls back to a placeholder when null.
  final String? imageUrl;
  final VoidCallback? onTap;

  /// Drives which quick actions the `⋮` menu offers.
  final PromotionStatus status;
  final ValueChanged<PromotionCardAction>? onAction;

  const PromotionCard({
    super.key,
    required this.title,
    required this.schedule,
    required this.usedBy,
    required this.discount,
    required this.status,
    this.imageUrl,
    this.onTap,
    this.onAction,
  });

  List<PopupMenuEntry<PromotionCardAction>> _menuItems() {
    final rows = <PopupMenuItem<PromotionCardAction>>[
      _menuRow(PromotionCardAction.edit, Icons.edit_outlined, 'Edit'),
    ];
    switch (status) {
      case PromotionStatus.draft:
        rows.add(
          _menuRow(
            PromotionCardAction.publish,
            Icons.publish_outlined,
            'Publish',
          ),
        );
        break;
      case PromotionStatus.active:
        rows.add(
          _menuRow(
            PromotionCardAction.pause,
            Icons.pause_circle_outline,
            'Pause',
          ),
        );
        break;
      case PromotionStatus.inactive:
        rows.add(
          _menuRow(
            PromotionCardAction.resume,
            Icons.play_circle_outline,
            'Resume',
          ),
        );
        break;
      case PromotionStatus.expired:
        break;
    }

    final entries = <PopupMenuEntry<PromotionCardAction>>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        entries.add(
          const PopupMenuDivider(height: 1, thickness: 1, color: AppColors.borderLight),
        );
      }
      entries.add(rows[i]);
    }
    return entries;
  }

  PopupMenuItem<PromotionCardAction> _menuRow(
    PromotionCardAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<PromotionCardAction>(
      value: value,
      height: 6.h,      
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.textPrimary),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromotionBanner(imageUrl: imageUrl),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              schedule,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 1.w),
                PopupMenuButton<PromotionCardAction>(
                  onSelected: onAction,
                  itemBuilder: (_) => _menuItems(),
                  padding: EdgeInsets.all(1.w),
                  menuPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  color: AppColors.background,
                  surfaceTintColor: AppColors.background,
                  elevation: 4,
                  shadowColor: AppColors.borderLight,
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    size: 17.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.6.h),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            SizedBox(height: 1.6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromotionStat(label: 'Used by', value: usedBy),
                SizedBox(width: 8.w),
                _PromotionStat(label: 'Discount', value: discount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionBanner extends StatelessWidget {
  final String? imageUrl;

  const _PromotionBanner({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_offer_rounded,
        size: 17.sp,
        color: AppColors.chartPrimary,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(2.w),
      child: SizedBox(
        width: 13.w,
        height: 13.w,
        child: imageUrl == null
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _PromotionStat extends StatelessWidget {
  final String label;
  final String value;

  const _PromotionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 0.8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(5.w),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
