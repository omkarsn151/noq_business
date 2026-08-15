import 'package:noq_business/core/models/upload_model.dart';

class ServiceImages {
  final List<UploadModel> thumbnails;
  final List<UploadModel> banners;

  const ServiceImages({this.thumbnails = const [], this.banners = const []});

  factory ServiceImages.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServiceImages();
    return ServiceImages(
      thumbnails: (json['thumbnails'] as List? ?? [])
          .map((e) => UploadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      banners: (json['banners'] as List? ?? [])
          .map((e) => UploadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceModel {
  final String id;
  final String? subCategoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final String price;
  final String currencyCode;
  final bool isActive;
  final ServiceImages images;

  const ServiceModel({
    required this.id,
    this.subCategoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    required this.currencyCode,
    required this.isActive,
    this.images = const ServiceImages()
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      subCategoryId: json['sub_category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      price: json['price'] as String,
      currencyCode: json['currency_code'] as String,
      isActive: json['is_active'] as bool,
      images: ServiceImages.fromJson(json['images'] as Map<String, dynamic>?)
    );
  }
}
