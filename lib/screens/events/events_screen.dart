import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../services/announcements_service.dart';
import '../../widgets/common/announcement_card.dart';
import '../../widgets/common/loading_indicator.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final AnnouncementsService _announcementsService = AnnouncementsService();
  
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
      final result = await _announcementsService.getAllAnnouncements();
      
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
      setState(() {
        _error = 'Error loading announcements: ${e.toString()}';
        _isLoading = false;
      });
    }
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
          // Top row with back button and title
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
                  'Events & Reminders',
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
        Row(
          children: [
            Expanded(
              child: const Text(
                'Stay updated with community announcements and events',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: _loadAnnouncements,
              icon: Icon(
                Icons.refresh,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              tooltip: 'Refresh',
            ),
          ],
        ),
        ],
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
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnnouncements,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_announcements.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Announcements (${_announcements.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...(_announcements.map((announcement) => AnnouncementCard(
            announcement: announcement,
            isAdmin: false,
          )).toList()),
          const SizedBox(height: 40),
        ],
      ),
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
              Icons.event_note_outlined,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Announcements Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Announcements and events from your barangay admin will appear here. Stay tuned for important community updates!',
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Check back soon for updates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildAnnouncementsList(),
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
