import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/bookings/data/booking_detail_status.dart';

/// Pill showing the booking's life stage - tinted icon and label.
class BookingStatusChip extends StatelessWidget {
  final BookingDetailStatus status;

  const BookingStatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case BookingDetailStatus.confirmed:
      case BookingDetailStatus.completed:
        return AppColors.success;
      case BookingDetailStatus.pending:
      case BookingDetailStatus.inProgress:
        return AppColors.orange;
      case BookingDetailStatus.rejected:
      case BookingDetailStatus.noShow:
        return AppColors.error;
      case BookingDetailStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case BookingDetailStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingDetailStatus.completed:
        return Icons.task_alt_rounded;
      case BookingDetailStatus.pending:
        return Icons.schedule_rounded;
      case BookingDetailStatus.inProgress:
        return Icons.play_circle_outline;
      case BookingDetailStatus.rejected:
        return Icons.cancel_outlined;
      case BookingDetailStatus.noShow:
        return Icons.person_off_outlined;
      case BookingDetailStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13.sp, color: color),
          SizedBox(width: 1.5.w),
          Text(
            status.label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: color),
          ),
        ],
      ),
    );
  }
}
