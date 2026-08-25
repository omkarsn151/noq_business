import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_booking_tile.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/circle_icon_button.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/revenue_card.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/stat_strip_card.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/todays_booking_card.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';
import 'package:noq_business/features/staff/presentation/widgets/staff_tile.dart';

// TODO: replace the hardcoded data below once the dashboard API is wired up.
const _staff = <StaffModel>[
  StaffModel(
    id: '1',
    name: 'Mike',
    worksFrom: '09:00',
    worksTo: '18:00',
    isActive: true,
    services: [],
  ),
  StaffModel(
    id: '2',
    name: 'Sara',
    worksFrom: '09:00',
    worksTo: '18:00',
    isActive: true,
    services: [],
  ),
  StaffModel(
    id: '3',
    name: 'James',
    worksFrom: '09:00',
    worksTo: '18:00',
    isActive: true,
    services: [],
  ),
  StaffModel(
    id: '4',
    name: 'Linda',
    worksFrom: '09:00',
    worksTo: '18:00',
    isActive: true,
    services: [],
  ),
];

const _bookings = [
  (
    customerName: 'Sarvam Prasad',
    serviceName: 'Haircut',
    duration: '30min',
    staffName: 'Sarangapani',
    time: '09:00 AM',
  ),
  (
    customerName: 'Anita Desai',
    serviceName: 'Manicure',
    duration: '45min',
    staffName: 'Lakshmi',
    time: '09:30 AM',
  ),
  (
    customerName: 'Ravi Kumar',
    serviceName: 'Beard Trim',
    duration: '20min',
    staffName: 'Sarangapani',
    time: '10:15 AM',
  ),
  (
    customerName: 'Priya Sharma',
    serviceName: 'Hair Spa',
    duration: '60min',
    staffName: 'Lakshmi',
    time: '11:00 AM',
  ),
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        showLeading: false,
        overline: 'Good Morning',
        title: 'Revive Saloon',
        actions: [
          CircleIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          SizedBox(width: 2.5.w),
          CircleIconButton(
            icon: Icons.person_outline,
            backgroundColor: AppColors.primary,
            iconColor: AppColors.background,
            onTap: () {},
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 5,
                      child: TodaysBookingCard(
                        title: "Today's Booking",
                        count: '12',
                        comparisonLabel: '+3 vs yesterday',
                      ),
                    ),
                    SizedBox(width: 3.w),
                    const Expanded(
                      flex: 4,
                      child: RevenueCard(
                        label: 'Revenue',
                        value: '\$450',
                        growthLabel: '18%',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              const StatStripCard(label: 'Bookings', value: '04'),
              SizedBox(height: 3.h),
              const DashboardSectionHeader(
                title: 'Staff',
                showLiveIndicator: true,
              ),
              SizedBox(height: 1.5.h),
              SizedBox(
                height: 14.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _staff.length,
                  separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
                  itemBuilder: (context, index) =>
                      StaffTile(staff: _staff[index], showDelete: false),
                ),
              ),
              SizedBox(height: 3.h),
              DashboardSectionHeader(
                title: 'Bookings',
                actionLabel: 'View All',
                onActionTap: () {},
              ),
              SizedBox(height: 1.5.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bookings.length,
                separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return DashboardBookingTile(
                    customerName: booking.customerName,
                    serviceName: booking.serviceName,
                    duration: booking.duration,
                    staffName: booking.staffName,
                    time: booking.time,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
