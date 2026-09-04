import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Pill-shaped search field shared by list screens - a fully rounded
/// stadium border in [AppColors.primary], a primary-colored search icon,
/// and an optional clear button once there's a query.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  /// Called when the clear (x) button is tapped. Only shown when the field
  /// currently has text.
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller?.text.isNotEmpty ?? false;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.w),
      borderSide: const BorderSide(color: AppColors.primary),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText ?? 'Search',
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20.sp),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 17.sp,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(vertical: 1.7.h),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
