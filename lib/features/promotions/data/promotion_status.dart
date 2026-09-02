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

/// The wire `status` is only `draft` | `published`; the four [PromotionStatus]
/// values are the list tabs. This maps `status` + the pause switch + the end
/// date to the tab the promo actually belongs to.
PromotionStatus resolvePromotionStatus({
  required String? rawStatus,
  required bool isActive,
  DateTime? validUntil,
}) {
  if (rawStatus != 'published') return PromotionStatus.draft;
  if (validUntil != null && validUntil.toUtc().isBefore(DateTime.now().toUtc())) {
    return PromotionStatus.expired;
  }
  return isActive ? PromotionStatus.active : PromotionStatus.inactive;
}
