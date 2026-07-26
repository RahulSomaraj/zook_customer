import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/zook_alert.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/otp_input.dart';
import 'otp_page.dart' show kOtpLength, kResendCooldownSeconds;

/// Attach & verify a phone number on the CURRENT signed-in user.
///
/// Shown to social-signup customers (no phone on file) when they reach
/// checkout. Two steps on one page: enter phone → enter the 6-digit code.
/// Pops with `true` once the phone is verified so the caller can continue.
class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  final _phoneController = TextEditingController();
  final _otpController = OtpInputController();
  String? _phoneError;
  String _code = '';
  bool _codeStep = false;
  int _secondsLeft = 0;
  Timer? _timer;
  SmartAuth? _smartAuth;

  @override
  void dispose() {
    _phoneController.dispose();
    _timer?.cancel();
    _smartAuth?.removeUserConsentApiListener();
    super.dispose();
  }

  void _sendCode() {
    if (!AppConstants.isValidMobile(_phoneController.text)) {
      setState(() => _phoneError = 'Enter a valid mobile number');
      return;
    }
    setState(() => _phoneError = null);
    context
        .read<AuthBloc>()
        .add(PhoneAttachOtpRequested(AppConstants.toE164(_phoneController.text)));
  }

  void _verify() {
    if (_code.length < kOtpLength) return;
    final bloc = context.read<AuthBloc>();
    bloc.add(PhoneAttachSubmitted(
      phoneNumber: bloc.state.phoneNumber,
      otp: _code,
    ));
  }

  void _startTimer([int? seconds]) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds ?? kResendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _listenForSms() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      _smartAuth = SmartAuth.instance;
      final res = await _smartAuth!.getSmsWithUserConsentApi();
      final sms = res.data?.code;
      if (sms == null || !mounted) return;
      final match = RegExp('\\d{$kOtpLength}').firstMatch(sms);
      if (match == null) return;
      _otpController.setCode(match.group(0)!);
      _verify();
    } catch (_) {
      // Fall back to manual entry.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: BackButton(
          color: AppColors.mid,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(AppStrings.verifyPhoneTitle, style: AppTextStyles.title.copyWith(fontSize: 18)),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.phoneAttachOtpSent) {
              setState(() => _codeStep = true);
              _startTimer();
              _listenForSms();
            } else if (state.status == AuthStatus.phoneAttached) {
              Navigator.of(context).pop(true);
            } else if (state.status == AuthStatus.failure) {
              if (state.retryAfterSeconds != null) {
                _startTimer(state.retryAfterSeconds);
              }
              showZookAlert(context,
                  type: ZookAlertType.error,
                  title: AppStrings.verificationFailed,
                  message: state.errorMessage ?? AppStrings.pleaseTryAgain);
            }
          },
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _codeStep
                        ? AppStrings.enterCodeTitle
                        : AppStrings.addPhoneTitle,
                    style: AppTextStyles.title.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _codeStep
                        ? AppStrings.sentTo(state.phoneNumber)
                        : AppStrings.phoneNeededForDelivery,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 24),
                  if (!_codeStep) ...[
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
                      label: AppStrings.sendCode,
                      isLoading: loading,
                      onPressed: _sendCode,
                    ),
                  ] else ...[
                    OtpInput(
                      length: kOtpLength,
                      controller: _otpController,
                      onChanged: (v) => _code = v,
                      onCompleted: (v) {
                        _code = v;
                        _verify();
                      },
                    ),
                    if (state.devOtp != null && state.devOtp!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ZookAlert(
                        type: ZookAlertType.info,
                        title: AppStrings.uatDevCode,
                        message: state.devOtp!,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _secondsLeft > 0 ? 'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}' : '',
                          style: AppTextStyles.caption,
                        ),
                        GestureDetector(
                          onTap: _secondsLeft == 0 && !loading ? _sendCode : null,
                          child: Text(
                            AppStrings.resendCode,
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
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: AppStrings.verifyAndContinue,
                      isLoading: loading,
                      onPressed: _verify,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
