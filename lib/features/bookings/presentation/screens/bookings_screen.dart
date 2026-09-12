import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_pill_tab_bar.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_bloc.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_state.dart';
import 'package:noq_business/features/bookings/bloc/bookings_bloc.dart';
import 'package:noq_business/features/bookings/bloc/bookings_event.dart';
import 'package:noq_business/features/bookings/bloc/bookings_state.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';
import 'package:noq_business/features/bookings/data/booking_model.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/presentation/booking_action_flow.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_card.dart';
import 'package:noq_business/features/bookings/presentation/widgets/bookings_loading_widget.dart';

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

  /// An action lands the booking in a different tab and shifts every count,
  /// so the whole listing is dropped and the open tab reloaded.
  void _onActionSettled(BuildContext context, BookingActionState state) {
    if (state is BookingActionSuccess) {
      AppSnackbar.success(context, state.message);
      context.read<BookingsBloc>().add(
        BookingsRefreshRequested(
          status: BookingStatus.values[_tabController.index],
        ),
      );
    } else if (state is BookingActionFailure) {
      AppSnackbar.error(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        showLeading: false,
        title: 'Bookings',
        subtitle: 'Track requests, visits in progress and past bookings',
      ),
      body: SafeArea(
        child: BlocListener<BookingActionBloc, BookingActionState>(
          listener: _onActionSettled,
          child: BlocBuilder<BookingActionBloc, BookingActionState>(
            builder: (context, actionState) {
              // The one booking currently being acted on, so only its card
              // shows a spinner.
              final busyId = actionState is BookingActionInProgress
                  ? actionState.bookingId
                  : null;

              return BlocBuilder<BookingsBloc, BookingsState>(
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
                                busyBookingId: busyId,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final BookingStatus status;
  final BookingsTabState tab;

  /// The booking with an action in flight, if any.
  final String? busyBookingId;

  const _BookingsList({
    required this.status,
    required this.tab,
    this.busyBookingId,
  });

  /// Translates a card tap into the action the API knows about, then runs the
  /// shared collect / confirm / dispatch flow.
  void _onCardAction(
    BuildContext context,
    BookingModel booking,
    BookingCardAction action,
  ) {
    const actions = {
      BookingCardAction.approve: BookingAction.approve,
      BookingCardAction.reject: BookingAction.reject,
      BookingCardAction.start: BookingAction.start,
      BookingCardAction.noShow: BookingAction.noShow,
      BookingCardAction.complete: BookingAction.complete,
      BookingCardAction.reschedule: BookingAction.reschedule,
      BookingCardAction.cancel: BookingAction.cancel,
      BookingCardAction.approveReschedule: BookingAction.approveReschedule,
      BookingCardAction.rejectReschedule: BookingAction.rejectReschedule,
    };

    runBookingAction(
      context,
      bookingId: booking.id,
      action: actions[action]!,
      isWalkIn: booking.isWalkIn,
    );
  }

  /// Empty-state illustration for a tab with no bookings.
  String _emptyImageFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppAssets.noPendingBookings;
      case BookingStatus.approved:
        return AppAssets.noApprovedBookings;
      case BookingStatus.completed:
        return AppAssets.noCompletedBookings;
      case BookingStatus.rejected:
        return AppAssets.noRejectedBookings;
      case BookingStatus.cancelled:
        return AppAssets.noCancelledBookings;
      case BookingStatus.dismissed:
        return AppAssets.noDissmissedBookings;
    }
  }

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
    if (tab.status == BookingsTabStatus.initial) {
      // An action taken on the details screen drops every cached tab, so a tab
      // can come back into view with nothing in it and nothing fetching. It
      // asks for itself here; the bloc ignores the ask if a load is already
      // running.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<BookingsBloc>().add(BookingsRequested(status: status));
      });
      return const BookingsLoadingWidget();
    }

    if (tab.status == BookingsTabStatus.loading) {
      return const BookingsLoadingWidget();
    }

    if (tab.status == BookingsTabStatus.failure) {
      return _BookingsMessage(
        message: tab.message,
        onRetry: () => _loadFirstPage(context),
      );
    }

    if (tab.bookings.isEmpty) {
      return _BookingsMessage(
        image: _emptyImageFor(status),
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
              status: booking.status,
              isWalkIn: booking.isWalkIn,
              isRescheduleRequest: booking.isRescheduleRequest,
              requestedStartTime: formatRelativeDateTime(
                booking.requestedStart,
              ),
              requestedEndTime: formatRelativeDateTime(booking.requestedEnd),
              canNoShow: hasSlotPassed(booking.scheduledEnd),
              isBusy: busyBookingId == booking.id,
              onTap: () => context.push('/bookings/${booking.id}'),
              // Reschedule rows are answerable too - the card sends
              // approve_reschedule / reject_reschedule with this same booking
              // id. A refused one sits on the read-only Rejected tab, so the
              // tab check already makes it inert.
              onAction: status.isReadOnly
                  ? null
                  : (action) => _onCardAction(context, booking, action),
            );
          },
        ),
      ),
    );
  }
}

class _BookingsMessage extends StatelessWidget {
  final String? image;
  final String message;
  final VoidCallback onRetry;

  const _BookingsMessage({this.image, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 8.h),
          if (image != null) ...[
            Center(child: Image.asset(image!, height: 30.h)),
            SizedBox(height: 2.h),
          ],
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
