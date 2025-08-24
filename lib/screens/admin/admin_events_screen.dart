import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Event Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Create and manage community events and reminders',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEventButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showCreateEventDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 12),
            Text(
              'Create New Event',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
                 return StatefulBuilder(
           builder: (context, setDialogState) {
             return AlertDialog(
               backgroundColor: AppColors.pureWhite,
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(20),
               ),
               contentPadding: EdgeInsets.zero,
               insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                             content: Container(
                 width: double.maxFinite,
                 constraints: const BoxConstraints(maxWidth: 500),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const SizedBox(height: 24),
                     const Text(
                       'Create New Event',
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
                                 labelText: 'Event Title',
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
                                   return 'Please enter event title';
                                 }
                                 return null;
                               },
                             ),
                             const SizedBox(height: 16),
                             TextFormField(
                               controller: descriptionController,
                               maxLines: 3,
                               decoration: InputDecoration(
                                 labelText: 'Event Description',
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
                                   return 'Please enter event description';
                                 }
                                 return null;
                               },
                             ),
                             const SizedBox(height: 16),
                             ListTile(
                               leading: const Icon(
                                 Icons.calendar_today,
                                 color: AppColors.primaryGreen,
                               ),
                               title: Text(
                                 '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                 style: const TextStyle(fontWeight: FontWeight.w600),
                               ),
                               subtitle: const Text('Event Date'),
                               onTap: () async {
                                 final date = await showDatePicker(
                                   context: context,
                                   initialDate: selectedDate,
                                   firstDate: DateTime.now(),
                                   lastDate: DateTime.now().add(
                                     const Duration(days: 365),
                                   ),
                                 );
                                 if (date != null) {
                                   setDialogState(() {
                                     selectedDate = date;
                                   });
                                 }
                               },
                             ),
                             ListTile(
                               leading: const Icon(
                                 Icons.access_time,
                                 color: AppColors.primaryGreen,
                               ),
                               title: Text(
                                 selectedTime.format(context),
                                 style: const TextStyle(fontWeight: FontWeight.w600),
                               ),
                               subtitle: const Text('Event Time'),
                               onTap: () async {
                                 final time = await showTimePicker(
                                   context: context,
                                   initialTime: selectedTime,
                                 );
                                 if (time != null) {
                                   setDialogState(() {
                                     selectedTime = time;
                                   });
                                 }
                               },
                             ),
                             const SizedBox(height: 24),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                                 TextButton(
                                   onPressed: () => Navigator.pop(context),
                                   child: const Text(
                                     'Cancel',
                                     style: TextStyle(color: AppColors.textSecondary),
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 ElevatedButton(
                                   onPressed: () {
                                     if (formKey.currentState!.validate()) {
                                       // TODO: Implement event creation logic
                                       Navigator.pop(context);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(
                                           content: Text('Event created successfully!'),
                                           backgroundColor: AppColors.success,
                                         ),
                                       );
                                     }
                                   },
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: AppColors.primaryGreen,
                                     foregroundColor: Colors.white,
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(12),
                                     ),
                                   ),
                                   child: const Text('Create Event'),
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
           },
         );
       },
     );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.3),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.event_outlined,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Events Created',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create community events and reminders that will be visible to all users in the app. Events help keep the community informed about important activities.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
                         child: Row(
               children: [
                 Icon(
                   Icons.info_outline,
                   size: 20,
                   color: AppColors.primaryGreen,
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     'Click "Create New Event" to get started',
                     style: const TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                       color: AppColors.primaryGreen,
                     ),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
          _buildHeader(),
          _buildCreateEventButton(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [_buildEmptyState(), const SizedBox(height: 40)],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
