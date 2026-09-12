import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/bookings/data/booking_action.dart';
import 'package:noq_business/features/bookings/data/booking_action_result.dart';
import 'package:noq_business/features/bookings/data/booking_detail_model.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/data/bookings_page_model.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

class BookingsRepository {
  static const int pageSize = 10;

  final DioClient _dioClient;

  BookingsRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<BookingsPageModel> getBookings({
    required BookingStatus status,
    int page = 1,
    int limit = pageSize,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getBookings,
      queryParameters: {'tab': status.value, 'page': page, 'page_size': limit},
    );

    return BookingsPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingDetailModel> getBookingDetails(String bookingId) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.getBookingDetails}$bookingId',
    );

    return BookingDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Date chips and the time grid for moving [bookingId] to a new slot.
  ///
  /// The payload is the same shape the walk-in slot picker reads, so it reuses
  /// [WalkinSlotsModel]. [date] is a local calendar day in the shop's timezone
  /// (`YYYY-MM-DD`); omit it to load the shop's today.
  Future<WalkinSlotsModel> getRescheduleSlots(
    String bookingId, {
    String? date,
  }) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.getRescheduleSlots}$bookingId/slots',
      queryParameters: {'date': ?date},
    );

    final json = response.data as Map<String, dynamic>;
    return WalkinSlotsModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Runs one action against a booking.
  ///
  /// Every extra field belongs to a single action, and the API rejects the
  /// request outright when one turns up on the wrong one - so they are added
  /// with null-aware entries and left out entirely when unused. [slots] are
  /// the chip starts from [getRescheduleSlots], sent as UTC ISO 8601.
  ///
  /// [bookingId] is always the *booking* id - `approve_reschedule` and
  /// `reject_reschedule` included. The server finds the pending request
  /// itself, so the request id is never sent.
  Future<BookingActionResult> performAction({
    required String bookingId,
    required BookingAction action,
    String? reason,
    String? verificationCode,
    List<DateTime>? slots,
    String? staffId,
  }) async {
    final response = await _dioClient.post(
      '${ApiEndpoints.bookingAction}$bookingId/actions',
      data: {
        'action': action.value,
        'reason': ?reason,
        'verification_code': ?verificationCode,
        'slots': ?slots
            ?.map((start) => start.toUtc().toIso8601String())
            .toList(),
        'staff_id': ?staffId,
      },
    );

    return BookingActionResult.fromJson(response.data as Map<String, dynamic>);
  }
}
