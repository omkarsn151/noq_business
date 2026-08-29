/// `data.booking` of POST /v1/business/walk-ins.
///
/// Walk-ins are always created confirmed and paid in cash, so the payment and
/// staff blocks of the response are not modelled - only what the confirmation
/// message needs.
class WalkinBookingModel {
  final String id;
  final String reference;
  final String status;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final int totalDurationMinutes;

  const WalkinBookingModel({
    required this.id,
    required this.reference,
    required this.status,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.totalDurationMinutes,
  });

  factory WalkinBookingModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] as Map<String, dynamic>? ?? const {};
    return WalkinBookingModel(
      id: booking['id']?.toString() ?? '',
      reference: booking['reference']?.toString() ?? '',
      status: booking['status']?.toString() ?? '',
      scheduledStart: DateTime.tryParse(
        booking['scheduled_start']?.toString() ?? '',
      ),
      scheduledEnd: DateTime.tryParse(
        booking['scheduled_end']?.toString() ?? '',
      ),
      totalDurationMinutes:
          (booking['total_duration_minutes'] as num?)?.toInt() ?? 0,
    );
  }
}
