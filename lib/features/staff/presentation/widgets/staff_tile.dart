import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/staff/bloc/staff_bloc.dart';
import 'package:noq_business/features/staff/bloc/staff_event.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';

class StaffTile extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback? onTap;
  final bool showDelete;

  const StaffTile({
    super.key,
    required this.staff,
    this.onTap,
    this.showDelete = true,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete Staff',
      message: 'Are you sure you want to delete "${staff.name}"?',
      primaryLabel: 'Delete',
      secondaryLabel: 'Cancel',
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.primaryLight,
    );
    if (confirmed && context.mounted) {
      context.read<StaffBloc>().add(StaffDeleteRequested(staffId: staff.id));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: staff.photo != null && staff.photo!.url.isNotEmpty
                      ? Image.network(
                          staff.photo!.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.person_outline, size: 20.sp),
                        )
                      : Icon(Icons.person_outline, size: 20.sp),
                ),
                SizedBox(height: 0.95.h),
                Text(
                  staff.name,
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
        if (showDelete)
          Positioned(
            top: 0.h,
            right: 0.0.w,
            child: InkWell(
              onTap: () => _confirmDelete(context),
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
