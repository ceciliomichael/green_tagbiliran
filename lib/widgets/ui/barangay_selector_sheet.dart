import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BarangaySelectorSheet extends StatelessWidget {
  final String selectedBarangay;
  final List<String> barangays;
  final Function(String) onBarangaySelected;

  const BarangaySelectorSheet({
    super.key,
    required this.selectedBarangay,
    required this.barangays,
    required this.onBarangaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 20),
          _buildBarangayList(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Select Barangay',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Choose the barangay where the issue is located',
      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    );
  }

  Widget _buildBarangayList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: barangays.length,
        itemBuilder: (context, index) {
          final barangay = barangays[index];
          final isSelected = barangay == selectedBarangay;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              title: Text(
                barangay,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                      size: 24,
                    )
                  : null,
              onTap: () {
                onBarangaySelected(barangay);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}

