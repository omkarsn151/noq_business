import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/data/bookings_page_model.dart';

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
}
