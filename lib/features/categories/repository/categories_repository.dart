import 'package:noq_business/core/api/api_endpoints.dart';
import 'package:noq_business/core/api/dio_client.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';

class CategoriesRepository {
  final DioClient _dioClient;

  CategoriesRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get(ApiEndpoints.getCategories);

    final data = response.data['data'] as List;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SubCategoryModel>> getSubCategories() async {
    final response = await _dioClient.get(ApiEndpoints.getSubCategories);

    final data = response.data['data'] as List;
    return data
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
