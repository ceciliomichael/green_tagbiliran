import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AnnouncementFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const AnnouncementFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Announcement Title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter announcement title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Announcement Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter announcement description';
            }
            return null;
          },
        ),
      ],
    );
  }
}

