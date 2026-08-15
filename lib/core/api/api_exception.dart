import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final List<String>? details;

  const ApiException(this.message, {this.statusCode, this.code, this.details});

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const ApiException('No internet connection.');
      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
          final errorObj = data['error'] as Map<String, dynamic>;
          final details = (errorObj['details'] as List?)
              ?.whereType<Map>()
              .map((d) => d['issue']?.toString())
              .whereType<String>()
              .toList();
          return ApiException(
            errorObj['message']?.toString() ?? 'Something went wrong. Please try again.',
            statusCode: statusCode,
            code: errorObj['code']?.toString(),
            details: details,
          );
        }

        final serverMessage = data is Map<String, dynamic>
            ? (data['message'] ?? data['error'])?.toString()
            : null;
        return ApiException(
          serverMessage ?? 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
        return const ApiException('Invalid certificate.');
      case DioExceptionType.unknown:
      default:
        return ApiException(error.message ?? 'Unexpected error occurred.');
    }
  }

  @override
  String toString() => message;
}
