import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shimmering placeholder shown while a staff profile is loading, shaped to
/// match [_StaffDetailsScreenState._body]'s header, availability, services
/// and today's bookings sections.
class StaffDetailsLoadingWidget extends StatelessWidget {
  const StaffDetailsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const _ProfileHeaderSkeleton(),
          SizedBox(height: 3.h),
          Bone.text(width: 26.w, fontSize: 16),
          SizedBox(height: 1.5.h),
          const _AvailabilityCardSkeleton(),
          SizedBox(height: 3.h),
          Bone.text(width: 20.w, fontSize: 16),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.2.h,
            children: [for (var i = 0; i < 3; i++) const _ServiceChipSkeleton()],
          ),
          SizedBox(height: 3.h),
          Bone.text(width: 32.w, fontSize: 16),
          SizedBox(height: 1.5.h),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 1.5.h),
            const _BookingRowSkeleton(),
          ],
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(4.w),
    border: Border.all(color: AppColors.borderLight),
  );
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Bone.circle(size: 16.w),
          SizedBox(width: 3.5.w),
          Expanded(child: Bone.text(width: 40.w, fontSize: 16)),
          SizedBox(width: 1.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Bone(
                width: 10.w,
                height: 2.2.h,
                borderRadius: BorderRadius.circular(4.w),
              ),
              SizedBox(height: 0.4.h),
              Bone.text(width: 22.w),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCardSkeleton extends StatelessWidget {
  const _AvailabilityCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const _AvailabilityRowSkeleton(),
          const Divider(color: AppColors.borderLight, height: 1),
          const _AvailabilityRowSkeleton(),
        ],
      ),
    );
  }
}

class _AvailabilityRowSkeleton extends StatelessWidget {
  const _AvailabilityRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.5.w),
      child: Row(
        children: [
          Bone.circle(size: 11.w),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 22.w),
                SizedBox(height: 0.5.h),
                Bone.text(width: 30.w, fontSize: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChipSkeleton extends StatelessWidget {
  const _ServiceChipSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(1.5.w, 1.5.w, 3.w, 1.5.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Bone.circle(size: 8.w),
          SizedBox(width: 2.w),
          Bone.text(width: 20.w),
        ],
      ),
    );
  }
}

class _BookingRowSkeleton extends StatelessWidget {
  const _BookingRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Bone.text(width: 12.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 35.w),
                SizedBox(height: 0.4.h),
                Bone.text(width: 30.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
