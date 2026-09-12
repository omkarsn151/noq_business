import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/enums/business_status.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_bloc.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_event.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_state.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_bloc.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_event.dart';
import 'package:noq_business/features/auth/verify_otp/bloc/verify_otp_state.dart';
import 'package:noq_business/core/common/otp_field.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class OtpVerificationScren extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScren({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScren> createState() => _OtpVerificationScrenState();
}

class _OtpVerificationScrenState extends State<OtpVerificationScren> {
  static const _resendDuration = Duration(minutes: 5);

  String _code = '';
  Timer? _timer;
  Duration _remaining = _resendDuration;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _remaining = _resendDuration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  String get _formattedRemaining {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onResendPressed() {
    if (_remaining > Duration.zero) return;
    context.read<RequestOtpBloc>().add(
      RequestOtpSubmitted(phone: widget.phoneNumber),
    );
  }

  void _onVerifyPressed() {
    if (_code.length != 6) return;
    context.read<VerifyOtpBloc>().add(
      VerifyOtpSubmitted(phone: widget.phoneNumber, code: _code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<VerifyOtpBloc, VerifyOtpState>(
            listener: (context, state) {
              if (state is VerifyOtpSuccess) {
                if (state.fullName == null) {
                  context.go('/register');
                } else if (state.businessStatus == null) {
                  context.go('/business-setup');
                } else {
                  switch (state.businessStatus!) {
                    case BusinessStatus.businessSetup:
                      context.go('/operation-setup');
                    case BusinessStatus.approved:
                      context.go('/dashboard');
                    case BusinessStatus.underReview:
                    case BusinessStatus.rejected:
                      context.go('/review-status');
                    case BusinessStatus.suspended:
                      AppSnackbar.error(
                        context,
                        'Your business account has been suspended.',
                      );
                  }
                }
              } else if (state is VerifyOtpFailure) {
                AppSnackbar.error(context, state.message);
              }
            },
          ),
          BlocListener<RequestOtpBloc, RequestOtpState>(
            listener: (context, state) {
              if (state is RequestOtpSuccess) {
                _startResendTimer();
                AppSnackbar.success(context, 'OTP resent successfully');
              } else if (state is RequestOtpFailure) {
                AppSnackbar.error(context, state.message);
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 1.5.h),

                Image.asset(AppAssets.appLogo),

                SizedBox(height: 2.5.h),

                Text(
                  'OTP Verification',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: AppColors.primary),
                ),

                SizedBox(height: 1.5.h),

                Text(
                  '6 Digit OTP has been sent to your mobile number ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 3.h),

                OtpField(
                  length: 6,
                  onChanged: (code) => setState(() => _code = code),
                ),

                SizedBox(height: 2.5.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formattedRemaining,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    BlocBuilder<RequestOtpBloc, RequestOtpState>(
                      builder: (context, state) {
                        final isRequesting = state is RequestOtpLoading;
                        final canResend =
                            _remaining == Duration.zero && !isRequesting;
                        final color = canResend
                            ? null
                            : Theme.of(context).disabledColor;
                        return TextButton(
                          onPressed: canResend ? _onResendPressed : null,
                          child: Text(
                            'Resend OTP',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  color: color,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 1.5.h),

                BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
                  builder: (context, state) {
                    final isLoading = state is VerifyOtpLoading;
                    return AppButton(
                      label: isLoading ? 'Verifying...' : 'Verify OTP',
                      isLoading: isLoading,
                      onPressed: (isLoading || _code.length != 6)
                          ? null
                          : _onVerifyPressed,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
