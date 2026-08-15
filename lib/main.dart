import 'package:flutter/material.dart';
import 'package:noq_business/app.dart';
import 'package:noq_business/core/auth/auth_session.dart';
import 'package:noq_business/core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthSession.registerLogoutHandler(() => AppRouter.router.go('/login'));
  runApp(const MyApp());
}