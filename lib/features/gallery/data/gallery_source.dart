/// Where one gallery picture came from. Doubles as the list tabs, so [all]
/// carries a null [value] and is simply omitted from the query.
enum GallerySource {
  all('All', null),
  businessCover('Shop', 'business_cover'),
  service('Services', 'service');

  /// Tab label.
  final String label;

  /// Value used for the `source` query parameter and on each gallery row.
  /// Null on [all], which means "no filter".
  final String? value;

  const GallerySource(this.label, this.value);

  /// Parses the `source` field of a gallery row. A row never says `all`, so an
  /// unknown value falls back to [service] - the only kind that can be captioned.
  static GallerySource fromValue(String? value) {
    return GallerySource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => GallerySource.service,
    );
  }
}
