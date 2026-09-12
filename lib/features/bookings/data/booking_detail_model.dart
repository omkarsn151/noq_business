import 'package:noq_business/core/utils/currency_format.dart';
import 'package:noq_business/features/bookings/data/booking_detail_status.dart';

/// True when a decimal string holds anything above zero.
bool _isPositive(String value) => (double.tryParse(value) ?? 0) > 0;

/// Who and what this booking is - the header strip of the details screen.
class BookingDetailIdentity {
  final String id;

  /// Short readable name, e.g. 'BK-7KQ4M2'. Shown as the Booking ID.
  final String reference;
  final BookingDetailStatus status;

  /// 'online' | 'walk_in'
  final String bookingType;

  /// 'auto' | 'manual'
  final String approvalMode;
  final DateTime? bookedAt;

  const BookingDetailIdentity({
    this.id = '',
    this.reference = '',
    this.status = BookingDetailStatus.pending,
    this.bookingType = '',
    this.approvalMode = '',
    this.bookedAt,
  });

  factory BookingDetailIdentity.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailIdentity();
    return BookingDetailIdentity(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      status: BookingDetailStatus.fromString(json['status']?.toString()),
      bookingType: json['booking_type']?.toString() ?? '',
      approvalMode: json['approval_mode']?.toString() ?? '',
      bookedAt: DateTime.tryParse(json['booked_at']?.toString() ?? ''),
    );
  }

  bool get isWalkIn {
    final type = bookingType.toLowerCase();
    return type == 'walk_in' || type == 'walkin' || type == 'walk-in';
  }
}

/// The person who is coming in, and how to reach them.
class BookingDetailCustomer {
  final String name;
  final String? phone;
  final String? photoUrl;
  final bool isWalkIn;

  const BookingDetailCustomer({
    this.name = '',
    this.phone,
    this.photoUrl,
    this.isWalkIn = false,
  });

  factory BookingDetailCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailCustomer();
    return BookingDetailCustomer(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      isWalkIn: json['is_walk_in'] as bool? ?? false,
    );
  }

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  /// 'SP' for 'Saryam Prasad' - drawn when there is no profile picture.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

/// One booked service line, with the price and length frozen at booking time.
class BookingDetailService {
  final String id;
  final String name;
  final String? imageUrl;
  final String price;
  final int durationMinutes;
  final String currencyCode;

  const BookingDetailService({
    this.id = '',
    this.name = '',
    this.imageUrl,
    this.price = '0',
    this.durationMinutes = 0,
    this.currencyCode = '',
  });

  factory BookingDetailService.fromJson(Map<String, dynamic> json) {
    return BookingDetailService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      price: json['price']?.toString() ?? '0',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      currencyCode: json['currency_code']?.toString() ?? '',
    );
  }

  String get priceLabel => formatAmount(price, currencyCode);

  String get durationLabel => '$durationMinutes min';
}

/// When the visit is booked for.
class BookingDetailSchedule {
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final int totalDurationMinutes;

  const BookingDetailSchedule({
    this.scheduledStart,
    this.scheduledEnd,
    this.totalDurationMinutes = 0,
  });

  factory BookingDetailSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailSchedule();
    return BookingDetailSchedule(
      scheduledStart: DateTime.tryParse(
        json['scheduled_start']?.toString() ?? '',
      ),
      scheduledEnd: DateTime.tryParse(json['scheduled_end']?.toString() ?? ''),
      totalDurationMinutes:
          (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
    );
  }

  String get durationLabel => '$totalDurationMinutes min';
}

/// The team member the customer asked for. A wish, never an assignment - the
/// API documents `is_confirmed` as always false.
class BookingDetailStaff {
  final String? requestedStaffId;

  /// The literal string 'Anyone' when nobody was picked.
  final String requestedStaffName;
  final bool isConfirmed;

  const BookingDetailStaff({
    this.requestedStaffId,
    this.requestedStaffName = 'Anyone',
    this.isConfirmed = false,
  });

  factory BookingDetailStaff.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailStaff();
    return BookingDetailStaff(
      requestedStaffId: json['requested_staff_id']?.toString(),
      requestedStaffName: json['requested_staff_name']?.toString() ?? 'Anyone',
      isConfirmed: json['is_confirmed'] as bool? ?? false,
    );
  }
}

/// Where the visit happens - the shop address, copied for the screen.
class BookingDetailLocation {
  final String? addressLine;
  final String? city;
  final String? state;
  final String? postalCode;

