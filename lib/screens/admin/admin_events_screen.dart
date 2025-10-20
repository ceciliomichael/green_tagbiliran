import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../services/announcements_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/announcement_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/feature/create_announcement_dialog.dart';
import '../../widgets/feature/edit_announcement_dialog.dart';
import '../../widgets/ui/announcement_empty_state.dart';
import '../../widgets/ui/announcement_error_state.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final AnnouncementsService _announcementsService = AnnouncementsService();
  final AuthService _authService = AuthService();
  
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.getAnnouncementsByAdmin(currentUser.id);
      
      if (!mounted) return;
      
      if (result.success && result.announcements != null) {
        setState(() {
          _announcements = result.announcements!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'Failed to load announcements';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading announcements: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showCreateAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAnnouncementDialog(
        onSuccess: _loadAnnouncements,
      ),
    );
  }

  void _showEditAnnouncementDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => EditAnnouncementDialog(
        announcement: announcement,
        onSuccess: _loadAnnouncements,
      ),
    );
  }

  void _showDeleteConfirmationDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Announcement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
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
            onPressed: () {
              Navigator.pop(context);
              _deleteAnnouncement(announcement);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement(Announcement announcement) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.deleteAnnouncement(
        announcementId: announcement.id,
        userId: currentUser.id,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Announcement deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAnnouncements();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to delete announcement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCreateAnnouncementButton(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildAnnouncementsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                onTap: () => Navigator.pop(context, true),
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
                  'Announcements & Events',
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
            'Create and manage community announcements and events',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAnnouncementButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showCreateAnnouncementDialog,
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
              'Create New Announcement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: LoadingIndicator(),
        ),
      );
    }

    if (_error != null) {
      return AnnouncementErrorState(
        errorMessage: _error!,
        onRetry: _loadAnnouncements,
      );
    }

    if (_announcements.isEmpty) {
      return const AnnouncementEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Your Announcements (${_announcements.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_announcements.map((announcement) => AnnouncementCard(
            announcement: announcement,
            isAdmin: true,
            onEdit: () => _showEditAnnouncementDialog(announcement),
            onDelete: () => _showDeleteConfirmationDialog(announcement),
          )).toList()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

