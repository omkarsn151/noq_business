import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noq_business/core/utils/app_colors.dart';
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
        padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(0.9.w),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.5.h),
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
                            color: AppColors.error,
                          ),
                          SizedBox(height: 1.h),
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 1.5.h),
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
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.5.h,
                      crossAxisSpacing: 3.w,
                      childAspectRatio: 1.5,
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
    final theme = Theme.of(context);
    final imageUrl = category.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final radius = BorderRadius.circular(3.w);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 1.5.w,
            )
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, _, _) => _fallback(context),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : _fallback(context),
                ),
              )
            else
              Positioned.fill(child: _fallback(context)),
            // White fade so the left-aligned text stays readable.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5.sp
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    SizedBox(height: 0.35.h),
                    Text(
                      category.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 4.w),
      child: Icon(
        Icons.storefront_outlined,
        size: 20.sp,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
