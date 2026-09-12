import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while the review status is loading, shaped
/// to match the icon, header, summary card and timeline below it.
class ReviewStatusLoadingWidget extends StatelessWidget {
  const ReviewStatusLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 25.h),
            Bone.circle(size: 22.56.w),
            SizedBox(height: 2.5.h),
            Bone.text(width: 55.w, fontSize: 22),
            SizedBox(height: 1.h),
            Bone.text(width: 70.w),
            SizedBox(height: 2.5.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.textfieldFilledColor,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(3.5.w),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(height: 1.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Bone.text(width: 26.w),
                        Bone.text(width: 22.w),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const _StepConnectorSkeleton(),
                    const Expanded(child: _StepSkeleton()),
                  ],
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Bone(
              width: double.infinity,
              height: 6.h,
              borderRadius: BorderRadius.circular(2.5.w),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepSkeleton extends StatelessWidget {
  const _StepSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Bone.circle(size: 8.21.w),
        SizedBox(height: 0.95.h),
        Bone.text(width: 12.w),
      ],
    );
  }
}

class _StepConnectorSkeleton extends StatelessWidget {
  const _StepConnectorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.5.h),
      child: SizedBox(
        width: 8.72.w,
        height: 2,
        child: const ColoredBox(color: AppColors.borderLight),
      ),
    );
  }
}
