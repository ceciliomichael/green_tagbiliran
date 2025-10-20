import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';

class ReportFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final int maxLines;
  final String? prefixText;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const ReportFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixText,
    this.prefixIcon,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          filled: true,
          fillColor: AppColors.pureWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

