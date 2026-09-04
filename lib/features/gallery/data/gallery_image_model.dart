import 'package:equatable/equatable.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';

/// One picture in the shop's gallery - either a shop cover photo or a picture
/// attached to one of the shop's services.
class GalleryImageModel extends Equatable {
  /// The stored file's id, unique across the gallery. Used as the Hero tag.
  final String uploadId;
  final String fileName;
  final String url;
  final GallerySource source;

  /// Both null when [source] is [GallerySource.businessCover] - a cover photo
  /// belongs to the shop, not to any one service.
  final String? serviceId;
  final String? serviceName;

  const GalleryImageModel({
    this.uploadId = '',
    this.fileName = '',
    this.url = '',
    this.source = GallerySource.service,
    this.serviceId,
    this.serviceName,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GalleryImageModel();
    return GalleryImageModel(
      uploadId: json['upload_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      source: GallerySource.fromValue(json['source']?.toString()),
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name']?.toString(),
    );
  }

  bool get isCover => source == GallerySource.businessCover;

  /// Ready to print under the tile and in the viewer.
  String get caption => serviceName ?? 'Shop cover';

  @override
  List<Object?> get props => [
    uploadId,
    fileName,
    url,
    source,
    serviceId,
    serviceName,
  ];
}
