import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/home_data.dart';
import '../../constants/routes.dart';
import '../../services/auth_service.dart';
import '../../services/notifications_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLocationTap;

  const HomeScreen({super.key, this.onLocationTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _notificationsService = NotificationsService();

  String get _userBarangay {
    return _authService.currentUser?.barangay ?? 'Unknown Barangay';
  }

  String get _userName {
    return _authService.currentUser?.fullName ?? 'User';
  }

  ScheduleItem? get _nextSchedule {
    // Find the schedule for the user's barangay
    final userBarangay = _userBarangay;
    try {
      return HomeConstants.garbageCollectionSchedule.firstWhere(
        (schedule) => schedule.barangay.toLowerCase().contains(
          userBarangay.toLowerCase(),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  String _getNextCollectionDay() {
    final schedule = _nextSchedule;
    if (schedule == null) return 'No schedule available';

    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday

    // Parse collection days
    final dayString = schedule.day.toLowerCase();
    List<int> collectionDays = [];

    if (dayString.contains('monday')) collectionDays.add(1);
    if (dayString.contains('tuesday')) collectionDays.add(2);
    if (dayString.contains('wednesday')) collectionDays.add(3);
    if (dayString.contains('thursday')) collectionDays.add(4);
    if (dayString.contains('friday')) collectionDays.add(5);
    if (dayString.contains('saturday')) collectionDays.add(6);
    if (dayString.contains('sunday')) collectionDays.add(7);

    if (collectionDays.isEmpty) return 'No schedule available';

    // Find next collection day
    int? nextDay;
    int daysUntil = 8; // Max days to check

    for (int day in collectionDays) {
      int diff = day - currentDay;
      if (diff <= 0) diff += 7; // Next week if today or past

      if (diff < daysUntil) {
        daysUntil = diff;
        nextDay = day;
      }
    }

    if (nextDay == null) return 'No schedule available';

    // Format the result
    final dayNames = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (daysUntil == 1) {
      return 'Tomorrow (${dayNames[nextDay]})';
    } else if (daysUntil < 7) {
      return '${dayNames[nextDay]} ($daysUntil days)';
    } else {
      return 'Next ${dayNames[nextDay]}';
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
          // Top row with location and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location display
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagbilaran City, Bohol',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Waste Management Hub',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification icon with badge
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
                child: StreamBuilder<int>(
                  stream: _notificationsService.unreadCountStream,
                  initialData: _notificationsService.unreadCount,
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;

                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // User Barangay Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_userName',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Barangay $_userBarangay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Next Collection Schedule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _nextSchedule?.time.contains('AM') == true
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Collection',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getNextCollectionDay(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_nextSchedule != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          _nextSchedule!.time,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.schedule);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 12,
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

  Widget _buildFeatureCard(FeatureCard feature) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // MASSIVE primary shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.4),
            offset: const Offset(0, 16),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          // STRONG secondary shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 3,
          ),
          // BOLD edge definition shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 14,
            spreadRadius: 2,
          ),
          // SHARP definition shadow
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle feature tap
            if (feature.title == 'Report Issue') {
              Navigator.pushNamed(context, AppRoutes.reportIssue);
            } else if (feature.title == 'Schedule') {
              Navigator.pushNamed(context, AppRoutes.schedule);
            } else if (feature.title == 'Events & Reminders') {
              Navigator.pushNamed(context, AppRoutes.events);
            } else if (feature.title == 'Location') {
              // Switch to track tab in bottom navigation
              widget.onLocationTap?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.asset(
                    feature.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Green header
              _buildHeader(),

              const SizedBox(height: 24),

              // Home title and complaint link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.reportIssue);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Click & Complaint',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Feature cards grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: HomeConstants.featureCards.length,
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(HomeConstants.featureCards[index]);
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
