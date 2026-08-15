import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class AppTextfieldTheme {
  AppTextfieldTheme._();

  static InputDecorationTheme get appTextfieldTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.textfieldFilledColor,

    contentPadding: EdgeInsets.symmetric(horizontal: 4.1.w, vertical: 1.9.h),

    hintStyle: TextStyle(
      fontSize: 15.sp,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w400,
    ),

    labelStyle: TextStyle(
      fontSize: 15.sp,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),

    floatingLabelStyle: TextStyle(
      fontSize: 15.sp,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),

    errorStyle: TextStyle(fontSize: 13.5.sp, color: AppColors.error),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.w),
      borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.w),
      borderSide: const BorderSide(color: AppColors.border, width: 1.5),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.w),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(3.w),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
