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

class SubCategoryBottomSheet {
  SubCategoryBottomSheet._();

  static Future<SubCategoryModel?> show(
    BuildContext context, {
    SubCategoryModel? selected,
  }) {
    context.read<CategoriesBloc>().add(const SubCategoriesRequested());
    return showModalBottomSheet<SubCategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _SubCategoryBottomSheetBody(selected: selected),
    );
  }
}

class _SubCategoryBottomSheetBody extends StatefulWidget {
  final SubCategoryModel? selected;

  const _SubCategoryBottomSheetBody({this.selected});

  @override
  State<_SubCategoryBottomSheetBody> createState() =>
      _SubCategoryBottomSheetBodyState();
}

class _SubCategoryBottomSheetBodyState
    extends State<_SubCategoryBottomSheetBody> {
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

  List<SubCategoryModel> _filter(List<SubCategoryModel> subCategories) {
    if (_query.isEmpty) return subCategories;
    return subCategories
        .where((s) => s.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SizedBox(
      height: 80.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PickerSheetHeader(
              title: 'Select Sub Category',
              subtitle: 'Choose the sub category this service belongs to',
            ),
            SizedBox(height: 1.8.h),
            AppSearchField(
              controller: _searchController,
              hintText: 'Search sub categories',
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
                      title: 'Could not load sub categories',
                      message: state.message,
                      actionLabel: 'Retry',
                      onAction: () => context.read<CategoriesBloc>().add(
                        const SubCategoriesRequested(),
                      ),
                    );
                  }

                  if (state is! SubCategoriesSuccess) {
                    return const PickerGridSkeleton();
                  }

                  if (state.subCategories.isEmpty) {
                    return const PickerSheetMessage(
                      icon: Icons.layers_outlined,
                      title: 'No sub categories available',
                      message: 'Please check back in a little while.',
                    );
                  }

                  final subCategories = _filter(state.subCategories);
                  if (subCategories.isEmpty) {
                    return PickerSheetMessage(
                      icon: Icons.search_off_rounded,
                      title: 'No matches found',
                      message:
                          'No sub category matches "${_searchController.text}".',
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
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = subCategories[index];
                      return PickerOptionTile(
                        name: subCategory.name,
                        imageUrl: subCategory.imageUrl,
                        fallbackIcon: Icons.design_services_outlined,
                        isSelected: subCategory.id == widget.selected?.id,
                        onTap: () => Navigator.pop(context, subCategory),
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
