import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/home_data.dart';
import '../ui/barangay_selector_bottom_sheet.dart';

class SendNotificationDialog extends StatefulWidget {
  final bool isLoading;
  final Function({
    required String title,
    required String message,
    required String targetType,
    String? targetBarangay,
  }) onSend;

  const SendNotificationDialog({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedTarget = 'All Users';
  String? selectedBarangay;

  final List<String> targetOptions = ['All Users', 'Specific Barangay'];

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _showBarangaySelector(FormFieldState<String> state) {
    // Extract unique barangay names from HomeConstants
    final Set<String> barangaySet = HomeConstants.garbageCollectionSchedule
        .map((schedule) => schedule.barangay)
        .toSet();
    final List<String> barangayOptions = barangaySet.toList()..sort();

    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BarangaySelectorBottomSheet(
          barangayOptions: barangayOptions,
          selectedBarangay: selectedBarangay,
        );
      },
    ).then((newBarangay) {
      if (newBarangay != null) {
        setState(() {
          selectedBarangay = newBarangay;
        });
        state.didChange(newBarangay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Send Notification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Notification Title',
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
                          return 'Please enter notification title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Notification Message',
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
                          return 'Please enter notification message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Send To',
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTarget,
                          isExpanded: true,
                          items: targetOptions.map((String target) {
                            return DropdownMenuItem<String>(
                              value: target,
                              child: Text(target),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedTarget = newValue;
                                if (newValue != 'Specific Barangay') {
                                  selectedBarangay = null;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedTarget == 'Specific Barangay') ...[
                      const SizedBox(height: 16),
                      FormField<String>(
                        validator: (value) {
                          if (selectedTarget == 'Specific Barangay' &&
                              (selectedBarangay == null ||
                                  selectedBarangay!.isEmpty)) {
                            return 'Please select a barangay';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showBarangaySelector(state),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.pureWhite,
                                    border: Border.all(
                                      color: state.hasError
                                          ? Colors.red
                                          : (selectedBarangay == null
                                              ? AppColors.textSecondary
                                                  .withValues(alpha: 0.3)
                                              : AppColors.primaryGreen),
                                      width: selectedBarangay == null ? 1 : 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Select Barangay',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (selectedBarangay != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedBarangay!,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.textSecondary,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    left: 12,
                                  ),
                                  child: Text(
                                    state.errorText!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: widget.isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    await widget.onSend(
                                      title: titleController.text.trim(),
                                      message: messageController.text.trim(),
                                      targetType: selectedTarget,
                                      targetBarangay: selectedBarangay,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send Notification'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

