import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while booking details are loading, shaped to
/// match [_DetailsBody]'s header, customer, appointment and payment cards.
class BookingDetailsLoadingWidget extends StatelessWidget {
  const BookingDetailsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailsCardSkeleton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(width: 20.w),
                        SizedBox(height: 0.6.h),
                        Bone.text(width: 30.w, fontSize: 20),
                        SizedBox(height: 0.6.h),
                        Bone.text(width: 24.w),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Bone(
                    width: 20.w,
                    height: 3.h,
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            _DetailsCardSkeleton(
              child: Row(
                children: [
                  Bone.circle(size: 14.w),
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
                  SizedBox(width: 2.w),
                  Bone.circle(size: 12.w),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            _DetailsCardSkeleton(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: 40.w, fontSize: 16),
                  SizedBox(height: 0.5.h),
                  for (var i = 0; i < 6; i++) const _InfoRowSkeleton(),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            _DetailsCardSkeleton(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: 20.w, fontSize: 16),
                  SizedBox(height: 1.5.h),
                  for (var i = 0; i < 3; i++) const _AmountRowSkeleton(),
                  SizedBox(height: 1.h),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
                  SizedBox(height: 1.h),
                  const _AmountRowSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCardSkeleton extends StatelessWidget {
  final Widget child;

  const _DetailsCardSkeleton({required this.child});

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
      child: child,
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
                Bone.text(width: 20.w),
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

class _AmountRowSkeleton extends StatelessWidget {
  const _AmountRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Bone.text(width: 22.w), Bone.text(width: 18.w)],
      ),
    );
  }
}
