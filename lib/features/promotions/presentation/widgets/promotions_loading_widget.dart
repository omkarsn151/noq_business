import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while a promotions tab is loading, shaped to
/// match [PromotionCard].
class PromotionsLoadingWidget extends StatelessWidget {
  const PromotionsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 12.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (_, _) => const _PromotionCardSkeleton(),
      ),
    );
  }
}

class _PromotionCardSkeleton extends StatelessWidget {
  const _PromotionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Bone(
                width: 13.w,
                height: 13.w,
                borderRadius: BorderRadius.circular(2.w),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 40.w),
                    SizedBox(height: 0.8.h),
                    Bone.text(width: 35.w),
                  ],
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
              _StatSkeleton(),
              SizedBox(width: 8.w),
              _StatSkeleton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 14.w),
        SizedBox(height: 0.8.h),
        Bone(
          width: 16.w,
          height: 2.5.h,
          borderRadius: BorderRadius.circular(5.w),
        ),
      ],
    );
  }
}
