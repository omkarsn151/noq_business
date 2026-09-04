import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/auth/auth_session.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppAlertDialog.show(
      context,
      icon: Icons.logout,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      primaryLabel: 'Logout',
      secondaryLabel: 'Cancel',
    );

    if (!confirmed) return;

    await AuthSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              SizedBox(height: 0.4.h),
              Text(
                'Manage your business, explore promotions and review policies.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 2.5.h),
              _SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Promotions',
                    subtitle: 'Create and manage offers',
                    onTap: () => context.push('/promotions'),
                  ),
                  SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: 'Business Profile',
                    subtitle: 'Edit business information',
                    onTap: () => context.push('/business-profile'),
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'T&C',
                    subtitle: 'Read terms and conditions',
                    onTap: () => context.push('/tnc'),
                  ),
                  SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    onTap: () => context.push('/privacy'),
                  ),
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App information and version',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded card that stacks settings rows with dividers between them.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
