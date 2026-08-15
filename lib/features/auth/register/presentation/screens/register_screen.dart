import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/services/secure_storage_service.dart';
import 'package:noq_business/core/utils/app_assets.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/auth/register/bloc/register_bloc.dart';
import 'package:noq_business/features/auth/register/bloc/register_event.dart';
import 'package:noq_business/features/auth/register/bloc/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillFullName();
  }

  Future<void> _prefillFullName() async {
    final cachedFullName = await SecureStorageService().getFullName();
    if (!mounted || cachedFullName == null) return;
    setState(() => fullNameController.text = cachedFullName);
  }

  void _onProceedPressed() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<RegisterBloc>().add(
      RegisterSubmitted(fullName: fullNameController.text.trim()),
    );
  }

  Future<void> _onBackPressed(BuildContext context) async {
    await SecureStorageService().clearTokens();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Register',
          subtitle: 'Step 1 of 3',
          onLeadingPressed: () => _onBackPressed(context),
        ),
        body: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              context.go('/business-setup');
            } else if (state is RegisterFailure) {
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
                    'Registration',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 1.5.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.97.w),
                    child: Text(
                      'Enter your details to proceed further and explore services',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Form(
                    key: _formKey,
                    child: AppTextField(
                      controller: fullNameController,
                      hintText: "Enter your Full name",
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: Icon(
                        Icons.person_outline_outlined,
                        color: AppColors.textSecondary,
                      ),
                      validator: (value) {
                        final fullName = value?.trim() ?? '';
                        if (fullName.isEmpty) return 'Full name is required';
                        if (fullName.length < 3) {
                          return 'Enter at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 2.5.h),

                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      final isLoading = state is RegisterLoading;
                      return AppButton(
                        label: isLoading ? 'Saving...' : 'Proceed to Setup',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onProceedPressed,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
