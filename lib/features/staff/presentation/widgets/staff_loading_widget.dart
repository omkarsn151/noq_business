import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while staff are loading, shaped to match
/// [StaffListCard].
class StaffLoadingWidget extends StatelessWidget {
  const StaffLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 12.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (_, _) => const _StaffCardSkeleton(),
      ),
    );
  }
}

class _StaffCardSkeleton extends StatelessWidget {
  const _StaffCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.circle(size: 16.w),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 35.w),
                SizedBox(height: 0.6.h),
                Bone.text(width: 30.w),
                SizedBox(height: 0.4.h),
                Bone.text(width: 25.w),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Bone(
            width: 14.w,
            height: 2.5.h,
            borderRadius: BorderRadius.circular(4.w),
          ),
        ],
      ),
    );
  }
}
