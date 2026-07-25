import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Lets a parent programmatically fill the boxes (e.g. from Android's SMS
/// User Consent prompt) without owning the internal controllers.
class OtpInputController {
  _OtpInputState? _state;

  /// Fills the boxes with [code] (digits only, truncated to the box count)
  /// and fires onChanged/onCompleted as if the user typed it.
  void setCode(String code) => _state?._applyCode(code);

  void clear() => _state?._applyCode('');
}

/// A row of OTP digit boxes. Calls [onCompleted] when all [length] digits
/// are filled, and [onChanged] on every change.
///
/// Auto-fill support:
///  - iOS: the boxes carry [AutofillHints.oneTimeCode], so the code from
///    Messages appears on the keyboard; tapping it inserts the full code,
///    which is distributed across the boxes.
///  - Android: pair with the SMS User Consent flow (see OtpPage) which calls
///    [OtpInputController.setCode].
///  - Pasting a full code into any box also distributes it.
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final OtpInputController? controller;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.controller,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
    widget.controller?._state = this;
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _notify() {
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  /// Fills the boxes from a full (or partial) code — used by paste, iOS
  /// keyboard autofill and the Android SMS consent flow.
  void _applyCode(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final nextIndex =
        digits.length >= widget.length ? widget.length - 1 : digits.length;
    _focusNodes[nextIndex].requestFocus();
    if (digits.length >= widget.length) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {});
    _notify();
  }

  void _onChanged(String value, int index) {
    // A multi-character insert means paste or keyboard autofill — spread it.
    if (value.length > 1) {
      _applyCode(value);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final active = _focusNodes[i].hasFocus;
        final highlighted = filled || active;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: filled ? AppColors.primaryPale : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: highlighted ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 0,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                // No maxLength so a pasted/auto-filled full code arrives
                // intact; _onChanged distributes anything longer than 1 char.
                showCursor: false,
                // iOS: surfaces the SMS code on the keyboard (QuickType).
                autofillHints: const [AutofillHints.oneTimeCode],
                style: AppTextStyles.title.copyWith(
                  fontSize: 22,
                  color: filled ? AppColors.primary : AppColors.black,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => _onChanged(v, i),
              ),
            ),
          ),
        );
      }),
    );
  }
}
