import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while ratings and reviews are loading,
/// shaped to match [RatingsSummaryHeader] and [ReviewCard].
class RatingsLoadingWidget extends StatelessWidget {
  /// Shows the summary header skeleton - only when the caller already has a
  /// score tile to render, mirroring how the real list only shows one when
  /// [RatingsAndReviewsScreen.summary] was passed in.
  final bool showSummary;

  const RatingsLoadingWidget({super.key, this.showSummary = false});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 12.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: (showSummary ? 1 : 0) + 5,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (context, index) {
          if (showSummary && index == 0) {
            return const _SummaryHeaderSkeleton();
          }
          return const _ReviewCardSkeleton();
        },
      ),
    );
  }
}

class _SummaryHeaderSkeleton extends StatelessWidget {
  const _SummaryHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          Bone.text(width: 14.w, fontSize: 28),
          SizedBox(height: 0.8.h),
          Bone.text(width: 26.w),
          SizedBox(height: 0.8.h),
          Bone.text(width: 20.w),
        ],
      ),
    );
  }
}

class _ReviewCardSkeleton extends StatelessWidget {
  const _ReviewCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.circle(size: 11.w),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 30.w),
                    SizedBox(height: 0.3.h),
                    Bone.text(width: 18.w),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Bone(
                width: 10.w,
                height: 2.5.h,
                borderRadius: BorderRadius.circular(4.w),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Bone.text(width: 26.w),
          SizedBox(height: 1.4.h),
          Bone.text(width: double.infinity),
          SizedBox(height: 0.5.h),
          Bone.text(width: 60.w),
        ],
      ),
    );
  }
}
