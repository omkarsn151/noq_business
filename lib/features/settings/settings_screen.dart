import 'package:flutter/material.dart';
import 'package:noq_business/core/auth/auth_session.dart';
import 'package:noq_business/core/common/app_alert_dialog.dart';

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
      body: Center(
        child: TextButton(
          onPressed: () => _handleLogout(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
