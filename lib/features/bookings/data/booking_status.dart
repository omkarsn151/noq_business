enum BookingStatus {
  pending('Pending', 'pending', 'pending'),
  approved('Approved', 'approved', 'approved'),
  rejected('Rejected', 'rejected', 'rejected'),
  cancelled('Cancellations', 'cancellations', 'cancelled');

  /// Tab label.
  final String label;

  /// Value used for the `tab` query parameter and the meta counts key.
  final String value;

  /// How a single booking spells this status in its own `status` field.
  final String itemValue;

  const BookingStatus(this.label, this.value, this.itemValue);

  /// Resolves a tab value (`pending`, ..., `cancellations`).
  static BookingStatus fromValue(String? value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value || status.name == value,
      orElse: () => BookingStatus.pending,
    );
  }

  /// Resolves the `status` of a single booking. Accepts both the item spelling
  /// (`cancelled`) and the tab spelling (`cancellations`).
  static BookingStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in BookingStatus.values) {
      if (status.itemValue == value || status.value == value) return status;
    }
    return null;
  }

  /// Used in the empty state copy - 'No cancelled bookings' reads better than
  /// the plural tab label.
  String get emptyLabel => itemValue;
}
