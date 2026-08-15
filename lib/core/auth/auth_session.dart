import 'package:flutter/foundation.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';

class AuthSession {
  AuthSession._();

  static VoidCallback? _onLoggedOut;

  static void registerLogoutHandler(VoidCallback handler) {
    _onLoggedOut = handler;
  }

  static Future<void> logout() async {
    await SecureStorageService().clearTokens();
    _onLoggedOut?.call();
  }
}
