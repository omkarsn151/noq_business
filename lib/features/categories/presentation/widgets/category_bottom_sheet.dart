import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_search_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/categories/bloc/categories_bloc.dart';
import 'package:noq_business/features/categories/bloc/categories_event.dart';
import 'package:noq_business/features/categories/bloc/categories_state.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';
import 'package:noq_business/features/categories/presentation/widgets/picker_sheet_parts.dart';

class CategoryBottomSheet {
  CategoryBottomSheet._();

  static Future<CategoryModel?> show(
    BuildContext context, {
    CategoryModel? selected,
  }) {
    context.read<CategoriesBloc>().add(const CategoriesRequested());
    return showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _CategoryBottomSheetBody(selected: selected),
    );
  }
}

class _CategoryBottomSheetBody extends StatefulWidget {
  final CategoryModel? selected;

  const _CategoryBottomSheetBody({this.selected});

  @override
  State<_CategoryBottomSheetBody> createState() =>
      _CategoryBottomSheetBodyState();
}

class _CategoryBottomSheetBodyState extends State<_CategoryBottomSheetBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  List<CategoryModel> _filter(List<CategoryModel> categories) {
    if (_query.isEmpty) return categories;
    return categories
        .where((c) => c.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SizedBox(
      height: 78.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PickerSheetHeader(
              title: 'Select Category',
              subtitle: 'Pick the category that best describes your business',
            ),
            SizedBox(height: 1.8.h),
            AppSearchField(
              controller: _searchController,
              hintText: 'Search categories',
              onChanged: _onQueryChanged,
              onClear: () {
                _searchController.clear();
                _onQueryChanged('');
              },
            ),
            Expanded(
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesFailure) {
                    return PickerSheetMessage(
                      icon: Icons.wifi_off_rounded,
                      iconColor: AppColors.error,
                      title: 'Could not load categories',
                      message: state.message,
                      actionLabel: 'Retry',
                      onAction: () => context.read<CategoriesBloc>().add(
                        const CategoriesRequested(),
                      ),
                    );
                  }

                  if (state is! CategoriesSuccess) {
                    return const PickerGridSkeleton();
                  }

                  if (state.categories.isEmpty) {
                    return const PickerSheetMessage(
                      icon: Icons.category_outlined,
                      title: 'No categories available',
                      message: 'Please check back in a little while.',
                    );
                  }

                  final categories = _filter(state.categories);
                  if (categories.isEmpty) {
                    return PickerSheetMessage(
                      icon: Icons.search_off_rounded,
                      title: 'No matches found',
                      message: 'No category matches "${_searchController.text}".',
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      1.6.h,
                      0,
                      1.6.h + keyboardInset,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    gridDelegate: pickerGridDelegate(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return PickerOptionTile(
                        name: category.name,
                        subtitle: category.description,
                        imageUrl: category.imageUrl,
                        isSelected: category.id == widget.selected?.id,
                        onTap: () => Navigator.pop(context, category),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
