import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/service/bloc/service_bloc.dart';
import 'package:noq_business/features/service/bloc/service_event.dart';
import 'package:noq_business/features/service/data/service_model.dart';

class ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool showDeleteButton;

  const ServiceTile({
    super.key,
    required this.service,
    this.onTap,
    this.showDeleteButton = true,
  });

  String? get _thumbnailUrl {
    if (service.images.thumbnails.isEmpty) return null;
    final url = service.images.thumbnails.first.url;
    return url.isNotEmpty ? url : null;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.delete_outline,
      title: 'Delete Service',
      message: 'Are you sure you want to delete "${service.name}"?',
      primaryLabel: 'Delete',
      secondaryLabel: 'Cancel',
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.primaryLight,
    );
    if (confirmed && context.mounted) {
      context.read<ServiceBloc>().add(
        ServiceDeleteRequested(serviceId: service.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(3.w),
          child: Container(
            width: 23.08.w,
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(3.w),
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
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _thumbnailUrl != null
                      ? Image.network(
                          _thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.design_services_outlined,
                            size: 20.sp,
                          ),
                        )
                      : Icon(Icons.design_services_outlined, size: 20.sp),
                ),
                SizedBox(height: 0.95.h),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (showDeleteButton)
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
