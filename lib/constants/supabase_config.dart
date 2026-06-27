import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Get these from your Supabase project settings
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // API endpoints for custom functions
  static String get baseApiUrl => '$url/rest/v1/rpc';

  // Custom function endpoints
  static String get registerUserEndpoint => '$baseApiUrl/register_user';
  static String get loginUserEndpoint => '$baseApiUrl/login_user';
  static String get getUserProfileEndpoint => '$baseApiUrl/get_user_profile';
  static String get updateUserProfileEndpoint =>
      '$baseApiUrl/update_user_profile';
  static String get createTruckDriverEndpoint =>
      '$baseApiUrl/create_truck_driver';

  // Truck driver management endpoints
  static String get getAllTruckDriversEndpoint =>
      '$baseApiUrl/get_all_truck_drivers';
  static String get updateTruckDriverEndpoint =>
      '$baseApiUrl/update_truck_driver';
  static String get resetTruckDriverPasswordEndpoint =>
      '$baseApiUrl/reset_truck_driver_password';
  static String get deleteTruckDriverEndpoint =>
      '$baseApiUrl/delete_truck_driver';

  // Reports endpoints
  static String get submitReportEndpoint => '$baseApiUrl/submit_report';
  static String get getAllReportsEndpoint => '$baseApiUrl/get_all_reports';
  static String get updateReportStatusEndpoint =>
      '$baseApiUrl/update_report_status';
  static String get updateReportStatusWithImagesEndpoint =>
      '$baseApiUrl/update_report_status_with_images';
  static String get getReportImagesEndpoint => '$baseApiUrl/get_report_images';
  static String get getAdminResponseImagesEndpoint =>
      '$baseApiUrl/get_admin_response_images';
  static String get getUserReportsEndpoint => '$baseApiUrl/get_user_reports';

  // Notifications endpoints
  static String get sendNotificationEndpoint =>
      '$baseApiUrl/send_notification';
  static String get getUserNotificationsEndpoint =>
      '$baseApiUrl/get_user_notifications';
  static String get markNotificationReadEndpoint =>
      '$baseApiUrl/mark_notification_read';
  static String get markAllNotificationsReadEndpoint =>
      '$baseApiUrl/mark_all_notifications_read';
  static String get getNotificationStatsEndpoint =>
      '$baseApiUrl/get_notification_stats';

  // Driver Status Tracking endpoints
  static String get updateDriverStatusEndpoint =>
      '$baseApiUrl/update_driver_status';
  static String get getDriverStatusForBarangayEndpoint =>
      '$baseApiUrl/get_driver_status_for_barangay';
  static String get getAllDriverStatusesEndpoint =>
      '$baseApiUrl/get_all_driver_statuses';
  static String get getDriverStatusHistoryEndpoint =>
      '$baseApiUrl/get_driver_status_history';

  // Headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  };

  // Headers for authenticated requests
  static Map<String, String> getAuthHeaders(String? accessToken) => {
    'Content-Type': 'application/json',
    'apikey': anonKey,
    'Authorization': 'Bearer ${accessToken ?? anonKey}',
  };
}
