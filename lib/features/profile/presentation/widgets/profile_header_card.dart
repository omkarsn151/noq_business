import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final OverviewProfile profile;
  final OverviewStats stats;
  final VoidCallback? onEditTap;
  final VoidCallback? onPreviewTap;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.stats,
    this.onEditTap,
    this.onPreviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primaryLight,
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 8.w),
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onEditTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 1.w),
                    Text(
                      'Edit',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(0, -7.w),
                  child: Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: profile.imageUrl != null
                        ? Image.network(
                            profile.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Icon(Icons.storefront_outlined, size: 24.sp),
                          )
                        : Icon(Icons.storefront_outlined, size: 24.sp),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: Theme.of(context).textTheme.titleMedium),
                      if (profile.categoryName.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(Icons.sell_outlined, size: 14.5.sp, color: AppColors.chartPrimary),
                            SizedBox(width: 1.w),
                            Text(
                              profile.categoryName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 0.5.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14.5.sp, color: AppColors.chartPrimary),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              profile.addressLabel,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onPreviewTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                          icon: Icon(Icons.remove_red_eye_outlined, size: 16.sp),
                          label: const Text('Preview Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatsRow(stats: stats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final OverviewStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.orange,
            value: stats.rating.averageLabel,
            label: 'Rating',
          ),
        ),
        _divider(),
        Expanded(
          child: _StatItem(
            icon: Icons.chat_bubble_outline,
            iconColor: AppColors.primary,
            value: stats.rating.totalReviews?.toString() ?? '-',
            label: 'Reviews',
          ),
        ),
        _divider(),
        Expanded(
          child: _StatItem(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.success,
            value: stats.verifiedLabel,
            label: 'Business',
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 5.h, color: AppColors.borderLight);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(height: 0.5.h),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
