import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/report/report_issue_screen.dart';
import 'screens/report/issue_status_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/track/track_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/admin/admin_reports_screen.dart';
import 'screens/admin/admin_events_screen.dart';
import 'screens/admin/admin_schedule_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_notifications_screen.dart';
import 'screens/admin/admin_truck_drivers_screen.dart';
import 'screens/driver/truck_driver_main_screen.dart';
import 'constants/routes.dart';
import 'constants/colors.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication service
  await AuthService().initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Tagbilaran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.reportIssue: (context) => const ReportIssueScreen(),
        AppRoutes.issueStatus: (context) => const IssueStatusScreen(),
        AppRoutes.schedule: (context) => const ScheduleScreen(),
        AppRoutes.events: (context) => const EventsScreen(),
        AppRoutes.notifications: (context) => const NotificationsScreen(),
        AppRoutes.track: (context) => const TrackScreen(),
        // Admin routes
        AppRoutes.adminMain: (context) => const AdminMainScreen(),
        AppRoutes.adminReports: (context) => const AdminReportsScreen(),
        AppRoutes.adminEvents: (context) => const AdminEventsScreen(),
        AppRoutes.adminSchedule: (context) => const AdminScheduleScreen(),
        AppRoutes.adminUsers: (context) => const AdminUsersScreen(),
        AppRoutes.adminNotifications: (context) =>
            const AdminNotificationsScreen(),
        AppRoutes.adminTruckDrivers: (context) =>
            const AdminTruckDriversScreen(),
        // Truck Driver routes
        AppRoutes.truckDriverMain: (context) => const TruckDriverMainScreen(),
      },
    );
  }
}
