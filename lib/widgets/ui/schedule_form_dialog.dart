import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/schedule.dart';

class ScheduleFormDialog extends StatefulWidget {
  final Schedule? schedule;
  final String currentUserId;
  final Future<dynamic> Function({
    required String barangay,
    required String day,
    required String time,
    required String userId,
  }) onSubmit;

  const ScheduleFormDialog({
    super.key,
    this.schedule,
    required this.currentUserId,
    required this.onSubmit,
  });

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  late final TextEditingController _barangayController;
  late final GlobalKey<FormState> _formKey;
  late String _selectedDay;
  late String _selectedTime;
  late bool _isActive;

  static const List<String> _dayOptions = [
    'Monday & Friday',
    'Tuesday & Saturday',
    'Monday, Wednesday & Friday',
    'Daily',
  ];

  static const List<String> _timeOptions = [
    '6:00 AM - 8:00 AM',
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
    '6:00 PM - 10:00 PM',
    '6:00 AM - 10:00 AM',
  ];

  @override
  void initState() {
    super.initState();
    _barangayController = TextEditingController(text: widget.schedule?.barangay ?? '');
    _formKey = GlobalKey<FormState>();
    _selectedDay = widget.schedule?.day ?? 'Monday & Friday';
    _selectedTime = widget.schedule?.time ?? '6:00 AM - 8:00 AM';
    _isActive = widget.schedule?.isActive ?? true;
  }

  @override
  void dispose() {
    _barangayController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.schedule != null;

  List<String> get _availableTimeOptions {
    final options = List<String>.from(_timeOptions);
    if (_isEditMode && !options.contains(_selectedTime)) {
      options.insert(0, _selectedTime);
    }
    return options;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await widget.onSubmit(
        barangay: _barangayController.text,
        day: _selectedDay,
        time: _selectedTime,
        userId: widget.currentUserId,
      );

      if (!mounted) return;
      navigator.pop(); // Close loading dialog
      navigator.pop(); // Close form dialog

      if (result.success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Schedule ${_isEditMode ? 'updated' : 'added'} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to ${_isEditMode ? 'update' : 'add'} schedule'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop(); // Close loading dialog
      navigator.pop(); // Close form dialog
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error ${_isEditMode ? 'updating' : 'adding'} schedule: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        _isEditMode ? 'Edit Schedule' : 'Add Schedule',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _barangayController,
                decoration: InputDecoration(
                  labelText: 'Barangay Name',
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
                    return 'Please enter barangay name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Collection Days',
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
                items: _dayOptions.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDay = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedTime,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Collection Time',
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
                items: _availableTimeOptions.map((String time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTime = newValue;
                    });
                  }
                },
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Schedule is active and visible to users'),
                  value: _isActive,
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeTrackColor: AppColors.primaryGreen,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(_isEditMode ? 'Update Schedule' : 'Add Schedule'),
        ),
      ],
    );
  }
}

