import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../../core/widgets/zook_alert.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!AppConstants.isValidMobile(_phoneController.text)) {
      setState(() => _phoneError = AppStrings.invalidPhone);
      return;
    }
    setState(() => _phoneError = null);
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
          } else if (state.status == AuthStatus.authenticated) {
            // Google sign-in completes here (no OTP page in between).
            context.go(AppRoute.home.path);
          } else if (state.status == AuthStatus.failure) {
            showZookAlert(context,
                type: ZookAlertType.error,
                title: 'Sign-in failed',
                message: state.errorMessage ?? 'Please try again.');
          }
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return Column(
            children: [
              // Dark hero
              SizedBox(
                height: 200,
                child: ClipRect(
                  child: Stack(
                  children: [
                    Container(color: AppColors.black),
                    // Decorative glows (match the splash / mockup hero)
                    Positioned(
                      top: -60,
                      right: -60,
                      child: _HeroGlow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        size: 200,
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: _HeroGlow(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        size: 160,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppStrings.appName.toUpperCase(),
                              style: AppTextStyles.brand(size: 42)),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.tagline,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppStrings.welcomeBack} 👋',
                          style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(AppStrings.signInToAccount,
                          style: AppTextStyles.caption),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: AppStrings.continueWithOtp,
                        isLoading: loading,
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.white, size: 20),
                        onPressed: _continue,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(AppStrings.orContinueWith,
                                style: AppTextStyles.caption),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SocialButton(
                        label: AppStrings.continueWithApple,
                        icon: const Icon(Icons.apple,
                            size: 20, color: AppColors.black),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 10),
                      SocialButton(
                        label: AppStrings.continueWithGoogle,
                        icon: const _GoogleGlyph(),
                        onPressed: loading
                            ? () {}
                            : () => context
                                .read<AuthBloc>()
                                .add(const GoogleSignInRequested()),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoute.signup.path),
                          child: Text.rich(
                            TextSpan(
                              text: '${AppStrings.noAccount} ',
                              style: AppTextStyles.caption,
                              children: [
                                TextSpan(
                                  text: AppStrings.signUpFree,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Soft radial glow used in the dark login hero.
class _HeroGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _HeroGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

/// Official multicolour Google "G" logo, rendered from vector for the
/// "Continue with Google" button.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_kGoogleSvg, width: size, height: size);
  }
}

const String _kGoogleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
<path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
<path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
<path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
</svg>
''';
