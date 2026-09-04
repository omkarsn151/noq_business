import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';

/// The score panel above the review list - big average, a star row and the
/// total count. Fed by the [OverviewRating] the Business Profile already loaded.
class RatingsSummaryHeader extends StatelessWidget {
  final OverviewRating summary;

  const RatingsSummaryHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final average = summary.average ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          Text(
            summary.averageLabel,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final filled = average >= index + 1;
              final half = !filled && average > index && average < index + 1;
              return Icon(
                half
                    ? Icons.star_half_rounded
                    : filled
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 18.sp,
                color: AppColors.orange,
              );
            }),
          ),
          SizedBox(height: 0.8.h),
          Text(
            summary.reviewsCountLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
