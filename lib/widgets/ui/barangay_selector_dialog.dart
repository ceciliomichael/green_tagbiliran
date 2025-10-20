import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BarangaySelectorDialog extends StatelessWidget {
  final List<String> barangays;
  final String? selectedBarangay;

  const BarangaySelectorDialog({
    super.key,
    required this.barangays,
    this.selectedBarangay,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Barangay Assignment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose which barangay this driver will be responsible for:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: barangays.map((barangay) {
                    final isSelected = selectedBarangay == barangay;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(barangay),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  barangay,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const Spacer(),
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

