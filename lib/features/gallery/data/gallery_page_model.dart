import 'package:noq_business/core/models/pagination_model.dart';
import 'package:noq_business/features/gallery/data/gallery_image_model.dart';

/// One page of gallery pictures plus the meta returned alongside it.
class GalleryPageModel {
  final List<GalleryImageModel> images;
  final PaginationModel pagination;

  const GalleryPageModel({
    required this.images,
    required this.pagination,
  });

  factory GalleryPageModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;

    return GalleryPageModel(
      images: (json['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GalleryImageModel.fromJson)
          .toList(),
      pagination: PaginationModel.fromJson(
        meta?['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}
