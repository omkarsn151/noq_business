enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled;

  static BookingStatus? fromString(String? value) {
    switch (value) {
      case 'pending':
        return BookingStatus.pending;
      case 'approved':
        return BookingStatus.approved;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return null;
    }
  }

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.approved:
        return 'approved';
      case BookingStatus.rejected:
        return 'rejected';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
