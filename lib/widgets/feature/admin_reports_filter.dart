import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AdminReportsFilter extends StatelessWidget {
  final String selectedFilter;
  final List<String> filterOptions;
  final Function(String) onFilterChanged;

  const AdminReportsFilter({
    super.key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = option == selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => onFilterChanged(option),
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

