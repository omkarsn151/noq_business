import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_colors.dart';

/// Scrollable pill styled tab bar - the selected tab is a filled primary pill,
/// the rest are plain labels.
class AppPillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const AppPillTabBar({
    super.key,
    required this.controller,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.w),
      ),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelColor: AppColors.background,
      unselectedLabelColor: AppColors.textPrimary,
      labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        for (final label in labels)
          Tab(
            height: 4.5.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(label),
            ),
          ),
      ],
    );
  }
}
