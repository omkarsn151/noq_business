import 'package:dio/dio.dart';
import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/walkin/data/walkin_booking_model.dart';
import 'package:noq_business/features/walkin/data/walkin_slots_model.dart';

class WalkinRepository {
  final DioClient _dioClient;

  WalkinRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Dates, time chips and shop operations for the ticked services.
  ///
  /// [date] is a local calendar day in the shop's timezone (`YYYY-MM-DD`);
  /// omit it to load the shop's today. The result is a snapshot - it holds no
  /// chair - so it must be reloaded whenever the service selection changes.
  Future<WalkinSlotsModel> getSlots({
    required List<String> serviceIds,
    String? date,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getWalkinSlots,
      queryParameters: {'service_ids': serviceIds, 'date': ?date},
      // The API wants `service_ids=a&service_ids=b`, not `service_ids[]=a`.
      options: Options(listFormat: ListFormat.multi),
    );

    final json = response.data as Map<String, dynamic>;
    return WalkinSlotsModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Creates one confirmed walk-in. [slotStarts] are the highlighted chip
  /// starts, in order; the first one is the start of the visit.
  Future<WalkinBookingModel> createWalkin({
    required String customerName,
    String? customerPhone,
    required List<String> serviceIds,
    required List<DateTime> slotStarts,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createWalkin,
      data: {
        'customer_name': customerName.trim(),
        'customer_phone': ?customerPhone,
        'service_ids': serviceIds,
        'slots': slotStarts
            .map((start) => start.toUtc().toIso8601String())
            .toList(),
        'staff_id': null,
      },
    );

    final json = response.data as Map<String, dynamic>;
    return WalkinBookingModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
