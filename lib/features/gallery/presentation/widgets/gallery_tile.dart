import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/gallery/data/gallery_image_model.dart';

/// One square picture in the gallery grid. Cover photos get a "Shop" pill,
/// service pictures get their service name on a bottom scrim.
class GalleryTile extends StatelessWidget {
  final GalleryImageModel image;

  /// The same picture shows up in more than one tab, and [TabBarView] mounts
  /// the neighbouring tab while swiping - so the tag is scoped to the tab.
  final String heroTag;
  final VoidCallback? onTap;

  const GalleryTile({
    super.key,
    required this.image,
    required this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: Material(
          color: AppColors.primaryLight,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  child: Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const _TilePlaceholder(loading: true);
                    },
                    errorBuilder: (_, _, _) => const _TilePlaceholder(),
                  ),
                ),
                if (image.isCover)
                  Positioned(
                    top: 1.5.w,
                    left: 1.5.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Shop',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (image.serviceName != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(2.w, 3.h, 2.w, 1.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                      child: Text(
                        image.serviceName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared stand-in while a picture loads or when it fails to load.
class _TilePlaceholder extends StatelessWidget {
  final bool loading;

  const _TilePlaceholder({this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              height: 5.w,
              width: 5.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(Icons.image_outlined, size: 16.sp, color: AppColors.primary),
    );
  }
}
