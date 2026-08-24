import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_bloc.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_event.dart';
import 'package:noq_business/features/auth/request_otp/bloc/request_otp_state.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:noq_business/core/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();

  void _onGetOtpPressed() {
    if (_formKey.currentState?.validate() != true) return;
    final phone = '+91${phoneNumberController.text.trim()}';
    context.read<RequestOtpBloc>().add(RequestOtpSubmitted(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<RequestOtpBloc, RequestOtpState>(
        listener: (context, state) {
          if (state is RequestOtpSuccess) {
            context.push('/otp', extra: state.phone);
          } else if (state is RequestOtpFailure) {
            AppSnackbar.error(context, state.message);
          }
        },
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
                  'Get Started',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: AppColors.primary),
                ),

                SizedBox(height: 1.5.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'Create your account to book services and skip waiting time in prior.',
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 3.h),

                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    hintText: 'Enter mobile number',
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.isEmpty) return 'Mobile number is required';
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                    prefixIcon: SizedBox(
                      width: 15.w,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 3.w),
                          const Text('+91'),
                          SizedBox(width: 3.w),
                          Container(
                            width: 1,
                            height: 2.h,
                            color: AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.5.h),

                BlocBuilder<RequestOtpBloc, RequestOtpState>(
                  builder: (context, state) {
                    final isLoading = state is RequestOtpLoading;
                    return AppButton(
                      label: isLoading ? "Requesting OTP..." : "Get OTP",
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onGetOtpPressed,
                    );
                  },
                ),

                SizedBox(height: 2.5.h),

                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      const TextSpan(text: "By continuing, you agree to our "),
                      TextSpan(
                        text: "Terms & Conditions",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/tnc');
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/privacy');
                          },
                      ),
                    ],
                  ),
                ),

                // RichText(
                //   text: TextSpan(
                //     style: Theme.of(context).textTheme.bodySmall,
                //     children: [
                //       const TextSpan(text: "New to NoQ? "),
                //       TextSpan(
                //         text: "Create Account",
                //         style: Theme.of(context).textTheme.bodySmall!.copyWith(
                //           color: AppColors.primary,
                //           fontWeight: FontWeight.w600,
                //         ),
                //         recognizer: TapGestureRecognizer()
                //           ..onTap = () {
                //             context.push('/register');
                //           },
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
