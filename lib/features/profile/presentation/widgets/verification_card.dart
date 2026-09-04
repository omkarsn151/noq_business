import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/section_card.dart';

/// The three KYC document rows - license, ID proof, tax document, always in
/// that order.
class VerificationCard extends StatelessWidget {
  final OverviewVerification verification;
  final VoidCallback? onManageTap;
  final ValueChanged<OverviewDocument>? onDocumentTap;

  const VerificationCard({
    super.key,
    required this.verification,
    this.onManageTap,
    this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = verification.items;
    return SectionCard(
      title: 'Business Verification',
      actionLabel: 'Manage',
      onActionTap: onManageTap,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
        itemBuilder: (context, index) {
          final document = items[index];
          return _DocumentRow(
            document: document,
            onTap: onDocumentTap == null ? null : () => onDocumentTap!(document),
          );
        },
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final OverviewDocument document;
  final VoidCallback? onTap;

  const _DocumentRow({required this.document, this.onTap});

  (IconData, Color) get _statusVisual {
    switch (document.status) {
      case VerificationStatus.verified:
        return (Icons.check_circle_outline, AppColors.success);
      case VerificationStatus.pending:
        return (Icons.schedule_rounded, AppColors.orange);
      case VerificationStatus.rejected:
        return (Icons.cancel_outlined, AppColors.error);
      case VerificationStatus.notUploaded:
        return (Icons.upload_file_outlined, AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _statusVisual;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Row(
        children: [
          Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(document.label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            document.statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 1.w),
          Icon(Icons.chevron_right, size: 16.sp, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