  const BookingDetailLocation({
    this.addressLine,
    this.city,
    this.state,
    this.postalCode,
  });

  factory BookingDetailLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailLocation();
    return BookingDetailLocation(
      addressLine: json['address_line']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
    );
  }

  /// '12 Sarangapani Street, Kumbakonam, Tamil Nadu 612001'
  String get label {
    final parts = [
      addressLine,
      city,
      state,
    ].where((part) => part != null && part.trim().isNotEmpty).toList();
    final joined = parts.join(', ');
    final pin = postalCode?.trim();

    if (joined.isEmpty) return pin?.isNotEmpty == true ? pin! : '—';
    return pin?.isNotEmpty == true ? '$joined $pin' : joined;
  }
}

/// The money breakdown, all frozen when the booking was made.
class BookingDetailPayment {
  final String subtotal;
  final String discount;
  final String platformFee;
  final String total;
  final String currencyCode;

  /// Always null today - online payments are not wired yet.
  final String? method;

  /// Always null today - payment status is not wired yet.
  final String? status;

  const BookingDetailPayment({
    this.subtotal = '0',
    this.discount = '0',
    this.platformFee = '0',
    this.total = '0',
    this.currencyCode = '',
    this.method,
    this.status,
  });

  factory BookingDetailPayment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailPayment();
    return BookingDetailPayment(
      subtotal: json['subtotal']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      platformFee: json['platform_fee']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      currencyCode: json['currency_code']?.toString() ?? '',
      method: json['method']?.toString(),
      status: json['status']?.toString(),
    );
  }

  String get subtotalLabel => formatAmount(subtotal, currencyCode);

  String get discountLabel => '-${formatAmount(discount, currencyCode)}';

  String get platformFeeLabel => formatAmount(platformFee, currencyCode);

  String get totalLabel => formatAmount(total, currencyCode);

  bool get hasDiscount => _isPositive(discount);

  bool get hasPlatformFee => _isPositive(platformFee);

  bool get hasMethod => method != null && method!.trim().isNotEmpty;

  bool get hasStatus => status != null && status!.trim().isNotEmpty;
}

/// Why the visit was cancelled and what the shop decided about the fee.
class BookingDetailCancellation {
  /// 'customer' | 'business' | 'system'
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? reason;

  /// 'charged' | 'waived' | null while the decision is still open.
  final String? penaltyDecision;
  final String? penaltyAmount;
  final DateTime? penaltyDecidedAt;

  const BookingDetailCancellation({
    this.cancelledBy,
    this.cancelledAt,
    this.reason,
    this.penaltyDecision,
    this.penaltyAmount,
    this.penaltyDecidedAt,
  });

  static BookingDetailCancellation? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return BookingDetailCancellation(
      cancelledBy: json['cancelled_by']?.toString(),
      cancelledAt: DateTime.tryParse(json['cancelled_at']?.toString() ?? ''),
      reason: json['reason']?.toString(),
      penaltyDecision: json['penalty_decision']?.toString(),
      penaltyAmount: json['penalty_amount']?.toString(),
      penaltyDecidedAt: DateTime.tryParse(
        json['penalty_decided_at']?.toString() ?? '',
      ),
    );
  }
}

/// Why the shop refused this booking.
class BookingDetailRejection {
  final String? reason;

  const BookingDetailRejection({this.reason});

  static BookingDetailRejection? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return BookingDetailRejection(reason: json['reason']?.toString());
  }
}

/// Who asked for the time change, and what to call them.
class BookingDetailRescheduleRequestedBy {
  /// 'customer' - the visitor asked and may still be waiting.
  /// 'business' - the shop already moved the visit itself.
  final String role;
  final String name;

  const BookingDetailRescheduleRequestedBy({this.role = '', this.name = ''});

  factory BookingDetailRescheduleRequestedBy.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return const BookingDetailRescheduleRequestedBy();
    return BookingDetailRescheduleRequestedBy(
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  bool get isByBusiness => role == 'business';

  /// Heading for the card - the shop moving a visit and a customer asking to
  /// are the same block with different words.
  String get label => isByBusiness ? 'Rescheduled by' : 'Requested by';
}

/// The old window, the proposed window, and the chips that were tapped.
class BookingDetailRescheduleSchedule {
  /// Where the visit sat when the request was made - the left side of the
  /// old -> new arrow. Copied onto the request at that moment, so it still
  /// reads correctly long afterwards.
  final DateTime? previousStart;
  final DateTime? previousEnd;

