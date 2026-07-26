import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/zook_alert.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/otp_input.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _code = '';
  int _secondsLeft = 42;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 42);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verify() {
    if (_code.length < 6) return;
    context
        .read<AuthBloc>()
        .add(OtpSubmitted(phoneNumber: widget.phoneNumber, otp: _code));
  }

  void _resend() {
    context.read<AuthBloc>().add(OtpRequested(widget.phoneNumber));
    _startTimer();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go(AppRoute.home.path);
            } else if (state.status == AuthStatus.failure) {
              showZookAlert(context,
                  type: ZookAlertType.error,
                  title: 'Verification failed',
                  message: state.errorMessage ?? 'Please try again.');
            }
          },
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(Icons.arrow_back,
                        size: 22, color: AppColors.mid),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.smartphone,
                        size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.enterOtp, style: AppTextStyles.title.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(AppStrings.otpSentTo, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(
                    widget.phoneNumber,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800, color: AppColors.black),
                  ),
                  const SizedBox(height: 28),
                  OtpInput(
                    length: 6,
                    onChanged: (v) => _code = v,
                    onCompleted: (v) => _code = v,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: AppColors.light),
                          const SizedBox(width: 5),
                          Text(
                            '${AppStrings.resendIn} $_timerLabel',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _secondsLeft == 0 ? _resend : null,
                        child: Text(
                          AppStrings.resendOtp,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13,
                            letterSpacing: 0,
                            color: _secondsLeft == 0
                                ? AppColors.primary
                                : AppColors.light,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: AppStrings.verifyContinue,
                    isLoading: loading,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.white, size: 20),
                    onPressed: _verify,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: '${AppStrings.termsPrefix} ',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        children: [
                          TextSpan(
                              text: AppStrings.terms,
                              style: const TextStyle(color: AppColors.primary)),
                          TextSpan(text: ' ${AppStrings.and} '),
                          TextSpan(
                              text: AppStrings.privacy,
                              style: const TextStyle(color: AppColors.primary)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
