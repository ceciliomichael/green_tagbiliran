import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';

class EditPhoneDialog extends StatefulWidget {
  final String currentPhone;
  final Function(String phone) onSave;

  const EditPhoneDialog({
    super.key,
    required this.currentPhone,
    required this.onSave,
  });

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Extract the 10 digits from current phone if it starts with +63
    String initialValue = widget.currentPhone;
    if (initialValue.startsWith('+63')) {
      initialValue = initialValue.substring(3).replaceAll(RegExp(r'[^\d]'), '');
    } else if (initialValue.startsWith('63')) {
      initialValue = initialValue.substring(2).replaceAll(RegExp(r'[^\d]'), '');
    } else if (initialValue.startsWith('09')) {
      initialValue = initialValue.substring(1).replaceAll(RegExp(r'[^\d]'), '');
    } else {
      initialValue = initialValue.replaceAll(RegExp(r'[^\d]'), '');
    }

    _phoneController = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepend +63 to the entered digits
        final phoneNumber = '+63${_phoneController.text.trim()}';
        await widget.onSave(phoneNumber);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Error handling is done in the parent widget
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Must be exactly 10 digits
    if (digitsOnly.length != 10) {
      return 'Please enter exactly 10 digits';
    }

    // Must start with 9 (Philippine mobile format)
    if (!digitsOnly.startsWith('9')) {
      return 'Philippine mobile numbers must start with 9';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Edit Phone Number',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: '9175550101',
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.shadowDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                prefixIcon: Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: const Text(
                    '+63',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                counterText: '',
              ),
              validator: _validatePhoneNumber,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
