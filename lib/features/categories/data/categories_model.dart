class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
}

class SubCategoryModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? slug;
  final String? imageUrl;
  final String? description;

  const SubCategoryModel({
    required this.id,
    required this.name,
    this.categoryId,
    this.slug,
    this.imageUrl,
    this.description,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
}
