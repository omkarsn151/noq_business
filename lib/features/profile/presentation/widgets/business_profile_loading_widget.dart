import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while the business profile overview is
/// loading, shaped to match [_ProfileContent]'s cards up through Services.
class BusinessProfileLoadingWidget extends StatelessWidget {
  const BusinessProfileLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProfileHeaderSkeleton(),
            SizedBox(height: 2.h),
            _SectionCardSkeleton(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Bone.text(width: 12.w, fontSize: 28),
                          SizedBox(height: 0.5.h),
                          Bone.text(width: 18.w),
                          SizedBox(height: 0.5.h),
                          Bone.text(width: 16.w),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(width: 1, height: 12.h, color: AppColors.borderLight),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: SizedBox(
                        height: 14.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Bone.text(width: 50.w),
                            SizedBox(height: 0.8.h),
                            Bone.text(width: 45.w),
                            SizedBox(height: 0.8.h),
                            Bone.text(width: 30.w),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            _SectionCardSkeleton(
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(height: 1.5.h),
                    const _ServiceRowSkeleton(),
                  ],
                  SizedBox(height: 2.h),
                  Bone(
                    width: double.infinity,
                    height: 5.5.h,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 6.h,
            color: AppColors.primaryLight,
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
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(width: 35.w, fontSize: 18),
                      SizedBox(height: 0.8.h),
                      Bone.text(width: 25.w),
                      SizedBox(height: 0.8.h),
                      Bone.text(width: 45.w),
                      SizedBox(height: 2.h),
                      Bone(
                        width: double.infinity,
                        height: 5.5.h,
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(child: _StatItemSkeleton()),
                    Container(width: 1, height: 5.h, color: AppColors.borderLight),
                    Expanded(child: _StatItemSkeleton()),
                    Container(width: 1, height: 5.h, color: AppColors.borderLight),
                    Expanded(child: _StatItemSkeleton()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Bone.icon(size: 18.sp),
        SizedBox(height: 0.5.h),
        Bone.text(width: 8.w),
        SizedBox(height: 0.3.h),
        Bone.text(width: 12.w),
      ],
    );
  }
}

class _ServiceRowSkeleton extends StatelessWidget {
  const _ServiceRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        children: [
          Bone.circle(size: 10.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 35.w),
                SizedBox(height: 0.4.h),
                Bone.text(width: 25.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCardSkeleton extends StatelessWidget {
  final Widget child;

  const _SectionCardSkeleton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone.text(width: 30.w, fontSize: 16),
              Bone.text(width: 14.w),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}
