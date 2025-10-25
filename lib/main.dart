import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'utils/fallback_material_localizations.dart';
import 'utils/fallback_cupertino_localizations.dart';
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
import 'screens/profile/help_support_screen.dart';
import 'constants/routes.dart';
import 'constants/colors.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize authentication service
  await AuthService().initialize();

  // Load saved locale
  final savedLocale = await LanguageService.getSavedLocale();

  runApp(MainApp(initialLocale: savedLocale));
}

class MainApp extends StatefulWidget {
  final Locale? initialLocale;

  const MainApp({super.key, this.initialLocale});

  @override
  State<MainApp> createState() => _MainAppState();

  // Static method to change language from anywhere in the app
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(locale);
  }
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LanguageService.saveLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Tagbilaran',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Fallback to English for Material/Cupertino when Cebuano is selected
      localeResolutionCallback: (locale, supportedLocales) {
        // If the device locale is not supported, default to English
        if (locale == null) {
          return const Locale('en');
        }
        
        // Check if we support this language
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        
        // Fallback to English
        return const Locale('en');
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.copyWith(
            bodyLarge: const TextStyle(color: AppColors.textPrimary),
            bodyMedium: const TextStyle(color: AppColors.textPrimary),
          ),
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
        AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
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
