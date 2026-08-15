import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:noq_business/core/auth/auth_session.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseurl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _secureStorageService.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isRetried = error.requestOptions.extra['__retried'] == true;
          final isInvalidToken = error.response?.statusCode == 401 &&
              _extractErrorCode(error.response?.data) == 'AUTH_INVALID_TOKEN';

          if (isInvalidToken && !isRetried) {
            try {
              final newAccessToken = await _refreshAccessToken();
              error.requestOptions.extra['__retried'] = true;
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await AuthSession.logout();
              return handler.next(error);
            }
          }

          if (isInvalidToken && isRetried) {
            await AuthSession.logout();
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  final _secureStorageService = SecureStorageService();
  Future<String>? _refreshFuture;

  String? _extractErrorCode(dynamic data) {
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      return (data['error'] as Map<String, dynamic>)['code']?.toString();
    }
    return null;
  }

  Future<String> _refreshAccessToken() {
    return _refreshFuture ??= _performRefresh().whenComplete(() => _refreshFuture = null);
  }

  Future<String> _performRefresh() async {
    final refreshToken = await _secureStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException('Session expired. Please log in again.');
    }

    final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseurl));
    final response = await refreshDio.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data['data'] as Map<String, dynamic>?;
    final newAccessToken = data?['access_token'] as String?;
    final newRefreshToken = data?['refresh_token'] as String?;
    if (newAccessToken == null) {
      throw const ApiException('Session expired. Please log in again.');
    }

    await _secureStorageService.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken ?? refreshToken,
    );

    return newAccessToken;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
