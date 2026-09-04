import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/section_card.dart';

/// The Services card - up to 5 rows (of the shop's [OverviewServices.total])
/// plus the dashed Add Service button.
class OverviewServicesCard extends StatelessWidget {
  final OverviewServices services;
  final VoidCallback? onManageTap;
  final VoidCallback? onAddTap;
  final ValueChanged<OverviewService>? onServiceTap;

  const OverviewServicesCard({
    super.key,
    required this.services,
    this.onManageTap,
    this.onAddTap,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Services',
      actionLabel: 'Manage',
      onActionTap: onManageTap,
      child: Column(
        children: [
          if (services.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                'No services added yet',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.items.length,
              separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
              itemBuilder: (context, index) {
                final service = services.items[index];
                return _ServiceRow(
                  service: service,
                  onTap: onServiceTap == null
                      ? null
                      : () => onServiceTap!(service),
                );
              },
            ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
                side: BorderSide(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              icon: Icon(Icons.add, size: 16.sp),
              label: const Text('Add Service'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final OverviewService service;
  final VoidCallback? onTap;

  const _ServiceRow({required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: service.thumbnailUrl != null
                  ? Image.network(
                      service.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.design_services_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.design_services_rounded,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    service.subtitleLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
