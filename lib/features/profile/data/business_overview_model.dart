import 'package:noq_business/core/utils/currency_format.dart';

/// Where a KYC paper stands. The API sends four values and leaves the wording
/// on screen to us.
enum VerificationStatus { notUploaded, pending, verified, rejected }

VerificationStatus _verificationStatusFrom(String? value) {
  switch (value) {
    case 'verified':
      return VerificationStatus.verified;
    case 'pending':
      return VerificationStatus.pending;
    case 'rejected':
      return VerificationStatus.rejected;
    default:
      return VerificationStatus.notUploaded;
  }
}

/// The address split into fields, for the Edit screen. Every part is null
/// until the owner saves one.
class OverviewAddressParts {
  final String? addressLine;
  final String? city;
  final String? state;
  final String? postalCode;

  const OverviewAddressParts({
    this.addressLine,
    this.city,
    this.state,
    this.postalCode,
  });

  factory OverviewAddressParts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewAddressParts();
    return OverviewAddressParts(
      addressLine: json['address_line']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
    );
  }
}

/// The header block - name, category, photo and the ready-to-print address.
class OverviewProfile {
  final String id;
  final String name;
  final String categoryName;

  /// One printable line. Null until they save an address.
  final String? address;
  final OverviewAddressParts addressParts;

  /// Null until they upload a photo.
  final String? imageUrl;

  const OverviewProfile({
    this.id = '',
    this.name = '',
    this.categoryName = '',
    this.address,
    this.addressParts = const OverviewAddressParts(),
    this.imageUrl,
  });

  factory OverviewProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewProfile();
    return OverviewProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      address: json['address']?.toString(),
      addressParts: OverviewAddressParts.fromJson(
        json['address_parts'] as Map<String, dynamic>?,
      ),
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// The address line, or a prompt to add one.
  String get addressLabel {
    final line = address?.trim();
    return line == null || line.isEmpty ? 'No address added yet' : line;
  }

  bool get hasAddress => (address?.trim() ?? '').isNotEmpty;
}

/// The star tile. [average] and [totalReviews] are null together on a shop
/// with no reviews - never 0, because a zero-star shop and a brand-new shop
/// are different things.
class OverviewRating {
  final double? average;
  final int? totalReviews;

  const OverviewRating({this.average, this.totalReviews});

  factory OverviewRating.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewRating();
    return OverviewRating(
      average: (json['average'] as num?)?.toDouble(),
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
    );
  }

  bool get hasRating => average != null;

  /// '4.8' - a dash while the shop has no reviews at all.
  String get averageLabel => average?.toStringAsFixed(1) ?? '-';

  /// '326 reviews' / 'No reviews yet'
  String get reviewsCountLabel {
    final total = totalReviews;
    if (total == null || total == 0) return 'No reviews yet';
    return '$total ${total == 1 ? 'review' : 'reviews'}';
  }
}

/// The two stat tiles beside the rating - the star and the Verified badge.
class OverviewStats {
  final OverviewRating rating;
  final bool isVerified;

  const OverviewStats({
    this.rating = const OverviewRating(),
    this.isVerified = false,
  });

  factory OverviewStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewStats();
    return OverviewStats(
      rating: OverviewRating.fromJson(json['rating'] as Map<String, dynamic>?),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  /// 'Verified' / 'Unverified' - the tile's value line.
  String get verifiedLabel => isVerified ? 'Verified' : 'Unverified';
}

/// One speech-bubble card. Only reviews with words reach this list; silent
/// star ratings still count towards [OverviewRating].
class OverviewReview {
  final String id;
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const OverviewReview({
    this.id = '',
    this.reviewerName = '',
    this.rating = 0,
    this.comment = '',
    this.createdAt,
  });

  factory OverviewReview.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return OverviewReview(
      id: json['id']?.toString() ?? '',
      // Already shortened by the server ('Priya S.') - print it as-is.
      reviewerName: reviewer?['name']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  /// '- Priya S.'
  String get attributionLabel => '- $reviewerName';
}

/// The Ratings & Reviews carousel - up to 5 cards, newest first. There is no
/// count here on purpose; print [OverviewRating.reviewsCountLabel] instead.
class OverviewReviews {
  final List<OverviewReview> items;

  const OverviewReviews({this.items = const []});

  factory OverviewReviews.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewReviews();
    return OverviewReviews(
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OverviewReview.fromJson)
          .toList(),
    );
  }
}

/// One row in the Services card.
class OverviewService {
  final String id;
  final String name;
  final int durationMinutes;

  /// Decimal string, e.g. '499.00'.
  final String price;
  final String currencyCode;

  /// Switched-off services are listed too - this is the shop's own catalogue.
  final bool isActive;
  final String? thumbnailUrl;

  const OverviewService({
    this.id = '',
    this.name = '',
    this.durationMinutes = 0,
    this.price = '0',
    this.currencyCode = '',
    this.isActive = true,
    this.thumbnailUrl,
  });

