import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/core/utils/currency_format.dart';
import 'package:noq_business/features/service/data/service_model.dart';

/// A full-width service row for the Services screen - thumbnail, name, duration
/// and price, and an active/hidden pill. The horizontal-strip [ServiceTile] is
/// fixed-width, so this is its list-shaped sibling. Deleting a service happens
/// from the Add/Edit screen (tap the card to get there), not from this row.
class ServiceListCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceListCard({super.key, required this.service, this.onTap});

  String? get _thumbnailUrl {
    if (service.images.thumbnails.isEmpty) return null;
    final url = service.images.thumbnails.first.url;
    return url.isNotEmpty ? url : null;
  }

  @override
  Widget build(BuildContext context) {
    final description = service.description?.trim();

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
            _Thumbnail(url: _thumbnailUrl),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 0.2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${service.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                        child: Text(
                          '·',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      Text(
                        formatAmount(service.price, service.currencyCode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    SizedBox(height: 0.2.h),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 2.w),
            _StatusPill(isActive: service.isActive),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(3.w),
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

  Widget _placeholder() => Icon(
    Icons.design_services_outlined,
    size: 20.sp,
    color: AppColors.primary,
  );
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
        isActive ? 'Active' : 'Hidden',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}