  /// Where the customer wants the visit to go. Not reserved while the request
  /// waits, which is why approving it can honestly fail.
  final DateTime? proposedStart;
  final DateTime? proposedEnd;
  final int totalDurationMinutes;

  /// Every chip the customer tapped, in order. Shown for honesty - the card
  /// reads [proposedStart] / [proposedEnd], not this list.
  final List<DateTime> proposedSlots;

  /// The shop's IANA timezone. Times on the wire are UTC.
  final String timezone;

  const BookingDetailRescheduleSchedule({
    this.previousStart,
    this.previousEnd,
    this.proposedStart,
    this.proposedEnd,
    this.totalDurationMinutes = 0,
    this.proposedSlots = const [],
    this.timezone = '',
  });

  factory BookingDetailRescheduleSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailRescheduleSchedule();
    return BookingDetailRescheduleSchedule(
      previousStart: DateTime.tryParse(
        json['previous_start']?.toString() ?? '',
      ),
      previousEnd: DateTime.tryParse(json['previous_end']?.toString() ?? ''),
      proposedStart: DateTime.tryParse(
        json['proposed_start']?.toString() ?? '',
      ),
      proposedEnd: DateTime.tryParse(json['proposed_end']?.toString() ?? ''),
      totalDurationMinutes:
          (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
      proposedSlots: (json['proposed_slots'] as List? ?? [])
          .map((slot) => DateTime.tryParse(slot?.toString() ?? ''))
          .whereType<DateTime>()
          .toList(),
      timezone: json['timezone']?.toString() ?? '',
    );
  }

  String get durationLabel => '$totalDurationMinutes min';
}

/// A request to move this booking to a different time.
///
/// Null on a booking that has never had one - the normal case - so its presence
/// is the single test for whether to draw the section. An answered request
/// stays here as history, and only the newest one is ever returned.
class BookingDetailRescheduleRequest {
  final String id;

  /// The *request's* own life stage - `pending`, `approved` or `rejected` -
  /// never the booking's, which answering a request never changes. A
  /// `confirmed` booking with a `pending` request is completely normal.
  final BookingDetailStatus status;
  final BookingDetailRescheduleRequestedBy requestedBy;
  final DateTime? createdAt;

  /// When the shop answered. Null while the request is still pending.
  final DateTime? resolvedAt;

  /// Why it was turned down. Null unless [status] is rejected. May be the
  /// shop's own words or a sentence the API writes when the request was closed
  /// because something else happened first.
  final String? rejectionReason;
  final BookingDetailRescheduleSchedule schedule;

  /// Who was asked for on the *proposed* visit - read off the request, not off
  /// the booking, which still describes the old appointment while this waits.
  final BookingDetailStaff staff;

  const BookingDetailRescheduleRequest({
    this.id = '',
    this.status = BookingDetailStatus.pending,
    this.requestedBy = const BookingDetailRescheduleRequestedBy(),
    this.createdAt,
    this.resolvedAt,
    this.rejectionReason,
    this.schedule = const BookingDetailRescheduleSchedule(),
    this.staff = const BookingDetailStaff(),
  });

  static BookingDetailRescheduleRequest? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return BookingDetailRescheduleRequest(
      id: json['id']?.toString() ?? '',
      status: BookingDetailStatus.fromString(json['status']?.toString()),
      requestedBy: BookingDetailRescheduleRequestedBy.fromJson(
        json['requested_by'] as Map<String, dynamic>?,
      ),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      resolvedAt: DateTime.tryParse(json['resolved_at']?.toString() ?? ''),
      rejectionReason: json['rejection_reason']?.toString(),
      schedule: BookingDetailRescheduleSchedule.fromJson(
        json['schedule'] as Map<String, dynamic>?,
      ),
      staff: BookingDetailStaff.fromJson(
        json['staff'] as Map<String, dynamic>?,
      ),
    );
  }

  /// Nobody has answered yet, so the visit is still at its old time.
  bool get isPending => status == BookingDetailStatus.pending;

  /// Already answered - the card reads as history rather than a question.
  bool get isResolved => !isPending;

  bool get hasRejectionReason =>
      rejectionReason != null && rejectionReason!.trim().isNotEmpty;
}

