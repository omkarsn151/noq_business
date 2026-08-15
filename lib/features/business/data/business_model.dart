class BusinessDocumentModel {
  final String id;
  final String uploadId;
  final String docType;
  final String status;
  final String fileName;
  final String url;
  final String? rejectionReason;

  const BusinessDocumentModel({
    required this.id,
    required this.uploadId,
    required this.docType,
    required this.status,
    required this.fileName,
    required this.url,
    this.rejectionReason,
  });

  factory BusinessDocumentModel.fromJson(Map<String, dynamic> json) {
    return BusinessDocumentModel(
      id: json['id'] as String,
      uploadId: json['upload_id'] as String,
      docType: json['doc_type'] as String,
      status: json['status'] as String,
      fileName: json['file_name'] as String,
      url: json['url'] as String,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}

class BusinessDetailsModel {
  final String name;
  final String categoryId;
  final String categoryName;
  final String description;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String gstNumber;

  const BusinessDetailsModel({
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.gstNumber,
  });

  factory BusinessDetailsModel.fromJson(Map<String, dynamic> json) {
    return BusinessDetailsModel(
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      description: json['description'] as String,
      addressLine: json['address_line'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      gstNumber: json['gst_number'] as String,
    );
  }
}

class BusinessModel {
  final String id;
  final BusinessDetailsModel business;
  final List<BusinessDocumentModel> documents;

  const BusinessModel({
    required this.id,
    required this.business,
    required this.documents,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      business: BusinessDetailsModel.fromJson(
        json['business'] as Map<String, dynamic>,
      ),
      documents: (json['documents'] as List)
          .map((e) => BusinessDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
