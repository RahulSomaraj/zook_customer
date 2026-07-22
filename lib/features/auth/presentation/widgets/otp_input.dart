import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A row of OTP digit boxes. Calls [onCompleted] when all [length] digits
/// are filled, and [onChanged] on every change.
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
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
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final active = _focusNodes[i].hasFocus;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: filled ? AppColors.primaryPale : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (filled || active)
                        ? AppColors.primary
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  showCursor: false,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 24,
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
          ),
        );
      }),
    );
  }
}
