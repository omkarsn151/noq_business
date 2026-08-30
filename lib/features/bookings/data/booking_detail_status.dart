/// Life stage of a single booking as reported by the details endpoint.
///
/// Wider than [BookingStatus], which only covers the four list tabs.
enum BookingDetailStatus {
  pending('Pending', 'pending'),
  confirmed('Confirmed', 'confirmed'),
  inProgress('In Progress', 'in_progress'),
  completed('Completed', 'completed'),
  noShow('No Show', 'no_show'),
  rejected('Rejected', 'rejected'),
  cancelled('Cancelled', 'cancelled');

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
