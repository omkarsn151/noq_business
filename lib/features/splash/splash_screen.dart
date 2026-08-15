import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/enums/business_status.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';
import 'package:noq_business/core/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final accessToken = await SecureStorageService().getAccessToken();
    final fullName = await SecureStorageService().getFullName();
    final businessStatus = await SecureStorageService().getBusinessStatus();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (accessToken == null || accessToken.isEmpty) {
      context.go('/login');
      return;
    }

    if (fullName == null) {
      context.go('/register');
      return;
    }

    if (businessStatus == null) {
      context.go('/business-setup');
      return;
    }

    switch (businessStatus) {
      case BusinessStatus.businessSetup:
        context.go('/operation-setup');
      case BusinessStatus.approved:
        context.go('/dashboard');
      case BusinessStatus.underReview:
      case BusinessStatus.rejected:
      case BusinessStatus.suspended:
        context.go('/review-status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(AppAssets.appLogo)));
  }
}
