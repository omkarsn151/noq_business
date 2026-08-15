import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme appTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 30.sp,
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary,
    ),

    headlineLarge: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),

    titleLarge: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    titleMedium: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyLarge: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    bodySmall: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    labelLarge: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}
