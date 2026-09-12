import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:noq_business/features/dashboard/bloc/dashboard_event.dart';
import 'package:noq_business/features/dashboard/bloc/dashboard_state.dart';
import 'package:noq_business/features/dashboard/data/dashboard_model.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_booking_tile.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/circle_icon_button.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_loading_widget.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/revenue_card.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/stat_strip_card.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/todays_booking_card.dart';
import 'package:noq_business/features/staff/presentation/widgets/staff_tile.dart';

/// 'Good Morning' / 'Good Afternoon' / 'Good Evening'
String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<DashboardBloc>().add(const DashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final dashboard = state is DashboardSuccess ? state.dashboard : null;

        return Scaffold(
          appBar: AppAppBar(
            showLeading: false,
            overline: _greeting(),
            // Blank until the payload lands, so the bar does not jump.
            title: dashboard?.header.businessName ?? '',
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
                onTap: () => context.push('/business-profile'),
              ),
              SizedBox(width: 4.w),
            ],
          ),
          body: SafeArea(child: _body(state)),
        );
      },
    );
  }

  Widget _body(DashboardState state) {
    if (state is DashboardInitial || state is DashboardLoading) {
      return const DashboardLoadingWidget();
    }

    if (state is DashboardFailure) {
      return _DashboardMessage(message: state.message, onRetry: _load);
    }

    return _DashboardContent(
      dashboard: (state as DashboardSuccess).dashboard,
      onRefresh: _load,
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardModel dashboard;
  final VoidCallback onRefresh;

  const _DashboardContent({required this.dashboard, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final summary = dashboard.summary;
    final staff = dashboard.staff.items;
    final bookings = dashboard.upcomingBookings;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    child: TodaysBookingCard(
                      title: "Today's Booking",
                      count: summary.todaysBookings.countLabel,
                      comparisonLabel: summary.todaysBookings.comparisonLabel,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 4,
                    child: RevenueCard(
                      label: 'Revenue',
                      value: summary.revenue.valueLabel,
                      growthLabel: summary.revenue.growthLabel,
                      isPositive: summary.revenue.isPositive,
                      chartValues: dashboard.revenueGraph.amounts,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            StatStripCard(
              label: 'Bookings',
              value: summary.pendingBookings.countLabel,
            ),
            SizedBox(height: 3.h),
            DashboardSectionHeader(
              title: 'Staff',
              showLiveIndicator: true,
              indicatorLabel: dashboard.header.isOpen ? 'OPEN' : 'CLOSED',
              indicatorColor: dashboard.header.isOpen
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
            SizedBox(height: 1.5.h),
            if (staff.isEmpty)
              const _EmptyRow(message: 'No staff added yet')
            else
              SizedBox(
                height: 14.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: staff.length,
                  separatorBuilder: (_, _) => SizedBox(width: 2.56.w),
                  itemBuilder: (context, index) => StaffTile(
                    name: staff[index].name,
                    photoUrl: staff[index].photoUrl,
                    // `push` stacks the profile over the bottom nav - `go`
                    // would swap the shell branch out from under it.
                    onTap: () => context.push('/staff/${staff[index].id}'),
                  ),
                ),
              ),
            SizedBox(height: 3.h),
            DashboardSectionHeader(
              title: 'Bookings',
              actionLabel: 'View All',
              // `go` switches the shell branch - `push` would stack a second
              // Bookings screen over the bottom nav.
              onActionTap: () => context.go('/bookings'),
            ),
            SizedBox(height: 1.5.h),
            if (bookings.isEmpty)
              const _EmptyRow(message: 'No upcoming bookings')
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
                    onTap: () => context.push('/bookings/${booking.id}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder line for a section the shop has nothing in yet.
class _EmptyRow extends StatelessWidget {
  final String message;

  const _EmptyRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Center(
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 1.5.h),
          Center(
            child: TextButton(onPressed: onRetry, child: const Text('Retry')),
          ),
        ],
      ),
    );
  }
}
