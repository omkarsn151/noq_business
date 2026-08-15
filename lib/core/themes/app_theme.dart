import 'package:flutter/material.dart';
import 'package:noq_business/core/themes/app_bar_theme.dart';
import 'package:noq_business/core/themes/app_textfield_theme.dart';

import 'app_button_theme.dart';
import '../utils/app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData appTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      error: AppColors.error,
    ),

    textTheme: AppTextTheme.appTextTheme,

    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,

    appBarTheme: AppBarThemes.appBarTheme,

    inputDecorationTheme: AppTextfieldTheme.appTextfieldTheme,

    // fontFamily: 'Inter',
  );
}
