import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

enum PickSource { image, pdf }

class PickSourceSheet {
  PickSourceSheet._();

  static Future<PickSource?> show(BuildContext context) {
    return showModalBottomSheet<PickSource>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => const _PickSourceSheetBody(),
    );
  }
}

class _PickSourceSheetBody extends StatelessWidget {
  const _PickSourceSheetBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: 2.h),
            Text(
              'Upload Document',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 0.4.h),
            Text(
              'Choose how you want to add your file',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 1.9.h),
            _SourceOption(
              icon: Icons.image_outlined,
              iconColor: AppColors.blue,
              title: 'Choose Image',
              subtitle: 'JPG, PNG or other image formats',
              onTap: () => Navigator.pop(context, PickSource.image),
            ),
            SizedBox(height: 1.3.h),
            _SourceOption(
              icon: Icons.picture_as_pdf_outlined,
              iconColor: AppColors.error,
              title: 'Choose PDF',
              subtitle: 'Upload a PDF document',
              onTap: () => Navigator.pop(context, PickSource.pdf),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.08.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.6.h),
        decoration: BoxDecoration(
          color: AppColors.textfieldFilledColor,
          borderRadius: BorderRadius.circular(3.08.w),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.3.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2.6.w),
              ),
              child: Icon(icon, size: 22.sp, color: iconColor),
            ),
            SizedBox(width: 3.6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
