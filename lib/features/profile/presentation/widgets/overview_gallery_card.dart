import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/profile/data/business_overview_model.dart';
import 'package:noq_business/features/profile/presentation/widgets/section_card.dart';

/// A row of up to 5 thumbnails (covers first, then service photos) with a
/// '+N' overlay on the last tile when [OverviewGallery.total] runs over that.
class OverviewGalleryCard extends StatelessWidget {
  final OverviewGallery gallery;
  final VoidCallback? onManageTap;
  final VoidCallback? onAddTap;

  const OverviewGalleryCard({
    super.key,
    required this.gallery,
    this.onManageTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Gallery',
      actionLabel: 'Manage',
      onActionTap: onManageTap,
      child: Column(
        children: [
          if (gallery.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                'No photos added yet',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Row(
              children: List.generate(gallery.items.length, (index) {
                final isLast = index == gallery.items.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isLast ? 0 : 2.w,
                    ),
                    child: _GalleryTile(
                      image: gallery.items[index],
                      overflowCount: isLast ? gallery.overflowCount : 0,
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final OverviewGalleryImage image;
  final int overflowCount;

  const _GalleryTile({required this.image, this.overflowCount = 0});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primaryLight,
                child: Icon(Icons.image_outlined, size: 16.sp, color: AppColors.primary),
              ),
            ),
            if (overflowCount > 0)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: Text(
                  '+$overflowCount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
