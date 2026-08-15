import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/features/categories/bloc/categories_bloc.dart';
import 'package:noq_business/features/categories/bloc/categories_event.dart';
import 'package:noq_business/features/categories/bloc/categories_state.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _SubCategoryBottomSheetBody(selected: selected),
    );
  }
}

class _SubCategoryBottomSheetBody extends StatelessWidget {
  final SubCategoryModel? selected;

  const _SubCategoryBottomSheetBody({this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.26.w,
                height: 0.47.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(0.51.w),
                ),
              ),
            ),
            SizedBox(height: 1.9.h),
            Text(
              'Select Sub Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.42.h),
            Expanded(
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading ||
                      state is CategoriesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CategoriesFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 40.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(height: 0.95.h),
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 1.42.h),
                          AppButton(
                            label: 'Retry',
                            onPressed: () => context.read<CategoriesBloc>().add(
                              const SubCategoriesRequested(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is! SubCategoriesSuccess) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final subCategories = state.subCategories;
                  if (subCategories.isEmpty) {
                    return const Center(
                      child: Text('No sub categories available'),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 1.42.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.42.h,
                      crossAxisSpacing: 3.08.w,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = subCategories[index];
                      final isSelected = subCategory.id == selected?.id;
                      return _SubCategoryGridTile(
                        subCategory: subCategory,
                        isSelected: isSelected,
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

class _SubCategoryGridTile extends StatelessWidget {
  final SubCategoryModel subCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryGridTile({
    required this.subCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.08.w),
      child: Container(
        padding: EdgeInsets.all(2.56.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.08.w),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12.31.w,
              height: 12.31.w,
              child: _fallbackIcon(context),
            ),
            SizedBox(height: 0.95.h),
            Text(
              subCategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(2.05.w),
      ),
      child: Icon(Icons.storefront_outlined, size: 26.sp),
    );
  }
}
