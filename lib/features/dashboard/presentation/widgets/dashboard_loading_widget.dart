import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while the dashboard is loading, shaped to
/// match [_DashboardContent] so the real data doesn't jump into place.
class DashboardLoadingWidget extends StatelessWidget {
  const DashboardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 18.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Bone.text(width: 20.w),
                          Bone.text(width: 14.w, fontSize: 24),
                          Bone(
                            width: 18.w,
                            height: 3.h,
                            borderRadius: BorderRadius.circular(6.w),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 18.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.1.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.w),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone.text(width: 12.w),
                          SizedBox(height: 1.5.h),
                          Bone.text(width: 16.w, fontSize: 20),
                          SizedBox(height: 1.5.h),
                          Bone(width: double.infinity, height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Bone(
              width: double.infinity,
              height: 9.h,
              borderRadius: BorderRadius.circular(5.w),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(width: 16.w, fontSize: 16),
                Bone.text(width: 12.w),
              ],
            ),
            SizedBox(height: 1.5.h),
            SizedBox(
              height: 14.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
                itemBuilder: (_, _) => Container(
                  width: 24.w,
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Bone.circle(size: 14.w),
                      SizedBox(height: 0.95.h),
                      Bone.text(width: 14.w),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(width: 16.w, fontSize: 16),
                Bone.text(width: 12.w),
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
      ),
    );
  }
}
