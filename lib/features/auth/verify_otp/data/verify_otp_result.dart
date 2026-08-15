import 'package:noq_business/core/enums/business_status.dart';

class VerifyOtpResult {
  final String? fullName;
  final BusinessStatus? businessStatus;
  final String accessToken;
  final String refreshToken;

  const VerifyOtpResult({
    this.fullName,
    this.businessStatus,
    required this.accessToken,
    required this.refreshToken,
  });

  factory VerifyOtpResult.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'] as Map<String, dynamic>?;
    return VerifyOtpResult(
      fullName: userInfo?['full_name'] as String?,
      businessStatus: BusinessStatus.fromString(
        json['business_status'] as String?,
      ),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
