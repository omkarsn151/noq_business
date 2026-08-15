import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested();
}

class SubCategoriesRequested extends CategoriesEvent {
  const SubCategoriesRequested();
}
