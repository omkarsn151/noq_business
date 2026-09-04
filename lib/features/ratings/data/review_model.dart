/// One customer review as returned by `v1/business/reviews`. A review may carry
/// no [comment] at all - a silent star rating still counts.
class ReviewModel {
  final String id;
  final String reviewerName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      // The server already shortens this ('Priya S.', 'Anonymous') - print as-is.
      reviewerName: reviewer?['name']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  bool get hasComment => (comment?.trim() ?? '').isNotEmpty;

  /// Falls back to 'Anonymous' when the server sends an empty name.
  String get displayName =>
      reviewerName.trim().isEmpty ? 'Anonymous' : reviewerName.trim();

  /// First letter for the avatar circle.
  String get initial {
    final name = displayName;
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}
