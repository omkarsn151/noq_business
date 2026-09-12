/// Life stage of a single booking as reported by the details endpoint.
///
/// Wider than the list tabs, which group several of these together - Approved
/// holds `confirmed` and `in_progress`, Completed holds `completed` and
/// `no_show`.
///
/// On a reschedule-request row this carries the *request's* status instead of
/// the booking's, so it always matches the tab the card sits in.
enum BookingDetailStatus {
  pending('Pending', 'pending'),
  confirmed('Confirmed', 'confirmed'),
  inProgress('In Progress', 'in_progress'),
  completed('Completed', 'completed'),
  noShow('No Show', 'no_show'),
  rejected('Rejected', 'rejected'),
  cancelled('Cancelled', 'cancelled'),

  /// Nobody answered the request before its slot came and went.
  dismissed('Dismissed', 'dismissed');

  /// Label shown on the status chip.
  final String label;

  /// How the API spells this status.
  final String value;

  const BookingDetailStatus(this.label, this.value);

  static BookingDetailStatus fromString(String? value) {
    return BookingDetailStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingDetailStatus.pending,
    );
  }
}
