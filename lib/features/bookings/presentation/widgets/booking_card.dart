import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/bookings/data/booking_detail_status.dart';

/// Everything the card can ask the screen to do. Reschedule and cancel live in
/// the overflow menu; the rest are footer buttons.
enum BookingCardAction {
  approve,
  reject,
  start,
  noShow,
  complete,
  reschedule,
  cancel,

  /// Answers a customer's request to move a booking. Separate from [approve] /
  /// [reject], which answer the booking itself.
  approveReschedule,
  rejectReschedule,
}

/// Booking request card - customer, service details, slot range and a footer
/// that changes with the booking [status].
class BookingCard extends StatelessWidget {
  final String customerName;
  final String serviceName;
  final String duration;
  final String startTime;
  final String endTime;
  final BookingDetailStatus status;

  /// Adds a 'Walk-in' chip next to the service details.
  final bool isWalkIn;

  /// Flags the card as a customer reschedule request: adds a badge, shows the
  /// current slot alongside the requested one and always offers the
  /// reject/approve actions.
  final bool isRescheduleRequest;

  /// The slot the customer asked to move to. Only used when
  /// [isRescheduleRequest] is true.
  final String? requestedStartTime;
  final String? requestedEndTime;

  /// No Show only makes sense once the booked slot has run out. The screen
  /// works this out from the booking's scheduled end.
  final bool canNoShow;

  /// An action on this booking is in flight - buttons spin and the menu is
  /// closed off.
  final bool isBusy;

  /// Opens the booking details screen.
  final VoidCallback? onTap;
  final ValueChanged<BookingCardAction>? onAction;

  const BookingCard({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.isWalkIn = false,
    this.isRescheduleRequest = false,
    this.requestedStartTime,
    this.requestedEndTime,
    this.canNoShow = false,
    this.isBusy = false,
    this.onTap,
    this.onAction,
  });

  void _fire(BookingCardAction action) => onAction?.call(action);

  /// Cancel is valid on a pending or confirmed booking, Reschedule only once
  /// it is confirmed - mirroring the `can_cancel` / `can_reschedule` flags the
  /// details endpoint returns, which list rows do not carry.
  ///
  /// Reschedule-request rows answer the customer's request rather than the
  /// booking, so they get no menu at all.
  bool get _canCancel =>
      status == BookingDetailStatus.pending ||
      status == BookingDetailStatus.confirmed;

  bool get _canReschedule => status == BookingDetailStatus.confirmed;