  factory OverviewService.fromJson(Map<String, dynamic> json) {
    return OverviewService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      price: json['price']?.toString() ?? '0',
      currencyCode: json['currency_code']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      thumbnailUrl: json['thumbnail_url']?.toString(),
    );
  }

  /// '30 min - 499'
  String get subtitleLabel =>
      '$durationMinutes min · ${formatAmount(price, currencyCode)}';
}

/// The Services card - [total] is the whole catalogue, [items] the first 5.
class OverviewServices {
  final int total;
  final List<OverviewService> items;

  const OverviewServices({this.total = 0, this.items = const []});

  factory OverviewServices.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewServices();
    return OverviewServices(
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OverviewService.fromJson)
          .toList(),
    );
  }
}

/// One gallery tile. Cover photos come first, then service pictures.
class OverviewGalleryImage {
  final String uploadId;
  final String fileName;
  final String url;

  /// 'business_cover' or 'service'.
  final String source;

  /// Null when [source] is 'business_cover' - a cover belongs to the shop.
  final String? serviceId;
  final String? serviceName;

  const OverviewGalleryImage({
    this.uploadId = '',
    this.fileName = '',
    this.url = '',
    this.source = '',
    this.serviceId,
    this.serviceName,
  });

  factory OverviewGalleryImage.fromJson(Map<String, dynamic> json) {
    return OverviewGalleryImage(
      uploadId: json['upload_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name']?.toString(),
    );
  }

  bool get isCover => source == 'business_cover';
}

/// The Gallery card - [total] counts every picture, [items] is the first 5,
/// so the last visible tile carries a '+N' overlay.
class OverviewGallery {
  final int total;
  final List<OverviewGalleryImage> items;

  const OverviewGallery({this.total = 0, this.items = const []});

  factory OverviewGallery.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewGallery();
    return OverviewGallery(
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OverviewGalleryImage.fromJson)
          .toList(),
    );
  }

  bool get hasMore => total > items.length;

  /// How many pictures sit behind the '+N' tile.
  int get overflowCount => hasMore ? total - items.length : 0;
}

/// One KYC row. A paper that was never attached still comes back, as
/// [VerificationStatus.notUploaded] with no file.
class OverviewDocument {
  final String docType;

  /// Server-supplied row title, e.g. 'Business License'.
  final String label;
  final VerificationStatus status;
  final String? fileName;
  final String? url;
  final String? rejectionReason;

  const OverviewDocument({
    this.docType = '',
    this.label = '',
    this.status = VerificationStatus.notUploaded,
    this.fileName,
    this.url,
    this.rejectionReason,
  });

  factory OverviewDocument.fromJson(Map<String, dynamic> json) {
    return OverviewDocument(
      docType: json['doc_type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      status: _verificationStatusFrom(json['status']?.toString()),
      fileName: json['file_name']?.toString(),
      url: json['url']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  /// The word printed at the end of the row.
  String get statusLabel {
    switch (status) {
      case VerificationStatus.verified:
        return 'Uploaded';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.notUploaded:
        return 'Not uploaded';
    }
  }
}

/// The KYC card - always exactly three rows, in the order license, id_proof,
/// tax_document.
class OverviewVerification {
  final List<OverviewDocument> items;

  const OverviewVerification({this.items = const []});

  factory OverviewVerification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OverviewVerification();
    return OverviewVerification(
      items: (json['items'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OverviewDocument.fromJson)
          .toList(),
    );
  }
}

/// Everything the Business Profile screen draws, in one call, grouped by
/// section of the screen.
class BusinessOverviewModel {
  final OverviewProfile profile;
  final OverviewStats stats;
  final OverviewReviews reviews;
  final OverviewServices services;
  final OverviewGallery gallery;
  final OverviewVerification verification;

  const BusinessOverviewModel({
    this.profile = const OverviewProfile(),
    this.stats = const OverviewStats(),
    this.reviews = const OverviewReviews(),
    this.services = const OverviewServices(),
    this.gallery = const OverviewGallery(),
    this.verification = const OverviewVerification(),
  });

  /// Takes the full response envelope and reads `data`.
  factory BusinessOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return BusinessOverviewModel(
      profile: OverviewProfile.fromJson(
        data['profile'] as Map<String, dynamic>?,
      ),
      stats: OverviewStats.fromJson(data['stats'] as Map<String, dynamic>?),
      reviews: OverviewReviews.fromJson(
        data['reviews'] as Map<String, dynamic>?,
      ),
      services: OverviewServices.fromJson(
        data['services'] as Map<String, dynamic>?,
      ),
      gallery: OverviewGallery.fromJson(
        data['gallery'] as Map<String, dynamic>?,
      ),
      verification: OverviewVerification.fromJson(
        data['verification'] as Map<String, dynamic>?,
      ),
    );
  }
}
