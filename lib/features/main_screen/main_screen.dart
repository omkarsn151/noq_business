import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        elevation: 2,
        shadowColor: AppColors.border,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).textTheme.labelSmall!.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            );
          }

          return Theme.of(context).textTheme.labelSmall!.copyWith(
            color: AppColors.border,
            fontWeight: FontWeight.w500,
          );
        }),

        destinations: const [
          NavigationDestination(
            icon: _NavIcon(AppAssets.navDashboard),
            selectedIcon: _NavIcon(AppAssets.navDashboardFilled, selected: true),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: _NavIcon(AppAssets.navBookings),
            selectedIcon: _NavIcon(AppAssets.navBookingsFilled, selected: true),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: _NavIcon(AppAssets.navWalkin),
            selectedIcon: _NavIcon(AppAssets.navWalkinFilled, selected: true),
            label: 'Walk-in',
          ),
          NavigationDestination(
            icon: _NavIcon(AppAssets.navInsights),
            selectedIcon: _NavIcon(AppAssets.navInsightsFilled, selected: true),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: _NavIcon(AppAssets.navSettings),
            selectedIcon: _NavIcon(AppAssets.navSettingsFilled, selected: true),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String asset;
  final bool selected;

  const _NavIcon(this.asset, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        selected ? AppColors.primary : AppColors.border,
        BlendMode.srcIn,
      ),
    );
  }
}
