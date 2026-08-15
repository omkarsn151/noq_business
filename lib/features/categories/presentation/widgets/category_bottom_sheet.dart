import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/features/categories/bloc/categories_bloc.dart';
import 'package:noq_business/features/categories/bloc/categories_event.dart';
import 'package:noq_business/features/categories/bloc/categories_state.dart';
import 'package:noq_business/features/categories/data/categories_model.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => _CategoryBottomSheetBody(selected: selected),
    );
  }
}

class _CategoryBottomSheetBody extends StatelessWidget {
  final CategoryModel? selected;

  const _CategoryBottomSheetBody({this.selected});

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
              'Select Category',
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
                              const CategoriesRequested(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is! CategoriesSuccess) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = state.categories;
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories available'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 1.42.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.42.h,
                      crossAxisSpacing: 3.08.w,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category.id == selected?.id;
                      return _CategoryGridTile(
                        category: category,
                        isSelected: isSelected,
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

class _CategoryGridTile extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageKey = category.imageKey;

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
            Stack(
              children: [
                SizedBox(
                  width: 12.31.w,
                  height: 12.31.w,
                  child: (imageKey != null && imageKey.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(2.05.w),
                          child: Image.network(
                            imageKey,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallbackIcon(context),
                          ),
                        )
                      : _fallbackIcon(context),
                ),
              ],
            ),
            SizedBox(height: 0.95.h),
            Text(
              category.name,
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
