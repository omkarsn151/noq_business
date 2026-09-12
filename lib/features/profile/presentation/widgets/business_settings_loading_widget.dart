import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering placeholder shown while business settings are loading, shaped
/// to match the form in [_BusinessSettingsScreenState._body].
class BusinessSettingsLoadingWidget extends StatelessWidget {
  const BusinessSettingsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.5.h),
            Bone.text(width: 26.w),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                for (var i = 0; i < 7; i++)
                  Bone(
                    width: 15.w,
                    height: 4.5.h,
                    borderRadius: BorderRadius.circular(18.sp),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Bone.text(width: 28.w),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(child: _FieldSkeleton()),
                SizedBox(width: 2.56.w),
                Expanded(child: _FieldSkeleton()),
              ],
            ),
            SizedBox(height: 1.5.h),
            Bone.text(width: 20.w),
            SizedBox(height: 2.h),
            Bone.text(width: 30.w),
            SizedBox(height: 0.25.h),
            Bone(
              width: double.infinity,
              height: 6.5.h,
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(height: 2.h),
            const _FieldSkeleton(),
            SizedBox(height: 2.h),
            Bone.text(width: 32.w),
            SizedBox(height: 0.25.h),
            _ChipRowSkeleton(count: 4),
            SizedBox(height: 2.h),
            Bone.text(width: 20.w),
            SizedBox(height: 0.25.h),
            _ChipRowSkeleton(count: 4),
            SizedBox(height: 2.h),
            Bone.text(width: 26.w),
            SizedBox(height: 0.25.h),
            const _ChipGridSkeleton(),
            SizedBox(height: 2.h),
            const _FieldSkeleton(),
            SizedBox(height: 2.h),
            const _FieldSkeleton(),
            SizedBox(height: 2.5.h),
            Bone(
              width: double.infinity,
              height: 6.h,
              borderRadius: BorderRadius.circular(2.5.w),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bone.text(width: 32.w),
        SizedBox(height: 0.8.h),
        Bone(
          width: double.infinity,
          height: 6.5.h,
          borderRadius: BorderRadius.circular(2.w),
        ),
      ],
    );
  }
}

class _ChipRowSkeleton extends StatelessWidget {
  final int count;

  const _ChipRowSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 2.56.w),
          Expanded(
            child: Bone(
              height: 5.h,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChipGridSkeleton extends StatelessWidget {
  const _ChipGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) SizedBox(height: 1.18.h),
          Row(
            children: [
              Expanded(
                child: Bone(
                  height: 5.h,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(width: 2.56.w),
              Expanded(
                child: Bone(
                  height: 5.h,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
