enum PromotionStatus {
  active('Active', 'active'),
  expired('Expired', 'expired'),
  inactive('Inactive', 'inactive'),
  draft('Drafts', 'drafts');

  /// Tab label.
  final String label;

  /// Value used for the `status` query parameter and the meta counts key.
  final String value;

  const PromotionStatus(this.label, this.value);

  static PromotionStatus fromValue(String? value) {
    return PromotionStatus.values.firstWhere(
      (status) => status.value == value || status.name == value,
      orElse: () => PromotionStatus.draft,
    );
  }
}
