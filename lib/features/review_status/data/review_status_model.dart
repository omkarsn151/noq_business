import 'package:noq_business/core/enums/business_status.dart';

class ReviewStatusTimelineItemModel {
  final String key;
  final String label;
  final String state;
  final DateTime? at;

  const ReviewStatusTimelineItemModel({
    required this.key,
    required this.label,
    required this.state,
    this.at,
  });

  factory ReviewStatusTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatusTimelineItemModel(
      key: json['key'] as String,
      label: json['label'] as String,
      state: json['state'] as String,
      at: json['at'] != null ? DateTime.parse(json['at'] as String) : null,
    );
  }
}

class ReviewStatusHeaderModel {
  final String icon;
  final String title;
  final String subtitle;

  const ReviewStatusHeaderModel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory ReviewStatusHeaderModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatusHeaderModel(
      icon: json['icon'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }
}

class ReviewStatusSummaryModel {
  final String businessName;
  final String categoryName;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const ReviewStatusSummaryModel({
    required this.businessName,
    required this.categoryName,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory ReviewStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatusSummaryModel(
      businessName: json['business_name'] as String,
      categoryName: json['category_name'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }
}

class ReviewStatusModel {
  final BusinessStatus? reviewStatus;
  final ReviewStatusHeaderModel header;
  final ReviewStatusSummaryModel summary;
  final List<ReviewStatusTimelineItemModel> timeline;

  const ReviewStatusModel({
    required this.reviewStatus,
    required this.header,
    required this.summary,
    required this.timeline,
  });

  factory ReviewStatusModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatusModel(
      reviewStatus: BusinessStatus.fromString(json['review_status'] as String?),
      header: ReviewStatusHeaderModel.fromJson(
        json['header'] as Map<String, dynamic>,
      ),
      summary: ReviewStatusSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      timeline: (json['timeline'] as List)
          .map((e) => ReviewStatusTimelineItemModel.fromJson(
                e as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}
