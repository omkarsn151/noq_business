import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noq_business/core/enums/business_status.dart';

class SecureStorageService {
  SecureStorageService._internal();

  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _fullNameKey = 'full_name';
  static const _businessStatusKey = 'business_status';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveFullName(String? fullName) async {
    if (fullName == null) {
      await _storage.delete(key: _fullNameKey);
    } else {
      await _storage.write(key: _fullNameKey, value: fullName);
    }
  }

  Future<void> saveBusinessStatus(BusinessStatus? businessStatus) async {
    if (businessStatus == null) {
      await _storage.delete(key: _businessStatusKey);
    } else {
      await _storage.write(key: _businessStatusKey, value: businessStatus.value);
    }
  }

  Future<String?> getFullName() => _storage.read(key: _fullNameKey);

  Future<BusinessStatus?> getBusinessStatus() async {
    final value = await _storage.read(key: _businessStatusKey);
    return BusinessStatus.fromString(value);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _fullNameKey);
    await _storage.delete(key: _businessStatusKey);
  }
}
