import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';
import 'package:noq_business/features/staff/data/staff_profile_model.dart';

class StaffRepository {
  final DioClient _dioClient;

  StaffRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<StaffModel>> getStaff() async {
    final response = await _dioClient.get(ApiEndpoints.getStaff);

    final data = response.data['data'] as List;
    return data
        .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Everything the Staff Profile screen needs for one person, in one call -
  /// their details, today's status tiles and today's full schedule.
  Future<StaffProfileModel> getStaffDetails(String id) async {
    final response = await _dioClient.get('${ApiEndpoints.staffDetails}/$id');

    return StaffProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// The edit endpoint takes a partial body, so the profile's Active toggle
  /// sends just this one field instead of re-posting the whole staff member.
  Future<void> setStaffActive({
    required String id,
    required bool isActive,
  }) async {
    await _dioClient.patch(
      '${ApiEndpoints.editStaff}/$id',
      data: {'is_active': isActive},
    );
  }

  Future<void> addStaff({
    required String name,
    String? photoId,
    required String worksFrom,
    required String worksTo,
    String? breakStart,
    String? breakEnd,
    required bool isActive,
    required List<String> serviceIds,
  }) async {
    await _dioClient.post(
      ApiEndpoints.addStaff,
      data: {
        'name': name,
        'photo_id': photoId,
        'works_from': worksFrom,
        'works_to': worksTo,
        'break_start': breakStart,
        'break_end': breakEnd,
        'is_active': isActive,
        'service_ids': serviceIds,
      },
    );
  }

  Future<void> deleteStaff(String id) async {
    await _dioClient.delete('${ApiEndpoints.deleteStaff}/$id');
  }

  Future<void> editStaff({
    required String id,
    required String name,
    String? photoId,
    required String worksFrom,
    required String worksTo,
    String? breakStart,
    String? breakEnd,
    required bool isActive,
    required List<String> serviceIds,
  }) async {
    await _dioClient.patch(
      '${ApiEndpoints.editStaff}/$id',
      data: {
        'name': name,
        'photo_id': photoId,
        'works_from': worksFrom,
        'works_to': worksTo,
        'break_start': breakStart,
        'break_end': breakEnd,
        'is_active': isActive,
        'service_ids': serviceIds,
      },
    );
  }
}
