import 'package:equatable/equatable.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesSuccess extends CategoriesState {
  final List<CategoryModel> categories;

  const CategoriesSuccess({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class SubCategoriesSuccess extends CategoriesState {
  final List<SubCategoryModel> subCategories;

  const SubCategoriesSuccess({required this.subCategories});

  @override
  List<Object?> get props => [subCategories];
}

class CategoriesFailure extends CategoriesState {
  final String message;

  const CategoriesFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
