class PaginationModel {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginationModel({
    this.page = 1,
    this.pageSize = 0,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory PaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaginationModel();
    return PaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 0,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }

  /// Whether another page can be requested after [page].
  bool get hasMore => page < totalPages;
}
