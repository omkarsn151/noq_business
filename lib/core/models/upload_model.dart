class UploadModel {
  final String id;
  final String purpose;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String url;

  const UploadModel({
    required this.id,
    required this.purpose,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.url,
  });

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    return UploadModel(
      id: json['id'] as String,
      purpose: json['purpose'] as String,
      fileName: json['file_name'] as String,
      contentType: json['content_type'] as String,
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
    );
  }
}