  bool get _hasMenu =>
      onAction != null && !isRescheduleRequest && (_canCancel || _canReschedule);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(3.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3.w),
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.8.h),
      decoration: BoxDecoration(
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
                        if (serviceName.isNotEmpty)
                          _BookingChip(label: serviceName),
                        _BookingChip(label: duration),
                        if (isWalkIn) const _BookingChip(label: 'Walk-in'),
                        if (isRescheduleRequest)
                          _BookingChip(
                            label: 'Reschedule Request',
                            icon: Icons.autorenew,
                            color: AppColors.orange.withValues(alpha: 0.12),
                            textColor: AppColors.live,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_hasMenu) ...[SizedBox(width: 1.w), _buildMenu(context)],
            ],
          ),
          SizedBox(height: 1.5.h),
          _buildSlots(context),
          SizedBox(height: 1.6.h),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          SizedBox(height: 1.6.h),
          _buildFooter(context),
        ],
      ),
    );
  }

  /// A plain booking shows its single slot. A reschedule request shows the
  /// current slot struck through above the slot the customer asked for.
  Widget _buildSlots(BuildContext context) {
    if (!isRescheduleRequest) {
      return _SlotRow(start: startTime, end: endTime);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SlotRow(
          label: 'Current',
          start: startTime,
          end: endTime,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          strikeThrough: true,
        ),
        SizedBox(height: 0.8.h),
        _SlotRow(
          label: 'Requested',
          start: requestedStartTime ?? '',
          end: requestedEndTime ?? '',
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<BookingCardAction>(
      enabled: !isBusy,
      onSelected: _fire,
      itemBuilder: (_) => [
        if (_canReschedule)
          PopupMenuItem(
            value: BookingCardAction.reschedule,
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
        if (_canReschedule && _canCancel) const PopupMenuDivider(height: 1, color: AppColors.border),
        if (_canCancel)
          PopupMenuItem(
            value: BookingCardAction.cancel,
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
      icon: Icon(Icons.more_vert, size: 17.sp, color: AppColors.textPrimary),
    );
  }

  /// Buttons follow the booking's own life stage. A reschedule request is the
  /// exception: whatever the booking's status, the row answers the request.
  Widget _buildFooter(BuildContext context) {
    if (isRescheduleRequest) {
      // On a reschedule row [status] is the *request's* own status, so a
      // waiting one is answerable and anything else is history.
      if (status != BookingDetailStatus.pending) {
        // Always qualified as the *time change*, never a bare 'Rejected':
        // turning down a new time is not turning down the booking, which is
        // usually still alive on its original slot.
        return _StatusLabel(
          icon: Icons.event_busy_outlined,
          color: AppColors.textSecondary,
          label: 'Time change rejected',
        );
      }

      return _actionRow([
        _reject(
          label: 'Reject',
          action: BookingCardAction.rejectReschedule,
        ),
        _accept(
          label: 'Approve',
          action: BookingCardAction.approveReschedule,
        ),
      ]);
    }

    switch (status) {
      case BookingDetailStatus.pending:
        return _actionRow([
          _reject(label: 'Reject'),
          _accept(label: 'Accept'),
        ]);
      case BookingDetailStatus.confirmed:
        return _actionRow([
          // Nobody can be a no-show until their slot has actually run out.
          if (canNoShow)
            _reject(label: 'No Show', action: BookingCardAction.noShow),
          _accept(label: 'Start', action: BookingCardAction.start),
        ]);
      case BookingDetailStatus.inProgress:
        return _actionRow([
          _accept(label: 'Complete', action: BookingCardAction.complete),
        ]);
      case BookingDetailStatus.completed:
        return _StatusLabel(
          icon: Icons.check_circle,
          color: AppColors.success,
          label: 'Completed',
        );
      case BookingDetailStatus.noShow:
        return _StatusLabel(
          icon: Icons.person_off_outlined,
          color: AppColors.orange,
          label: 'No Show',
        );
      case BookingDetailStatus.rejected:
        return _StatusLabel(
          icon: Icons.cancel,
          color: AppColors.error,
          label: 'Rejected',
        );
      case BookingDetailStatus.cancelled:
        return _StatusLabel(
          icon: Icons.block,
          color: AppColors.textSecondary,
          label: 'Cancelled',
        );
      case BookingDetailStatus.dismissed:
        return _StatusLabel(
          icon: Icons.timer_off_outlined,
          color: AppColors.textSecondary,
          label: 'Dismissed',
        );
    }
  }

  Widget _actionRow(List<Widget> buttons) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) SizedBox(width: 3.w),
            Expanded(child: buttons[i]),
          ],
        ],
      ),
    );
  }

  /// The outlined, secondary half of an action pair.
  Widget _reject({
    required String label,
    BookingCardAction action = BookingCardAction.reject,
  }) {
    return AppButton(
      label: label,
      isLoading: isBusy,
      onPressed: onAction == null ? null : () => _fire(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        minimumSize: Size(double.infinity, 5.h),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.5.w),
        ),
        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// The filled, primary half of an action pair.
  Widget _accept({
    required String label,
    BookingCardAction action = BookingCardAction.approve,
  }) {
    return AppButton(
      label: label,
      isLoading: isBusy,
      onPressed: onAction == null ? null : () => _fire(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        minimumSize: Size(double.infinity, 5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.5.w),
        ),
        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BookingChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  const _BookingChip({
    required this.label,
    this.icon,
    this.color = AppColors.primaryLight,
    this.textColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: textColor),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13.sp, color: textColor),
                SizedBox(width: 1.5.w),
                text,
              ],
            ),
    );
  }
}

/// A 'start → end' slot line, optionally prefixed with a label and tinted /
/// struck through so a reschedule request can show its old and new slots.
class _SlotRow extends StatelessWidget {
  final String? label;
  final String start;
  final String end;
  final Color color;
  final bool strikeThrough;
  final FontWeight? fontWeight;

  const _SlotRow({
    required this.start,
    required this.end,
    this.label,
    this.color = AppColors.textSecondary,
    this.strikeThrough = false,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: color,
      fontWeight: fontWeight,
      decorationColor: color,
    );

    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 14.sp, color: color),
        SizedBox(width: 2.w),
        if (label != null) ...[
          Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
          SizedBox(width: 1.5.w),
        ],
        Flexible(
          child: Text(
            start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
          child: Icon(Icons.arrow_forward, size: 15.sp, color: color),
        ),
        Flexible(
          child: Text(
            end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
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
