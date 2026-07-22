import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/zook_text_field.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  static final _emailRegExp =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final nameError =
        _nameController.text.trim().isEmpty ? AppStrings.invalidName : null;
    final emailError = _emailRegExp.hasMatch(_emailController.text.trim())
        ? null
        : AppStrings.invalidEmail;
    final phoneError = AppConstants.isValidMobile(_phoneController.text)
        ? null
        : AppStrings.invalidPhone;

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _phoneError = phoneError;
    });

    if (nameError != null || emailError != null || phoneError != null) return;

    context
        .read<AuthBloc>()
        .add(OtpRequested(AppConstants.toE164(_phoneController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.otpSent) {
            context.push(AppRoute.otp.path, extra: state.phoneNumber);
          } else if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Failed')),
            );
          }
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Text('←',
                        style: TextStyle(fontSize: 22, color: AppColors.mid)),
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.createAccount, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(AppStrings.signUpSubtitle,
                      style: AppTextStyles.caption),
                  const SizedBox(height: 24),
                  ZookTextField(
                    label: AppStrings.fullName,
                    hint: AppStrings.fullNameHint,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ZookTextField(
                    label: AppStrings.email,
                    hint: AppStrings.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(AppStrings.mobileNumber.toUpperCase(),
                      style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  PhoneInputField(
                    controller: _phoneController,
                    errorText: _phoneError,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: '${AppStrings.continueText} →',
                    isLoading: loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoute.login.path),
                      child: Text.rich(
                        TextSpan(
                          text: '${AppStrings.haveAccount} ',
                          style: AppTextStyles.caption,
                          children: [
                            TextSpan(
                              text: AppStrings.signIn,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
