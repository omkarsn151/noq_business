import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while insights are loading, shaped to match
/// [_InsightsContent] - the stat card grid, the performance chart card and
/// the customer flow card.
class InsightsLoadingWidget extends StatelessWidget {
  const InsightsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCardSkeleton()),
                  SizedBox(width: 3.w),
                  Expanded(child: _StatCardSkeleton()),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCardSkeleton()),
                  SizedBox(width: 3.w),
                  Expanded(child: _StatCardSkeleton()),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),
            _SectionCardSkeleton(
              child: SizedBox(
                height: 22.h,
                child: Bone(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ),
            SizedBox(height: 2.5.h),
            _SectionCardSkeleton(
              child: Column(
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderLight,
                      ),
                    _FlowRowSkeleton(),
                  ],
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.25.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Bone.circle(size: 9.w),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 18.w),
                SizedBox(height: 0.6.h),
                Bone.text(width: 12.w, fontSize: 18),
                SizedBox(height: 0.6.h),
                Bone.text(width: 14.w),
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(width: 35.w, fontSize: 16),
          SizedBox(height: 0.5.h),
          Bone.text(width: 45.w),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}

class _FlowRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.6.h),
      child: Row(
        children: [
          Bone.icon(size: 16.sp),
          SizedBox(width: 3.w),
          Expanded(child: Bone.text(width: 30.w)),
          Bone.text(width: 8.w),
        ],
      ),
    );
  }
}
