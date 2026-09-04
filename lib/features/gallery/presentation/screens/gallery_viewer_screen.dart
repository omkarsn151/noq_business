import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/features/gallery/data/gallery_image_model.dart';

/// Full screen photo viewer - swipe between the loaded pictures, pinch to zoom,
/// tap to hide the chrome.
class GalleryViewerScreen extends StatefulWidget {
  final List<GalleryImageModel> images;
  final int initialIndex;

  /// Must match the prefix the grid gave its tiles, so the Hero pairs up.
  final String heroPrefix;

  const GalleryViewerScreen({
    super.key,
    required this.images,
    required this.heroPrefix,
    this.initialIndex = 0,
  });

  /// Pushes the viewer with a fade, so the Hero flies over a still grid.
  static Future<void> open(
    BuildContext context, {
    required List<GalleryImageModel> images,
    required int initialIndex,
    required String heroPrefix,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => GalleryViewerScreen(
          images: images,
          initialIndex: initialIndex,
          heroPrefix: heroPrefix,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<GalleryViewerScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _showChrome = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.images[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final page = widget.images[index];
              return GestureDetector(
                onTap: () => setState(() => _showChrome = !_showChrome),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Hero(
                      tag: '${widget.heroPrefix}-${page.uploadId}',
                      child: Image.network(
                        page.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_outlined,
                          size: 32.sp,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedOpacity(
            opacity: _showChrome ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showChrome,
              child: Stack(
                children: [
                  _TopBar(position: _index + 1, total: widget.images.length),
                  _CaptionBar(image: image),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int position;
  final int total;

  const _TopBar({required this.position, required this.total});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: 3.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, size: 20.sp),
                  color: Colors.white,
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: Text(
                    '$position / $total',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

class _CaptionBar extends StatelessWidget {
  final GalleryImageModel image;

  const _CaptionBar({required this.image});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(top: 5.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      image.isCover
                          ? Icons.storefront_outlined
                          : Icons.design_services_outlined,
                      size: 15.sp,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: Text(
                        image.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (image.fileName.isNotEmpty) ...[
                  SizedBox(height: 0.4.h),
                  Text(
                    image.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
