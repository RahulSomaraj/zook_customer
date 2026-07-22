import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/zook_text_field.dart';
import '../../domain/entities/address.dart';
import '../cubit/address_cubit.dart';

/// Bottom-sheet form to create a new delivery address via the API.
class AddAddressSheet extends StatefulWidget {
  final AddressCubit cubit;
  const AddAddressSheet({super.key, required this.cubit});

  /// Opens the sheet. Resolves to `true` when an address was saved.
  static Future<bool?> show(BuildContext context, AddressCubit cubit) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddAddressSheet(cubit: cubit),
    );
  }

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _postalCode = TextEditingController();
  final _landmark = TextEditingController();

  String _label = 'Home';
  bool _isDefault = false;
  String? _error;

  /// Smaller, subdued placeholder style for the form fields.
  static const TextStyle _hintStyle =
      TextStyle(fontSize: 12, color: AppColors.light);

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _phone,
      _line1,
      _line2,
      _city,
      _state,
      _country,
      _postalCode,
      _landmark,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_fullName.text.trim().isEmpty) return 'Full name is required.';
    if (_phone.text.trim().isEmpty) return 'Phone number is required.';
    if (_line1.text.trim().isEmpty) return 'Address line 1 is required.';
    if (_city.text.trim().isEmpty) return 'City is required.';
    return null;
  }

  Future<void> _submit() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() => _error = null);

    final address = Address(
      fullName: _fullName.text.trim(),
      phone: AppConstants.toE164(_phone.text),
      label: _label,
      line1: _line1.text.trim(),
      line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim().isEmpty ? _city.text.trim() : _state.text.trim(),
      country: _country.text.trim().isEmpty ? 'UAE' : _country.text.trim(),
      postalCode:
          _postalCode.text.trim().isEmpty ? null : _postalCode.text.trim(),
      landmark: _landmark.text.trim().isEmpty ? null : _landmark.text.trim(),
      isDefault: _isDefault,
    );

    final ok = await widget.cubit.add(address);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error =
          widget.cubit.state.errorMessage ?? 'Could not save the address.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return BlocBuilder<AddressCubit, AddressState>(
            bloc: widget.cubit,
            builder: (context, state) {
              final submitting = state.status == AddressStatus.submitting;
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Text('Add delivery address',
                            style: AppTextStyles.title.copyWith(fontSize: 17)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text('✕',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.light)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        _LabelPicker(
                          selected: _label,
                          onSelected: (l) => setState(() => _label = l),
                        ),
                        const SizedBox(height: 14),
                        ZookTextField(
                            label: 'Full name',
                            hint: 'Enter full name',
                            hintStyle: _hintStyle,
                            controller: _fullName),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PHONE', style: AppTextStyles.label),
                            const SizedBox(height: 6),
                            PhoneInputField(controller: _phone),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ZookTextField(
                            label: 'Address line 1',
                            hint: 'House / villa / building, street',
                            hintStyle: _hintStyle,
                            controller: _line1),
                        const SizedBox(height: 12),
                        ZookTextField(
                            label: 'Address line 2 (optional)',
                            hint: 'Apartment, area',
                            hintStyle: _hintStyle,
                            controller: _line2),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ZookTextField(
                                  label: 'City',
                                  hint: 'Enter city',
                                  hintStyle: _hintStyle,
                                  controller: _city),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ZookTextField(
                                  label: 'State / Emirate',
                                  hint: 'Enter state',
                                  hintStyle: _hintStyle,
                                  controller: _state),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ZookTextField(
                                  label: 'Country',
                                  hint: 'Enter country',
                                  hintStyle: _hintStyle,
                                  controller: _country),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ZookTextField(
                                  label: 'Postal code',
                                  hint: 'Enter postal code',
                                  hintStyle: _hintStyle,
                                  controller: _postalCode,
                                  keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ZookTextField(
                            label: 'Landmark (optional)',
                            hint: 'Nearby landmark',
                            hintStyle: _hintStyle,
                            controller: _landmark),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isDefault = !_isDefault),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Switch(
                                value: _isDefault,
                                activeColor: AppColors.primary,
                                onChanged: (v) =>
                                    setState(() => _isDefault = v),
                              ),
                              const SizedBox(width: 4),
                              Text('Set as default address',
                                  style: AppTextStyles.body
                                      .copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 12, color: AppColors.primary)),
                        ],
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Save address',
                          isLoading: submitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LabelPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _LabelPicker({required this.selected, required this.onSelected});

  static const _labels = ['Home', 'Work', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final l in _labels) ...[
          GestureDetector(
            onTap: () => onSelected(l),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected == l
                    ? AppColors.primary
                    : AppColors.surface,
                border: Border.all(
                    color: selected == l
                        ? AppColors.primary
                        : AppColors.border),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                l,
                style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        selected == l ? AppColors.white : AppColors.charcoal),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
