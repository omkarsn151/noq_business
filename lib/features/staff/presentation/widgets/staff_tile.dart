import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Avatar card for one team member. Takes the name and photo rather than a
/// model, so the dashboard's lighter staff payload can use it too.
class StaffTile extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final VoidCallback? onTap;

  /// Shows the delete badge when provided.
  final VoidCallback? onDelete;

  const StaffTile({
    super.key,
    required this.name,
    this.photoUrl,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final photo = photoUrl;

    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 24.w,
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: photo != null && photo.isNotEmpty
                      ? Image.network(
                          photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.person_outline, size: 20.sp),
                        )
                      : Icon(Icons.person_outline, size: 20.sp),
                ),
                SizedBox(height: 0.95.h),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 0.h,
            right: 0.0.w,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(10.w),
              child: Container(
                padding: EdgeInsets.all(1.03.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14.sp, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
