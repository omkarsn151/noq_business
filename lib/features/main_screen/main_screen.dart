import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            icon: Icon(Icons.space_dashboard_outlined, color: AppColors.border),
            selectedIcon: Icon(
              Icons.space_dashboard_rounded,
              color: AppColors.primary,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: AppColors.border),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, color: AppColors.border),
            selectedIcon: Icon(
              Icons.shopping_cart_rounded,
              color: AppColors.primary,
            ),
            label: 'Walk-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, color: AppColors.border),
            selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.border),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
