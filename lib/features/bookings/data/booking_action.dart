/// One thing the shop can do to a booking, posted as `action` to
/// `POST v1/business/bookings/{booking_id}/actions`.
///
/// The extra body fields belong to one action each and must be left out for
/// the rest - sending `reason` with `approve`, for instance, is a 422.
enum BookingAction {
  approve('approve', 'Booking approved.'),
  reject('reject', 'Booking rejected.'),
  start('start', 'Booking started.'),
  noShow('no_show', 'Booking marked as no-show.'),
  complete('complete', 'Booking completed.'),
  cancel('cancel', 'Booking cancelled.'),
  reschedule('reschedule', 'Booking rescheduled.'),

  /// Says yes to a customer's request to move an existing booking. Distinct
  /// from [approve], which accepts a brand new booking - answering a time
  /// change never touches the booking's own status.
  approveReschedule('approve_reschedule', 'Time change approved.'),

  /// Says no to that request. The booking stays alive on its original slot.
  rejectReschedule('reject_reschedule', 'Time change rejected.');

  /// How the API spells this action.
  final String value;

  /// Shown when the response carries no `message` of its own.
  final String successMessage;

  const BookingAction(this.value, this.successMessage);

  /// Only `reject`, `cancel` and `reject_reschedule` accept a reason.
  bool get takesReason =>
      this == reject || this == cancel || this == rejectReschedule;

  /// Answers a customer's reschedule request rather than the booking itself.
  bool get answersRescheduleRequest =>
      this == approveReschedule || this == rejectReschedule;
}
