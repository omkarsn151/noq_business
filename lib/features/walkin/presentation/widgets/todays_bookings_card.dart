import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_booking_tile.dart';
import 'package:noq_business/features/walkin/data/todays_bookings_model.dart';

/// The Walk In screen's "Current Bookings" strip - the next few visits still
/// ahead of now, today. Draws whatever `bookings` holds (0 to 5 rows) and adds
/// a "View All" link once [TodaysBookingsModel.hasMoreThanShown].
class TodaysBookingsCard extends StatelessWidget {
  final TodaysBookingsModel model;
  final VoidCallback? onViewAll;
  final void Function(String bookingId)? onBookingTap;

  const TodaysBookingsCard({
    super.key,
    required this.model,
    this.onViewAll,
    this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    final bookings = model.bookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Bookings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (model.hasMoreThanShown)
              InkWell(
                onTap: onViewAll,
                child: Text(
                  'View All (${model.totalToday})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),
        if (bookings.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Center(
              child: Text(
                'No bookings left for today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return DashboardBookingTile(
                customerName: booking.customerName,
                serviceName: booking.serviceLabel,
                duration: booking.durationLabel,
                staffName: booking.staffLabel,
                time: formatTime(booking.scheduledStart),
                onTap: onBookingTap == null
                    ? null
                    : () => onBookingTap!(booking.id),
              );
            },
          ),
      ],
    );
  }
}
