import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AppBarThemes {
  AppBarThemes._();

  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,

    titleTextStyle: TextStyle(
      // fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}
