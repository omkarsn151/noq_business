import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_bloc.dart';
import 'package:noq_business/features/bookings/bloc/booking_action_event.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';
import 'package:noq_business/features/bookings/presentation/widgets/reason_bottom_sheet.dart';
import 'package:noq_business/features/bookings/presentation/widgets/verification_code_bottom_sheet.dart';
import 'package:noq_business/features/walkin/presentation/widgets/slot_selection_bottom_sheet.dart';

/// Whether the booked slot has run out.
///
/// No Show is only offered past this point - up until then the customer is
/// merely not there yet. `isBefore` compares instants, so the UTC times off
/// the wire line up with local `now` without conversion.
bool hasSlotPassed(DateTime? scheduledEnd) {
  if (scheduledEnd == null) return false;
  return scheduledEnd.isBefore(DateTime.now());
}

/// Collects whatever [action] needs, confirms the destructive ones, then hands
/// the request to [BookingActionBloc].
///
/// Input is gathered before the confirmation so the dialog can name the actual
/// choice - 'Move this booking to Sep 12, 3:00 PM?' - rather than asking the
/// owner to commit blind. Returns without dispatching if any step is dismissed.
///
/// The result is not awaited here: both screens listen to the bloc for the
/// snackbar and the reload.
///
/// [bookingId] is the booking id for every action, the two `*Reschedule` ones
/// included - the server finds the pending request itself.
Future<void> runBookingAction(
  BuildContext context, {
  required String bookingId,
  required BookingAction action,
  required bool isWalkIn,
}) async {
  final bloc = context.read<BookingActionBloc>();

  String? reason;
  String? verificationCode;
  List<DateTime>? slots;

  switch (action) {
    case BookingAction.approve:
      break;

    case BookingAction.reject:
      final note = await ReasonBottomSheet.show(
        context,
        title: 'Reject Booking',
        subtitle: 'The customer sees this note. Leave it blank to skip.',
        hintText: 'e.g. Fully booked at that time',
        confirmLabel: 'Reject Booking',
      );
      if (note == null) return;
      reason = note.isEmpty ? null : note;

    case BookingAction.start:
      // The code is the customer's proof of arrival; a walk-in was added at
      // the counter, so there is nobody to verify against.
      if (!isWalkIn) {
        if (!context.mounted) return;
        final code = await VerificationCodeBottomSheet.show(context);
        if (code == null) return;
        verificationCode = code;
      }

    case BookingAction.noShow:
      if (!context.mounted) return;
      final confirmed = await AppAlertDialog.show(
        context,
        icon: Icons.person_off_outlined,
        title: 'Mark as No Show?',
        message:
            'The customer will be recorded as not having turned up. This '
            'cannot be undone.',
        primaryLabel: 'Mark No Show',
        secondaryLabel: 'Cancel',
      );
      if (!confirmed) return;

    case BookingAction.complete:
      if (!context.mounted) return;
      final confirmed = await AppAlertDialog.show(
        context,
        icon: Icons.check_circle_outline,
        title: 'Complete Booking?',
        message: 'Mark this service as finished. This cannot be undone.',
        primaryLabel: 'Complete',
        secondaryLabel: 'Cancel',
        iconColor: AppColors.success,
      );
      if (!confirmed) return;

    case BookingAction.cancel:
      final note = await ReasonBottomSheet.show(
        context,
        title: 'Cancel Booking',
        subtitle: 'The customer sees this note. Leave it blank to skip.',
        hintText: 'e.g. Shop closed unexpectedly',
        confirmLabel: 'Continue',
      );
      if (note == null) return;
      reason = note.isEmpty ? null : note;

      if (!context.mounted) return;
      final confirmed = await AppAlertDialog.show(
        context,
        icon: Icons.block,
        title: 'Cancel this booking?',
        message:
            'The slot is freed and the customer is told. This cannot be '
            'undone.',
        primaryLabel: 'Cancel Booking',
        secondaryLabel: 'Keep Booking',
        iconColor: AppColors.error,
        iconBackgroundColor: Color(0x14FF0000),
      );
      if (!confirmed) return;

    case BookingAction.reschedule:
      final selection = await SlotSelectionBottomSheet.showForReschedule(
        context,
        bookingId: bookingId,
      );
      if (selection == null || selection.starts.isEmpty) return;
      slots = selection.starts;

      if (!context.mounted) return;
      final confirmed = await AppAlertDialog.show(
        context,
        icon: Icons.event_repeat_outlined,
        title: 'Reschedule Booking?',
        message:
            'This booking moves to ${selection.label}. The customer is told '
            'about the new time.',
        primaryLabel: 'Reschedule',
        secondaryLabel: 'Keep Current Time',
      );
      if (!confirmed) return;

    case BookingAction.approveReschedule:
      if (!context.mounted) return;
      // The proposed slot was never held while the request waited, so this can
      // fail on a full or closed slot. The wording promises an attempt, not an
      // outcome; a failure leaves the request pending and answerable later.
      final confirmed = await AppAlertDialog.show(
        context,
        icon: Icons.event_available_outlined,
        title: 'Approve Time Change?',
        message:
            'The booking moves to the time the customer asked for, if that '
            'slot is still free.',
        primaryLabel: 'Approve',
        secondaryLabel: 'Not Now',
        iconColor: AppColors.success,
      );
      if (!confirmed) return;

    case BookingAction.rejectReschedule:
      final note = await ReasonBottomSheet.show(
        context,
        title: 'Reject Time Change',
        subtitle:
            'The booking stays at its current time. The customer sees this '
            'note. Leave it blank to skip.',
        hintText: 'e.g. That slot is already taken',
        confirmLabel: 'Reject Change',
      );
      if (note == null) return;
      reason = note.isEmpty ? null : note;
  }

  bloc.add(
    BookingActionRequested(
      bookingId: bookingId,
      action: action,
      reason: reason,
      verificationCode: verificationCode,
      slots: slots,
    ),
  );
}
