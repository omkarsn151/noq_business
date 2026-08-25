import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';

/// Booking request card - customer, service details, slot range and a footer
/// that changes with the booking [status].
class BookingCard extends StatelessWidget {
  final String customerName;
  final String serviceName;
  final String duration;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;

  const BookingCard({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.onReject,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.8.h),
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
              Container(
                width: 12.5.w,
                height: 12.5.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline,
                  size: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 0.8.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 0.6.h,
                      children: [
                        _BookingChip(label: serviceName),
                        _BookingChip(label: duration),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _SlotTime(time: startTime),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                child: Icon(
                  Icons.arrow_forward,
                  size: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              _SlotTime(time: endTime),
            ],
          ),
          SizedBox(height: 1.6.h),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          SizedBox(height: 1.6.h),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reject',
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 5.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.5.w),
                    ),
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: AppButton(
                  label: 'Approve',
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.5.w),
                    ),
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case BookingStatus.approved:
        return _StatusLabel(
          icon: Icons.check,
          color: AppColors.success,
          label: 'Approved',
        );
      case BookingStatus.rejected:
        return _StatusLabel(
          icon: Icons.cancel,
          color: AppColors.error,
          label: 'Rejected',
        );
      case BookingStatus.cancelled:
        return _StatusLabel(
          icon: Icons.block,
          color: AppColors.textSecondary,
          label: 'Cancelled',
        );
    }
  }
}

class _BookingChip extends StatelessWidget {
  final String label;

  const _BookingChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SlotTime extends StatelessWidget {
  final String time;

  const _SlotTime({required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 2.w),
        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatusLabel({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 2.w),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color, fontSize: 14.sp),
        ),
      ],
    );
  }
}
