import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/gallery/data/gallery_page_model.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';

class GalleryRepository {
  /// A multiple of the 3 column grid, so every page fills whole rows.
  static const int pageSize = 21;

  final DioClient _dioClient;

  GalleryRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Every picture the shop has - cover photos first, then service pictures.
  /// [GallerySource.all] sends no `source` filter at all.
  Future<GalleryPageModel> getGallery({
    GallerySource source = GallerySource.all,
    int page = 1,
    int limit = pageSize,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getBusinessGallery,
      queryParameters: {
        'page': page,
        'page_size': limit,
        'source': ?source.value,
      },
    );

    return GalleryPageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
