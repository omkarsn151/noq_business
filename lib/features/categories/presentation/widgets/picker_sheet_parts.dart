import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Shared chrome for the category / sub category pickers so both sheets look
/// and behave the same: grab handle, title block with a close button,
/// shimmering placeholders while loading, and a common empty / error state.

class PickerSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PickerSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 10.26.w,
            height: 0.47.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(0.51.w),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                padding: EdgeInsets.all(1.6.w),
                decoration: const BoxDecoration(
                  color: AppColors.textfieldFilledColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 17.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Centered icon + message block used for the error and empty states.
class PickerSheetMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PickerSheetMessage({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = AppColors.textSecondary,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28.sp, color: iconColor),
            ),
            SizedBox(height: 1.8.h),
            Text(title, textAlign: TextAlign.center, style: textTheme.labelLarge),
            if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: 0.6.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 2.2.h),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 8.w),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid delegate shared by both pickers so the tiles line up identically.
SliverGridDelegate pickerGridDelegate() {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 1.6.h,
    crossAxisSpacing: 3.08.w,
    childAspectRatio: 1.45,
  );
}

/// Placeholder tiles shown while the list is loading, shaped to match
/// [PickerOptionTile]'s bottom-left name and subtitle.
class PickerGridSkeleton extends StatelessWidget {
  final int itemCount;

  const PickerGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        gridDelegate: pickerGridDelegate(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _PickerTileSkeleton(),
      ),
    );
  }
}

class _PickerTileSkeleton extends StatelessWidget {
  const _PickerTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.08.w),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: EdgeInsets.fromLTRB(3.2.w, 3.w, 3.2.w, 3.w),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Bone.text(width: 22.w, fontSize: 15),
          SizedBox(height: 0.6.h),
          Bone.text(width: 16.w),
        ],
      ),
    );
  }
}

/// A single selectable option tile - a full bleed image with a white fade so
/// the left aligned label stays readable, a primary ring plus check badge when
/// selected, and an icon fallback when there is no image.
class PickerOptionTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const PickerOptionTile({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.imageUrl,
    this.fallbackIcon = Icons.storefront_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(4.w);
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 2.5.w : 1.5.w,
              offset: Offset(0, 0.3.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, _, _) => _fallback(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : _fallback(),
                )
              else
                _fallback(),
              // White fade so the left-aligned text stays readable.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.background.withValues(alpha: 0.90),
                      AppColors.background.withValues(alpha: 0.50),
                      AppColors.background.withValues(alpha: 0.05),
                      AppColors.background.withValues(alpha: 0.00),
                      AppColors.background.withValues(alpha: 0.00),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(3.2.w, 3.w, 8.w, 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: 0.4.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 2.2.w,
                right: 2.2.w,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isSelected ? 1 : 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 19.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 4.w),
      child: Icon(
        fallbackIcon,
        size: 24.sp,
        color: AppColors.primary.withValues(alpha: 0.45),
      ),
    );
  }
}
