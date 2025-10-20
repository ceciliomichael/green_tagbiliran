import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/schedule.dart';
import '../../services/schedules_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/ui/schedule_card.dart';
import '../../widgets/ui/schedule_empty_state.dart';
import '../../widgets/ui/schedule_delete_dialog.dart';
import '../../widgets/ui/schedule_form_dialog.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  final SchedulesService _schedulesService = SchedulesService();
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  bool _isSeeding = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _currentUserId = user?.id;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _schedulesService.getAllSchedules();
      if (result.success && result.schedules != null) {
        setState(() {
          _schedules = result.schedules!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _schedules = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading schedules: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _seedDefaultSchedules() async {
    if (_currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSeeding = true;
    });

    try {
      final result = await _schedulesService.seedDefaultSchedules(
        adminId: _currentUserId!,
      );

      setState(() {
        _isSeeding = false;
      });

      if (result.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Default schedules seeded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadSchedules();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to seed default schedules'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSeeding = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seeding schedules: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddScheduleDialog() {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ScheduleFormDialog(
        currentUserId: _currentUserId!,
        onSubmit: ({
          required String barangay,
          required String day,
          required String time,
          required String userId,
        }) async {
          final result = await _schedulesService.createSchedule(
            barangay: barangay,
            day: day,
            time: time,
            createdBy: userId,
          );
          _loadSchedules();
          return result;
        },
      ),
    );
  }

  void _showEditScheduleDialog(Schedule schedule) {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ScheduleFormDialog(
        schedule: schedule,
        currentUserId: _currentUserId!,
        onSubmit: ({
          required String barangay,
          required String day,
          required String time,
          required String userId,
        }) async {
          final result = await _schedulesService.updateSchedule(
            scheduleId: schedule.id,
            barangay: barangay,
            day: day,
            time: time,
            userId: userId,
            isActive: schedule.isActive,
          );
          _loadSchedules();
          return result;
        },
      ),
    );
  }

  Future<void> _handleDeleteSchedule(Schedule schedule) async {
    final confirmed = await ScheduleDeleteDialog.show(context, schedule);
    if (confirmed != true || _currentUserId == null) return;

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await _schedulesService.deleteSchedule(
        scheduleId: schedule.id,
        userId: _currentUserId!,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result.success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Schedule deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadSchedules();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to delete schedule'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting schedule: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDismissSchedule(Schedule schedule) async {
    if (_currentUserId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _schedulesService.deleteSchedule(
        scheduleId: schedule.id,
        userId: _currentUserId!,
      );

      if (!mounted) return;
      if (result.success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Schedule deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadSchedules();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to delete schedule'),
            backgroundColor: AppColors.error,
          ),
        );
        _loadSchedules();
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting schedule: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
      _loadSchedules();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
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
                  'Schedule Management',
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
            'Manage garbage collection schedules for all barangays',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAddScheduleButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showAddScheduleDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 12),
            Text(
              'Add New Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_schedules.isEmpty) {
      return ScheduleEmptyState(
        isSeeding: _isSeeding,
        onSeedDefault: _seedDefaultSchedules,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collection Schedules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_schedules.length} schedules',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              final schedule = _schedules[index];
              return Dismissible(
                key: Key(schedule.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await ScheduleDeleteDialog.show(context, schedule);
                },
                onDismissed: (direction) => _handleDismissSchedule(schedule),
                child: ScheduleCard(
                  schedule: schedule,
                  onEdit: () => _showEditScheduleDialog(schedule),
                  onDelete: () => _handleDeleteSchedule(schedule),
                ),
              );
            },
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildAddScheduleButton(),
              _buildSchedulesList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

