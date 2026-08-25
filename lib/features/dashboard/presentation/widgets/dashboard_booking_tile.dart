import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class DashboardBookingTile extends StatelessWidget {
  final String customerName;
  final String serviceName;
  final String duration;
  final String staffName;
  final String time;
  final VoidCallback? onTap;

  const DashboardBookingTile({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.duration,
    required this.staffName,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.75.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 15),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
              width: 1.25.w,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2.w)              ),
            ),
              Expanded(
                child: Padding(
                 padding: EdgeInsets.only(left: 3.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '$serviceName  \u2022  $duration',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              staffName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
