import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_pill_tab_bar.dart';
import 'package:noq_business/features/gallery/bloc/gallery_bloc.dart';
import 'package:noq_business/features/gallery/bloc/gallery_event.dart';
import 'package:noq_business/features/gallery/bloc/gallery_state.dart';
import 'package:noq_business/features/gallery/data/gallery_source.dart';
import 'package:noq_business/features/gallery/presentation/widgets/gallery_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: GallerySource.values.length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_onTabChanged);
    context.read<GalleryBloc>().add(
      const GalleryRequested(source: GallerySource.all, refresh: true),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Loads a tab the first time it is opened.
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<GalleryBloc>().add(
      GalleryRequested(source: GallerySource.values[_tabController.index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        final total = state.totalPhotos;
        return Scaffold(
          appBar: AppAppBar(
            title: 'Gallery',
            subtitle: total > 0
                ? '$total ${total == 1 ? 'photo' : 'photos'}'
                : 'Business Profile',
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPillTabBar(
                  controller: _tabController,
                  labels: [
                    for (final source in GallerySource.values) source.label,
                  ],
                ),
                SizedBox(height: 1.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      for (final source in GallerySource.values)
                        GalleryGrid(
                          source: source,
                          tab: state.tabFor(source),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
