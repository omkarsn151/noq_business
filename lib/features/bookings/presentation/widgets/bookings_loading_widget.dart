import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while a bookings tab is loading, shaped to
/// match [BookingCard] so the real list doesn't jump into place.
class BookingsLoadingWidget extends StatelessWidget {
  const BookingsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 4.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (_, _) => const _BookingCardSkeleton(),
      ),
    );
  }
}

class _BookingCardSkeleton extends StatelessWidget {
  const _BookingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.circle(size: 12.5.w),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(width: 35.w),
                    SizedBox(height: 0.8.h),
                    Row(
                      children: [
                        Bone(
                          width: 18.w,
                          height: 2.5.h,
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                        SizedBox(width: 2.w),
                        Bone(
                          width: 14.w,
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
          SizedBox(height: 1.5.h),
          Bone.text(width: 45.w),
          SizedBox(height: 1.6.h),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          SizedBox(height: 1.6.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Row(
              children: [
                Expanded(
                  child: Bone(
                    height: 5.h,
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Bone(
                    height: 5.h,
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
