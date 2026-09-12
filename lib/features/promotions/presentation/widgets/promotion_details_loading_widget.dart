import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while promo details are loading, shaped to
/// match [_DetailsBody] - the banner header, discount timeline and
/// performance sections.
class PromotionDetailsLoadingWidget extends StatelessWidget {
  const PromotionDetailsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                    width: 16.w,
                    height: 16.w,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(width: 50.w),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Bone(
                              width: 18.w,
                              height: 2.5.h,
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            SizedBox(width: 2.w),
                            Bone(
                              width: 16.w,
                              height: 2.5.h,
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
              SizedBox(height: 2.h),
              Bone.text(width: 40.w, fontSize: 16),
              SizedBox(height: 1.h),
              const _InfoRowSkeleton(),
              const _InfoRowSkeleton(),
              SizedBox(height: 1.5.h),
              const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
              SizedBox(height: 2.h),
              Bone.text(width: 35.w, fontSize: 16),
              SizedBox(height: 1.h),
              const _InfoRowSkeleton(),
              const _InfoRowSkeleton(),
              const _InfoRowSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Bone(
            width: 9.w,
            height: 9.w,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 25.w),
                SizedBox(height: 0.4.h),
                Bone.text(width: 40.w, fontSize: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
