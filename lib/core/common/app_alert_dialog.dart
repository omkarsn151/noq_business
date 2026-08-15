import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class AppAlertDialog {
  AppAlertDialog._();

  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String primaryLabel = 'Yes',
    String secondaryLabel = 'No',
    Color? iconColor,
    Color? iconBackgroundColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32.sp,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.5.h),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: primaryLabel,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
