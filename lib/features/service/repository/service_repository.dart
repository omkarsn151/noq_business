import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/service/data/service_model.dart';

class ServiceRepository {
  final DioClient _dioClient;

  ServiceRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<ServiceModel>> getServices() async {
    final response = await _dioClient.get(ApiEndpoints.getServices);

    final data = response.data['data'] as List;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteService(String id) async {
    await _dioClient.delete('${ApiEndpoints.deleteService}/$id');
  }

  Future<void> addService({
    required String name,
    required int durationMinutes,
    required String price,
    String? subCategoryId,
    String? description,
    required bool isActive,
    required List<String> thumbnailIds,
    List<String> bannerIds = const [],
  }) async {
    await _dioClient.post(
      ApiEndpoints.addService,
      data: {
        'name': name,
        'duration_minutes': durationMinutes,
        'price': price,
        'sub_category_id': subCategoryId,
        'description': description,
        'is_active': isActive,
        'thumbnail_ids': thumbnailIds,
        'banner_ids': bannerIds,
      },
    );
  }

  Future<void> editService({
    required String id,
    required String name,
    required int durationMinutes,
    required String price,
    String? subCategoryId,
    String? description,
    required bool isActive,
    required List<String> thumbnailIds,
    List<String> bannerIds = const [],
  }) async {
    await _dioClient.patch(
      '${ApiEndpoints.editService}/$id',
      data: {
        'name': name,
        'duration_minutes': durationMinutes,
        'price': price,
        'sub_category_id': subCategoryId,
        'description': description,
        'is_active': isActive,
        'thumbnail_ids': thumbnailIds,
        'banner_ids': bannerIds,
      },
    );
  }
}
