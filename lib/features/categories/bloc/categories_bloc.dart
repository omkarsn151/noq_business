import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/api/api_exception.dart';
import 'package:noq_business/features/categories/bloc/categories_event.dart';
import 'package:noq_business/features/categories/bloc/categories_state.dart';
import 'package:noq_business/features/categories/repository/categories_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesBloc(this._repository) : super(const CategoriesInitial()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<SubCategoriesRequested>(_onSubCategoriesRequested);
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoriesSuccess(categories: categories));
    } on ApiException catch (e) {
      emit(CategoriesFailure(message: e.message));
    } catch (e) {
      emit(CategoriesFailure(message: e.toString()));
    }
  }

  Future<void> _onSubCategoriesRequested(
    SubCategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final subCategories = await _repository.getSubCategories();
      emit(SubCategoriesSuccess(subCategories: subCategories));
    } on ApiException catch (e) {
      emit(CategoriesFailure(message: e.message));
    } catch (e) {
      emit(CategoriesFailure(message: e.toString()));
    }
  }
}
