import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/dashboard/presentation/widgets/dashboard_section_header.dart';

/// White rounded card shell shared by every section on the Business Profile
/// screen - title + optional action row, then the section's own content.
class SectionCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: title,
            actionLabel: actionLabel,
            onActionTap: onActionTap,
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}
