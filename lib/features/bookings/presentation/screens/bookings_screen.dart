import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_pill_tab_bar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/bookings/bloc/bookings_bloc.dart';
import 'package:noq_business/features/bookings/bloc/bookings_event.dart';
import 'package:noq_business/features/bookings/bloc/bookings_state.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: BookingStatus.values.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_onTabChanged);
    context.read<BookingsBloc>().add(
      BookingsRequested(status: BookingStatus.values.first, refresh: true),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Loads a tab the first time it is opened.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<BookingsBloc>().add(
      BookingsRequested(status: BookingStatus.values[_tabController.index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        showLeading: false,
        title: 'Bookings',
        subtitle: 'Check your bookings, requests and rejected details',
      ),
      body: SafeArea(
        child: BlocBuilder<BookingsBloc, BookingsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                AppPillTabBar(
                  controller: _tabController,
                  labels: [
                    for (final status in BookingStatus.values)
                      '${status.label} ${state.counts.countFor(status)}',
                  ],
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      for (final status in BookingStatus.values)
                        _BookingsList(
                          status: status,
                          tab: state.tabFor(status),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final BookingStatus status;
  final BookingsTabState tab;

  const _BookingsList({required this.status, required this.tab});

  void _loadFirstPage(BuildContext context) {
    context.read<BookingsBloc>().add(
      BookingsRequested(status: status, refresh: true),
    );
  }

  /// Requests the next page once the list is scrolled near its end.
  bool _onScroll(BuildContext context, ScrollNotification notification) {
    final position = notification.metrics;
    if (position.axis != Axis.vertical) return false;

    if (tab.hasMore &&
        !tab.isLoadingMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      context.read<BookingsBloc>().add(
        BookingsNextPageRequested(status: status),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (tab.status == BookingsTabStatus.initial ||
        tab.status == BookingsTabStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tab.status == BookingsTabStatus.failure) {
      return _BookingsMessage(
        message: tab.message,
        onRetry: () => _loadFirstPage(context),
      );
    }

    if (tab.bookings.isEmpty) {
      return _BookingsMessage(
        message: 'No ${status.emptyLabel} bookings',
        onRetry: () => _loadFirstPage(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadFirstPage(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 4.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: tab.bookings.length + (tab.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            if (index == tab.bookings.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final booking = tab.bookings[index];
            return BookingCard(
              customerName: booking.customerName,
              serviceName: booking.serviceLabel,
              duration: booking.durationLabel,
              startTime: formatRelativeDateTime(booking.scheduledStart),
              endTime: formatRelativeDateTime(booking.scheduledEnd),
              status: booking.status ?? status,
              isWalkIn: booking.isWalkIn,
              isRescheduleRequest: booking.isRescheduleRequest,
              requestedStartTime: formatRelativeDateTime(
                booking.requestedStart,
              ),
              requestedEndTime: formatRelativeDateTime(booking.requestedEnd),
              onTap: () => context.push('/bookings/${booking.id}'),
              // TODO: wire up once the action endpoints are available. Regular
              // rows go to POST v1/business/bookings/{id}/actions, reschedule
              // rows to POST
              // v1/business/reschedule-requests/{reschedule_request_id}/approve-reject.
              onReject: () {},
              onApprove: () {},
            );
          },
        ),
      ),
    );
  }
}

class _BookingsMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BookingsMessage({required this.message, required this.onRetry});

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
