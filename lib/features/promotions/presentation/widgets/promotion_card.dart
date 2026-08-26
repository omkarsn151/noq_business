import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

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
  final VoidCallback? onMenuPressed;

  const PromotionCard({
    super.key,
    required this.title,
    required this.schedule,
    required this.usedBy,
    required this.discount,
    this.imageUrl,
    this.onTap,
    this.onMenuPressed,
  });

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
                InkWell(
                  onTap: onMenuPressed,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Icon(
                      Icons.more_vert,
                      size: 17.sp,
                      color: AppColors.textPrimary,
                    ),
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
