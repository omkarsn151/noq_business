import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final _Style s = _styleFor(type);

    final snackBar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(1.6.w),
            decoration: BoxDecoration(
              color: s.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(s.icon, color: s.fg, size: 16.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.background,
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.5.w),
        side: BorderSide(color: s.fg.withValues(alpha: 0.25), width: 1.5),
      ),
      duration: duration,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: AppColors.primary,
            )
          : null,
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.info,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.warning,
      duration: duration,
    );
  }

  static _Style _styleFor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return _Style(
          fg: AppColors.success,
          tint: AppColors.success.withValues(alpha: 0.12),
          icon: Icons.check_circle_rounded,
        );
      case AppSnackBarType.error:
        return _Style(
          fg: AppColors.error,
          tint: AppColors.error.withValues(alpha: 0.10),
          icon: Icons.error_rounded,
        );
      case AppSnackBarType.warning:
        return _Style(
          fg: AppColors.orange,
          tint: AppColors.orange.withValues(alpha: 0.14),
          icon: Icons.warning_amber_rounded,
        );
      case AppSnackBarType.info:
        return _Style(
          fg: AppColors.primary,
          tint: AppColors.primaryLight,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _Style {
  final Color fg;
  final Color tint;
  final IconData icon;
  const _Style({required this.fg, required this.tint, required this.icon});
}
