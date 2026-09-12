import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_info_row.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/date_formats.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_bloc.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_state.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_bloc.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_event.dart';
import 'package:noq_business/features/bookings/bloc/booking_details_state.dart';
import 'package:noq_business/features/bookings/bloc/bookings_bloc.dart';
import 'package:noq_business/features/bookings/bloc/bookings_event.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';
import 'package:noq_business/features/bookings/data/booking_detail_model.dart';
import 'package:noq_business/features/bookings/data/booking_detail_status.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/presentation/booking_action_flow.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_details_loading_widget.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_status_chip.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<BookingDetailsBloc>().add(
      BookingDetailsRequested(bookingId: widget.bookingId),
    );
  }

  void _run(BookingAction action, BookingDetailModel details) {
    runBookingAction(
      context,
      bookingId: widget.bookingId,
      action: action,
      isWalkIn: details.booking.isWalkIn,
    );
  }

  /// Repaints this screen with the new status and action flags, and drops the
  /// list's cache so the tabs behind are right when the owner pops back.
  void _onActionSettled(BuildContext context, BookingActionState state) {
    if (state is BookingActionSuccess) {
      AppSnackbar.success(context, state.message);
      _load();
      // A refresh drops *every* cached tab - the status named here only picks
      // which one reloads eagerly, and Pending is the one the owner is most
      // likely behind. The rest refetch as they come back into view.
      context.read<BookingsBloc>().add(
        const BookingsRefreshRequested(status: BookingStatus.pending),
      );
    } else if (state is BookingActionFailure) {
      AppSnackbar.error(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingActionBloc, BookingActionState>(
      listener: _onActionSettled,
      child: BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
        builder: (context, state) {
          final details = state is BookingDetailsSuccess ? state.details : null;

          return Scaffold(
            appBar: AppAppBar(
              title: 'Booking Details',
              actions: [
                // Straight off the API flags: can_reschedule is true only on a
                // confirmed booking, can_cancel on pending and confirmed too.
                if (details != null && details.actions.hasMenu)
                  _DetailsMenu(
                    actions: details.actions,
                    onSelected: (action) => _run(action, details),
                  ),
              ],
            ),
            body: SafeArea(child: _buildBody(state)),
            bottomNavigationBar: details == null
                ? null
                : BlocBuilder<BookingActionBloc, BookingActionState>(
                    builder: (context, actionState) => _DetailsActions(
                      actions: details.actions,
                      // can_start stays true for another day's booking, but a
                      // customer is only a no-show once their slot has gone.
                      canNoShow:
                          details.actions.canNoShow &&
                          hasSlotPassed(details.schedule.scheduledEnd),
                      busyAction: actionState is BookingActionInProgress
                          ? actionState.action
                          : null,
                      onSelected: (action) => _run(action, details),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BookingDetailsState state) {
    if (state is BookingDetailsInitial || state is BookingDetailsLoading) {
      return const BookingDetailsLoadingWidget();
    }

    if (state is BookingDetailsFailure) {
      return _DetailsMessage(message: state.message, onRetry: _load);
    }

    final details = (state as BookingDetailsSuccess).details;
    return _DetailsBody(
      details: details,
      onAction: (action) => _run(action, details),
    );
  }
}

/// The Reschedule / Cancel overflow in the app bar.
class _DetailsMenu extends StatelessWidget {
  final BookingDetailActions actions;
  final ValueChanged<BookingAction> onSelected;

  const _DetailsMenu({required this.actions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookingAction>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        if (actions.canReschedule)
          PopupMenuItem(
            value: BookingAction.reschedule,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Reschedule Booking',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        if (actions.canReschedule && actions.canCancel)
          const PopupMenuDivider(height: 1, color: AppColors.border),
        if (actions.canCancel)
          PopupMenuItem(
            value: BookingAction.cancel,
            child: Row(
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 16.sp,
                  color: AppColors.error,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Cancel Booking',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
      ],
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.sp)),
      menuPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      color: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 4,
      shadowColor: AppColors.borderLight,
      position: PopupMenuPosition.under,
      icon: Icon(Icons.more_vert, size: 18.sp, color: AppColors.textPrimary),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final BookingDetailModel details;

  /// Fires the reschedule-request answer, which lives in the scroll body
  /// rather than the bottom bar.
  final ValueChanged<BookingAction> onAction;

  const _DetailsBody({required this.details, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final cancellation = details.cancellation;
    final rejection = details.rejection;
    final rescheduleRequest = details.rescheduleRequest;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookingHeaderCard(booking: details.booking),
          SizedBox(height: 1.5.h),
          _CustomerCard(customer: details.customer),
          SizedBox(height: 1.5.h),
          _AppointmentCard(details: details),
          SizedBox(height: 1.5.h),
          _PaymentCard(payment: details.payment),
          if (rescheduleRequest != null) ...[
            SizedBox(height: 1.5.h),
            _RescheduleRequestCard(
              request: rescheduleRequest,
              actions: details.actions,
              onAction: onAction,
            ),
          ],
          if (cancellation != null) ...[
            SizedBox(height: 1.5.h),
            _CancellationCard(cancellation: cancellation),
          ],
          if (rejection != null) ...[
            SizedBox(height: 1.5.h),
            _RejectionCard(rejection: rejection),
          ],
        ],
      ),
    );
  }
}

/// Shared card shell - white, rounded, hairline border and a soft shadow.
class _DetailsCard extends StatelessWidget {
  final Widget child;

  const _DetailsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
      ),
      child: child,
    );
  }
}

/// Section heading used above the grouped rows inside a card.
class _CardTitle extends StatelessWidget {
  final String title;

  const _CardTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _BookingHeaderCard extends StatelessWidget {
  final BookingDetailIdentity booking;

  const _BookingHeaderCard({required this.booking});

  /// 'Booked today' for the recent ones, 'Booked on 23 Jun' further back.
  String? get _bookedLabel {
    if (booking.bookedAt == null) return null;
    final day = formatRelativeDay(booking.bookedAt);
    const relative = {'Today', 'Tomorrow', 'Yesterday'};
    return relative.contains(day)
        ? 'Booked ${day.toLowerCase()}'
        : 'Booked on $day';
  }

  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 13.sp,
      color: AppColors.textSecondary,
    );
    final bookedLabel = _bookedLabel;

    return _DetailsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking ID', style: captionStyle),
                SizedBox(height: 0.4.h),
                Text(
                  '#${booking.reference}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
                if (bookedLabel != null) ...[
                  SizedBox(height: 0.4.h),
                  Text(bookedLabel, style: captionStyle),
                ],
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BookingStatusChip(status: booking.status),
              if (booking.isWalkIn) ...[
                SizedBox(height: 0.8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: Text(
                    'Walk-in',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final BookingDetailCustomer customer;

  const _CustomerCard({required this.customer});

  Future<void> _call(BuildContext context) async {
    final phone = customer.phone?.trim();
    if (phone == null || phone.isEmpty) return;

    try {
      final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
      if (!launched && context.mounted) {
        AppSnackbar.error(context, 'Could not place the call');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Could not place the call');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      child: Row(
        children: [
          _CustomerAvatar(customer: customer),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (customer.hasPhone) ...[
                  SizedBox(height: 0.4.h),
                  Text(
                    customer.phone!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (customer.hasPhone) ...[
            SizedBox(width: 2.w),
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _call(context),
                child: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: Icon(
                    Icons.call,
                    size: 16.sp,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final BookingDetailCustomer customer;

  const _CustomerAvatar({required this.customer});

  @override
  Widget build(BuildContext context) {
    final initials = customer.initials;
    final placeholder = Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: initials.isEmpty
          ? Icon(
              Icons.person_outline,
              size: 16.sp,
              color: AppColors.textSecondary,
            )
          : Text(
              initials,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.chartPrimary),
            ),
    );

    return ClipOval(
      child: SizedBox(
        width: 14.w,
        height: 14.w,
        child: customer.hasPhoto
            ? Image.network(
                customer.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              )
            : placeholder,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final BookingDetailModel details;

  const _AppointmentCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final schedule = details.schedule;
    final services = details.services;

    return _DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Appointment Details'),
          SizedBox(height: 0.5.h),
          AppInfoRow(
            icon: Icons.design_services_rounded,
            label: services.length > 1 ? 'Services' : 'Service',
            value: services.isEmpty
                ? '—'
                : services
                      .map(
                        (service) =>
                            '${service.name}  •  ${service.priceLabel}',
                      )
                      .join('\n'),
          ),
          AppInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: formatDayMonthYear(schedule.scheduledStart),
          ),
          AppInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: formatTime(schedule.scheduledStart),
          ),
          AppInfoRow(
            icon: Icons.timelapse_rounded,
            label: 'Duration',
            value: schedule.durationLabel,
          ),
          AppInfoRow(
            icon: Icons.person_outline,
            label: 'Requested Staff',
            value: details.staff.requestedStaffName,
          ),
          AppInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: details.location.label,
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final BookingDetailPayment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Payment'),
          SizedBox(height: 1.5.h),
          _AmountRow(label: 'Subtotal', value: payment.subtotalLabel),
          if (payment.hasDiscount)
            _AmountRow(
              label: 'Discount',
              value: payment.discountLabel,
              valueColor: AppColors.success,
            ),
          if (payment.hasPlatformFee)
            _AmountRow(label: 'Platform Fee', value: payment.platformFeeLabel),
          if (payment.hasMethod)
            _AmountRow(label: 'Method', value: payment.method!),
          if (payment.hasStatus)
            _AmountRow(label: 'Status', value: payment.status!),
          SizedBox(height: 1.h),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          SizedBox(height: 1.h),
          _AmountRow(
            label: 'Total',
            value: payment.totalLabel,
            emphasised: true,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasised;

  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasised = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasised
                ? theme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
                : theme.bodySmall?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            value,
            style: emphasised
                ? theme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )
                : theme.bodySmall?.copyWith(
                    fontSize: 14.sp,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}

/// The customer's request to move this booking - and the two buttons that
/// answer it.
///
/// Deliberately its own card rather than part of the bottom bar: answering a
/// time change is a different question from answering the booking, and the
/// owner needs the old -> new times in front of them while they decide.
class _RescheduleRequestCard extends StatelessWidget {
  final BookingDetailRescheduleRequest request;
  final BookingDetailActions actions;
  final ValueChanged<BookingAction> onAction;

  const _RescheduleRequestCard({
    required this.request,
    required this.actions,
    required this.onAction,
  });

  /// 'Sep 12, 3:00 PM - 3:45 PM', or a dash when the window is missing.
  String _window(DateTime? start, DateTime? end) {
    if (start == null) return '—';
    final from = formatRelativeDateTime(start);
    return end == null ? from : '$from - ${formatTime(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final schedule = request.schedule;

    return _DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            request.isPending ? 'Time Change Requested' : 'Time Change',
          ),
          SizedBox(height: 0.5.h),
          AppInfoRow(
            icon: Icons.person_outline,
            label: request.requestedBy.label,
            value: _orDash(request.requestedBy.name),
          ),
          AppInfoRow(
            icon: Icons.event_busy_outlined,
            label: 'Current Time',
            value: _window(schedule.previousStart, schedule.previousEnd),
          ),
          AppInfoRow(
            icon: Icons.event_available_outlined,
            label: 'Requested Time',
            value: _window(schedule.proposedStart, schedule.proposedEnd),
          ),
          AppInfoRow(
            icon: Icons.badge_outlined,
            // 'Requested', never 'Assigned' - the staff pick is only a wish
            // the shop never accepts or declines.
            label: 'Staff Requested',
            value: _orDash(request.staff.requestedStaffName),
          ),
          AppInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Asked On',
            value: formatDateTime(request.createdAt),
          ),
          if (request.isResolved) ...[
            AppInfoRow(
              icon: Icons.task_alt_rounded,
              label: request.status == BookingDetailStatus.rejected
                  ? 'Rejected On'
                  : 'Approved On',
              value: formatDateTime(request.resolvedAt),
            ),
            if (request.hasRejectionReason)
              AppInfoRow(
                icon: Icons.notes_rounded,
                label: 'Reason',
                value: _orDash(request.rejectionReason),
              ),
          ],
          if (actions.hasRescheduleAnswer) ...[
            SizedBox(height: 1.h),
            BlocBuilder<BookingActionBloc, BookingActionState>(
              builder: (context, state) {
                final busy = state is BookingActionInProgress
                    ? state.action
                    : null;

                // Refusing writes nothing to the booking, so the API can offer
                // Reject while Approve is off - the row has to read well with
                // one button as well as two.
                final buttons = <Widget>[
                  if (actions.canRejectReschedule)
                    _OutlinedAction(
                      label: 'Reject',
                      isLoading: busy == BookingAction.rejectReschedule,
                      onPressed: busy != null
                          ? null
                          : () => onAction(BookingAction.rejectReschedule),
                    ),
                  if (actions.canApproveReschedule)
                    _FilledAction(
                      label: 'Approve Change',
                      isLoading: busy == BookingAction.approveReschedule,
                      onPressed: busy != null
                          ? null
                          : () => onAction(BookingAction.approveReschedule),
                    ),
                ];

                return Row(
                  children: [
                    for (var i = 0; i < buttons.length; i++) ...[
                      if (i > 0) SizedBox(width: 3.w),
                      Expanded(child: buttons[i]),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _CancellationCard extends StatelessWidget {
  final BookingDetailCancellation cancellation;

  const _CancellationCard({required this.cancellation});

  @override
  Widget build(BuildContext context) {
    final penaltyDecision = cancellation.penaltyDecision;
    final penaltyAmount = cancellation.penaltyAmount;

    return _DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Cancellation'),
          SizedBox(height: 0.5.h),
          AppInfoRow(
            icon: Icons.person_outline,
            label: 'Cancelled By',
            value: _titleCase(cancellation.cancelledBy),
          ),
          AppInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Cancelled On',
            value: formatDateTime(cancellation.cancelledAt),
          ),
          AppInfoRow(
            icon: Icons.notes_rounded,
            label: 'Reason',
            value: _orDash(cancellation.reason),
          ),
          AppInfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'Cancellation Fee',
            value: penaltyDecision == null
                ? 'Not decided'
                : penaltyAmount == null
                ? _titleCase(penaltyDecision)
                : '${_titleCase(penaltyDecision)} · $penaltyAmount',
          ),
        ],
      ),
    );
  }
}

class _RejectionCard extends StatelessWidget {
  final BookingDetailRejection rejection;

  const _RejectionCard({required this.rejection});

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Rejection'),
          SizedBox(height: 0.5.h),
          AppInfoRow(
            icon: Icons.notes_rounded,
            label: 'Reason',
            value: _orDash(rejection.reason),
          ),
        ],
      ),
    );
  }
}

/// 'customer' -> 'Customer'
String _titleCase(String? value) {
  final text = value?.trim().replaceAll('_', ' ');
  if (text == null || text.isEmpty) return '—';
  return text[0].toUpperCase() + text.substring(1);
}

String _orDash(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? '—' : text;
}

/// Bottom bar drawn from the `actions` block the API returns, rather than from
/// the status.
class _DetailsActions extends StatelessWidget {
  final BookingDetailActions actions;

  /// [BookingDetailActions.canNoShow] narrowed by the slot having passed.
  final bool canNoShow;

  /// The action currently in flight, so only its button spins.
  final BookingAction? busyAction;
  final ValueChanged<BookingAction> onSelected;

  const _DetailsActions({
    required this.actions,
    required this.canNoShow,
    required this.busyAction,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!actions.hasAny) return const SizedBox.shrink();

    Widget outlined(String label, BookingAction action) => _OutlinedAction(
      label: label,
      isLoading: busyAction == action,
      onPressed: busyAction != null ? null : () => onSelected(action),
    );

    Widget filled(String label, BookingAction action) => _FilledAction(
      label: label,
      isLoading: busyAction == action,
      onPressed: busyAction != null ? null : () => onSelected(action),
    );

    final buttons = <Widget>[
      if (actions.canReject) outlined('Reject', BookingAction.reject),
      if (canNoShow) outlined('No Show', BookingAction.noShow),
      if (actions.canApprove) filled('Accept', BookingAction.approve),
      if (actions.canStart) filled('Start Service', BookingAction.start),
      if (actions.canComplete) filled('Complete', BookingAction.complete),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 2.h),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) SizedBox(width: 3.w),
              Expanded(child: buttons[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _OutlinedAction({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _FilledAction({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      isLoading: isLoading,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailsMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 1.5.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
