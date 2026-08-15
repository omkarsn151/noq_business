enum BusinessStatus {
  businessSetup,
  underReview,
  approved,
  rejected,
  suspended;

  static BusinessStatus? fromString(String? value) {
    switch (value) {
      case 'business_setup':
        return BusinessStatus.businessSetup;
      case 'under_review':
        return BusinessStatus.underReview;
      case 'approved':
        return BusinessStatus.approved;
      case 'rejected':
        return BusinessStatus.rejected;
      case 'suspended':
        return BusinessStatus.suspended;
      default:
        return null;
    }
  }

  String get value {
    switch (this) {
      case BusinessStatus.businessSetup:
        return 'business_setup';
      case BusinessStatus.underReview:
        return 'under_review';
      case BusinessStatus.approved:
        return 'approved';
      case BusinessStatus.rejected:
        return 'rejected';
      case BusinessStatus.suspended:
        return 'suspended';
    }
  }
}
