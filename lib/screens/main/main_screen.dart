import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../home/home_screen.dart';
import '../track/track_screen.dart';
import '../recycle/recycle_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/notifications_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_overlay_service.dart';
import '../../widgets/ui/floating_ai_button.dart';
import '../../widgets/ui/ai_chat_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final NotificationsService _notificationsService = NotificationsService();
  final AuthService _authService = AuthService();
  final NotificationOverlayService _overlayService =
      NotificationOverlayService();
  bool _showAiChat = false;

  @override
  void initState() {
    super.initState();
    // Set context for overlay service after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayService.setContext(context);
    });
    _startNotificationPolling();
  }

  @override
  void dispose() {
    _notificationsService.stopPolling();
    _overlayService.dispose();
    super.dispose();
  }

  void _startNotificationPolling() {
    if (_authService.currentUser != null) {
      _notificationsService.startPolling(_authService.currentUser!.id);
    }
  }

  List<Widget> get _screens => [
    HomeScreen(
      onLocationTap: () {
        setState(() {
          _currentIndex = 1; // Switch to track tab
        });
      },
    ),
    const TrackScreen(),
    const RecycleScreen(),
    const ProfileScreen(),
  ];

  void _toggleAiChat() {
    setState(() {
      _showAiChat = !_showAiChat;
    });
  }

  void _closeAiChat() {
    setState(() {
      _showAiChat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          _screens[_currentIndex],

          // Floating AI button
          if (!_showAiChat) FloatingAiButton(onTap: _toggleAiChat),

          // AI Chat overlay
          if (_showAiChat) AiChatOverlay(onClose: _closeAiChat),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.1),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.pureWhite,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on_outlined),
              activeIcon: const Icon(Icons.location_on),
              label: l10n.navTrack,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.recycling_outlined),
              activeIcon: const Icon(Icons.recycling),
              label: l10n.navRecycle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
