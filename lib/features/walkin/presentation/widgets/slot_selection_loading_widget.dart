import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while the slot selection bottom sheet is
/// loading its first page - the date strip and the time grid, shaped to
/// match [_DateStrip] and [_TimeGrid].
class SlotSelectionLoadingWidget extends StatelessWidget {
  const SlotSelectionLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.text(width: 35.w, fontSize: 16),
            SizedBox(height: 1.5.h),
            const _DateStripSkeleton(),
            SizedBox(height: 2.5.h),
            Bone.text(width: 45.w, fontSize: 16),
            SizedBox(height: 1.5.h),
            const SlotTimeGridLoadingWidget(),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder for just the time grid, shown while re-fetching
/// times for a newly picked date - the date strip above stays interactive.
class SlotTimeGridLoadingWidget extends StatelessWidget {
  const SlotTimeGridLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 1.5.h,
        ),
        itemCount: 9,
        itemBuilder: (_, _) => Bone(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(12.sp),
        ),
      ),
    );
  }
}

class _DateStripSkeleton extends StatelessWidget {
  const _DateStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(width: 1.5.w),
        itemBuilder: (_, _) => Container(
          width: 14.w,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Bone.text(width: 6.w),
              SizedBox(height: 1.h),
              Bone.circle(size: 6.w),
            ],
          ),
        ),
      ),
    );
  }
}