/// Which buttons to draw. Read these instead of switching on the status.
class BookingDetailActions {
  final bool canApprove;
  final bool canReject;
  final bool canStart;
  final bool canNoShow;
  final bool canComplete;

  /// The two that live in the overflow menu rather than the bottom bar.
  /// [canReschedule] is true only while confirmed; [canCancel] while pending
  /// or confirmed.
  final bool canReschedule;
  final bool canCancel;

  /// The two that answer a customer's *reschedule request* rather than the
  /// booking. Both need a pending request; approving also needs the booking
  /// itself to be confirmed, so Reject can be on while Approve is off.
  ///
  /// These are never [canApprove] / [canReject], which are only ever about
  /// accepting a new booking.
  final bool canApproveReschedule;
  final bool canRejectReschedule;

  const BookingDetailActions({
    this.canApprove = false,
    this.canReject = false,
    this.canStart = false,
    this.canNoShow = false,
    this.canComplete = false,
    this.canReschedule = false,
    this.canCancel = false,
    this.canApproveReschedule = false,
    this.canRejectReschedule = false,
  });

  factory BookingDetailActions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingDetailActions();
    return BookingDetailActions(
      canApprove: json['can_approve'] as bool? ?? false,
      canReject: json['can_reject'] as bool? ?? false,
      canStart: json['can_start'] as bool? ?? false,
      canNoShow: json['can_no_show'] as bool? ?? false,
      canComplete: json['can_complete'] as bool? ?? false,
      canReschedule: json['can_reschedule'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      canApproveReschedule: json['can_approve_reschedule'] as bool? ?? false,
      canRejectReschedule: json['can_reject_reschedule'] as bool? ?? false,
    );
  }

  /// Buttons drawn in the bottom bar.
  bool get hasAny =>
      canApprove || canReject || canStart || canNoShow || canComplete;

  /// Items drawn in the app bar overflow menu.
  bool get hasMenu => canReschedule || canCancel;

  /// Buttons drawn on the reschedule request card.
  bool get hasRescheduleAnswer => canApproveReschedule || canRejectReschedule;
}

/// Grouped payload for GET /business/bookings/{booking_id} - the whole screen.
class BookingDetailModel {
  final BookingDetailIdentity booking;
  final BookingDetailCustomer customer;
  final List<BookingDetailService> services;
  final BookingDetailSchedule schedule;
  final BookingDetailStaff staff;
  final BookingDetailLocation location;
  final BookingDetailPayment payment;

  /// Only present when the booking was cancelled.
  final BookingDetailCancellation? cancellation;

  /// Only present when the booking was rejected.
  final BookingDetailRejection? rejection;

  /// The customer's request to move this booking, pending or already answered.
  /// Null when there has never been one - the normal case.
  final BookingDetailRescheduleRequest? rescheduleRequest;
  final BookingDetailActions actions;

  const BookingDetailModel({
    required this.booking,
    required this.customer,
    required this.services,
    required this.schedule,
    required this.staff,
    required this.location,
    required this.payment,
    this.cancellation,
    this.rejection,
    this.rescheduleRequest,
    required this.actions,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return BookingDetailModel(
      booking: BookingDetailIdentity.fromJson(
        data['booking'] as Map<String, dynamic>?,
      ),
      customer: BookingDetailCustomer.fromJson(
        data['customer'] as Map<String, dynamic>?,
      ),
      services: (data['services'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BookingDetailService.fromJson)
          .toList(),
      schedule: BookingDetailSchedule.fromJson(
        data['schedule'] as Map<String, dynamic>?,
      ),
      staff: BookingDetailStaff.fromJson(
        data['staff'] as Map<String, dynamic>?,
      ),
      location: BookingDetailLocation.fromJson(
        data['location'] as Map<String, dynamic>?,
      ),
      payment: BookingDetailPayment.fromJson(
        data['payment'] as Map<String, dynamic>?,
      ),
      cancellation: BookingDetailCancellation.fromJson(
        data['cancellation'] as Map<String, dynamic>?,
      ),
      rejection: BookingDetailRejection.fromJson(
        data['rejection'] as Map<String, dynamic>?,
      ),
      rescheduleRequest: BookingDetailRescheduleRequest.fromJson(
        data['reschedule_request'] as Map<String, dynamic>?,
      ),
      actions: BookingDetailActions.fromJson(
        data['actions'] as Map<String, dynamic>?,
      ),
    );
  }
}
