import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/staff/data/staff_model.dart';

/// A full-width team-member row for the Staff screen - avatar, name, working
/// hours and the number of services they cover, plus an active/inactive pill.
/// The compact [StaffTile] is the fixed-width sibling used on the dashboard.
class StaffListCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback? onTap;

  const StaffListCard({super.key, required this.staff, this.onTap});

  String? get _photoUrl {
    final url = staff.photo?.url;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  @override
  Widget build(BuildContext context) {
    final serviceCount = staff.services.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.w),
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 12),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(url: _photoUrl),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 0.4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${staff.worksFrom} - ${staff.worksTo}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.design_services_rounded,
                        size: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        serviceCount == 0
                            ? 'No services assigned'
                            : '$serviceCount '
                                  '${serviceCount == 1 ? 'service' : 'services'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            _StatusPill(isActive: staff.isActive),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;

  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _placeholder()
          : Image.network(
              url!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Center(
                      child: SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (_, _, _) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person_outline, size: 20.sp, color: AppColors.primary);
}

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.borderLight,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}
