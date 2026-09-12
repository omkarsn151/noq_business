import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while the Walk In screen's "Current Bookings"
/// section is loading, shaped to match [TodaysBookingsCard].
class TodaysBookingsLoadingWidget extends StatelessWidget {
  const TodaysBookingsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone.text(width: 30.w, fontSize: 16),
              Bone.text(width: 16.w),
            ],
          ),
          SizedBox(height: 1.5.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
            itemBuilder: (_, _) => Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.75.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(5.w),
                border: Border.all(color: AppColors.borderLight, width: 1.5),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 1.25.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Bone.text(width: 30.w),
                                  SizedBox(height: 0.5.h),
                                  Bone.text(width: 40.w),
                                  SizedBox(height: 0.5.h),
                                  Bone.text(width: 20.w),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Bone.text(width: 10.w),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
