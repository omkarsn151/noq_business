import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while services are loading, shaped to match
/// [ServiceListCard].
class ServicesLoadingWidget extends StatelessWidget {
  const ServicesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 12.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (_, _) => const _ServiceCardSkeleton(),
      ),
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

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
          Bone(
            width: 16.w,
            height: 16.w,
            borderRadius: BorderRadius.circular(3.w),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 35.w),
                SizedBox(height: 0.5.h),
                Bone.text(width: 25.w),
                SizedBox(height: 0.5.h),
                Bone.text(width: 45.w),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Bone(
            width: 12.w,
            height: 2.5.h,
            borderRadius: BorderRadius.circular(4.w),
          ),
        ],
      ),
    );
  }
}
