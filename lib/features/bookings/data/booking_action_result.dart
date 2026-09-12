/// What the app keeps from an action response.
///
/// The `data` block differs per action - approve returns a schedule, cancel a
/// cancellation, reschedule the new slot - so only the two fields every shape
/// shares are parsed here. The screens reload the booking afterwards anyway.
class BookingActionResult {
  /// Server copy for the success snackbar, e.g. 'Booking approved.'.
  final String message;

  /// The booking's new status, when the response carried one.
  final String? status;

  const BookingActionResult({this.message = '', this.status});

  factory BookingActionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final booking = data?['booking'] as Map<String, dynamic>?;

    return BookingActionResult(
      message: json['message']?.toString() ?? '',
      // Older shapes put the status at the top of `data`, newer ones nest it
      // under `data.booking`.
      status: (booking?['status'] ?? data?['status'])?.toString(),
    );
  }
}
