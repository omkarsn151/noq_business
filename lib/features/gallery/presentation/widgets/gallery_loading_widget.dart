import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering placeholder shown while a gallery tab is loading, shaped to
/// match [GalleryGrid]'s 3-column tile grid.
class GalleryLoadingWidget extends StatelessWidget {
  const GalleryLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 12.h),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
        ),
        itemCount: 12,
        itemBuilder: (_, _) => AspectRatio(
          aspectRatio: 1,
          child: Bone(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
      ),
    );
  }
}
