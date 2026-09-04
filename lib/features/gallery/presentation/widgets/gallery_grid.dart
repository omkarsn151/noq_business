import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/gallery/bloc/gallery_bloc.dart';
import 'package:noq_business/features/gallery/bloc/gallery_event.dart';
import 'package:noq_business/features/gallery/bloc/gallery_state.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';
import 'package:noq_business/features/gallery/presentation/screens/gallery_viewer_screen.dart';
import 'package:noq_business/features/gallery/presentation/widgets/gallery_tile.dart';

/// The picture grid of one tab, including its loading, empty and error states.
class GalleryGrid extends StatelessWidget {
  final GallerySource source;
  final GalleryTabState tab;

  const GalleryGrid({super.key, required this.source, required this.tab});

  void _loadFirstPage(BuildContext context) {
    context.read<GalleryBloc>().add(
      GalleryRefreshRequested(source: source),
    );
  }

  /// Requests the next page once the grid is scrolled near its end.
  bool _onScroll(BuildContext context, ScrollNotification notification) {
    final position = notification.metrics;
    if (position.axis != Axis.vertical) return false;

    if (tab.hasMore &&
        !tab.isLoadingMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      context.read<GalleryBloc>().add(GalleryNextPageRequested(source: source));
    }
    return false;
  }

  String get _emptyMessage => switch (source) {
    GallerySource.businessCover => 'No shop photos yet',
    GallerySource.service => 'No service photos yet',
    GallerySource.all => 'No photos yet',
  };

  String get _emptyHint => switch (source) {
    GallerySource.businessCover =>
      'Cover photos added in Business Setup show up here.',
    GallerySource.service =>
      'Photos attached to your services show up here.',
    GallerySource.all =>
      'Add cover photos to your shop or pictures to your services.',
  };

  @override
  Widget build(BuildContext context) {
    if (tab.status == GalleryTabStatus.initial ||
        tab.status == GalleryTabStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tab.status == GalleryTabStatus.failure) {
      if (tab.businessNotFound) {
        return _GalleryMessage(
          icon: Icons.storefront_outlined,
          title: "You don't have a business yet",
          hint: 'Set up your shop to start building its gallery.',
          actionLabel: 'Set up business',
          onAction: () => context.push('/business-setup'),
        );
      }
      return _GalleryMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load the gallery',
        hint: tab.message,
        actionLabel: 'Retry',
        onAction: () => _loadFirstPage(context),
      );
    }

    if (tab.images.isEmpty) {
      return _GalleryMessage(
        icon: Icons.photo_library_outlined,
        title: _emptyMessage,
        hint: _emptyHint,
        actionLabel: 'Refresh',
        onAction: () => _loadFirstPage(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,      
      onRefresh: () async => _loadFirstPage(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 12.h),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2.w,
            crossAxisSpacing: 2.w,
          ),
          itemCount: tab.images.length + (tab.isLoadingMore ? 3 : 0),
          itemBuilder: (context, index) {
            // The trailing row is the load more spinner, centred across it.
            if (index >= tab.images.length) {
              return index == tab.images.length
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }

            return GalleryTile(
              image: tab.images[index],
              heroTag: '${source.name}-${tab.images[index].uploadId}',
              onTap: () => GalleryViewerScreen.open(
                context,
                images: tab.images,
                initialIndex: index,
                heroPrefix: source.name,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Empty and error states - scrollable so pull to refresh still works.
class _GalleryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final String actionLabel;
  final VoidCallback onAction;

  const _GalleryMessage({
    required this.icon,
    required this.title,
    required this.hint,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onAction(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              height: 22.w,
              width: 22.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26.sp, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (hint.isNotEmpty) ...[
            SizedBox(height: 0.8.h),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 1.5.h),
          Center(
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}
