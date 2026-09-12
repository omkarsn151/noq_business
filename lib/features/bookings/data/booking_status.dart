/// One tab on the Bookings screen.
///
/// The order here is the order the tabs are drawn in - [values] drives both the
/// `TabController` length and the tab bar itself - and it mirrors the API's own
/// tab order.
enum BookingStatus {
  pending('Pending', 'pending', 'pending'),
  approved('Approved', 'approved', 'approved'),

  /// Finished visits: `completed` and `no_show` together. Read-only history.
  completed('Completed', 'completed', 'completed'),
  rejected('Rejected', 'rejected', 'rejected'),
  cancelled('Cancellations', 'cancellations', 'cancelled'),

  /// Requests nobody answered before their slot came and went. Read-only.
  dismissed('Dismissed', 'dismissed', 'dismissed');

  /// Tab label.
  final String label;

  /// Value used for the `tab` query parameter and the meta counts key.
  final String value;

  /// Used in the empty state copy - 'No cancelled bookings' reads better than
  /// the plural tab label.
  final String emptyLabel;

  const BookingStatus(this.label, this.value, this.emptyLabel);

  /// No action can be taken on a booking listed under this tab.
  ///
  /// Only Pending and Approved hold rows the shop can still answer; the rest
  /// are history. Phrased as an exclusion so a tab added later is inert by
  /// default rather than accidentally actionable.
  bool get isReadOnly =>
      this != BookingStatus.pending && this != BookingStatus.approved;

  /// Resolves a tab value (`pending`, ..., `dismissed`).
  static BookingStatus fromValue(String? value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value || status.name == value,
      orElse: () => BookingStatus.pending,
    );
  }
}
