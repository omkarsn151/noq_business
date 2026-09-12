import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/otp_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';

/// Takes the six-digit check-in code the customer shows on their phone.
///
/// Only online bookings need one - a walk-in is started without it. Returns
/// the code, or null when the sheet is dismissed.
class VerificationCodeBottomSheet {
  VerificationCodeBottomSheet._();

  static const int codeLength = 6;

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => const _VerificationCodeBody(),
    );
  }
}

class _VerificationCodeBody extends StatefulWidget {
  const _VerificationCodeBody();

  @override
  State<_VerificationCodeBody> createState() => _VerificationCodeBodyState();
}

class _VerificationCodeBodyState extends State<_VerificationCodeBody> {
  String _code = '';

  bool get _isComplete =>
      _code.length == VerificationCodeBottomSheet.codeLength;

  /// [code] is passed straight through from `onCompleted`, whose callback runs
  /// before the `setState` from `onChanged` has landed.
  void _submit([String? code]) {
    final value = code ?? _code;
    if (value.length != VerificationCodeBottomSheet.codeLength) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.26.w,
                  height: 0.47.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(0.51.w),
                  ),
                ),
              ),
              SizedBox(height: 1.9.h),
              Text('Verify Customer', style: textTheme.titleMedium),
              SizedBox(height: 0.5.h),
              Text(
                'Enter the 6-digit code shown in the customer\'s app to start '
                'this booking.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 3.h),
              OtpField(
                length: VerificationCodeBottomSheet.codeLength,
                autofocus: true,
                onChanged: (value) => setState(() => _code = value),
                onCompleted: _submit,
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Start Service',
                  onPressed: _isComplete ? () => _submit() : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
