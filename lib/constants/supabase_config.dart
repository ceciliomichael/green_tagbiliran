class SupabaseConfig {
  // Get these from your Supabase project settings
  static const String url = 'https://wvpcosfglhanrzugelrv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2cGNvc2ZnbGhhbnJ6dWdlbHJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQ2MzUsImV4cCI6MjA3MTYxMDYzNX0.b-ZKhiboJ2r44jd7x3CFGXJE6LuQ1w4WZ3L5zuNbjNg';

  // API endpoints for custom functions
  static const String baseApiUrl = '$url/rest/v1/rpc';

  // Custom function endpoints
  static const String registerUserEndpoint = '$baseApiUrl/register_user';
  static const String loginUserEndpoint = '$baseApiUrl/login_user';
  static const String getUserProfileEndpoint = '$baseApiUrl/get_user_profile';
  static const String updateUserProfileEndpoint =
      '$baseApiUrl/update_user_profile';
  static const String createTruckDriverEndpoint =
      '$baseApiUrl/create_truck_driver';

  // Truck driver management endpoints
  static const String getAllTruckDriversEndpoint =
      '$baseApiUrl/get_all_truck_drivers';
  static const String updateTruckDriverEndpoint =
      '$baseApiUrl/update_truck_driver';
  static const String resetTruckDriverPasswordEndpoint =
      '$baseApiUrl/reset_truck_driver_password';
  static const String deleteTruckDriverEndpoint =
      '$baseApiUrl/delete_truck_driver';

  // Reports endpoints
  static const String submitReportEndpoint = '$baseApiUrl/submit_report';
  static const String getAllReportsEndpoint = '$baseApiUrl/get_all_reports';
  static const String updateReportStatusEndpoint =
      '$baseApiUrl/update_report_status';
  static const String updateReportStatusWithImagesEndpoint =
      '$baseApiUrl/update_report_status_with_images';
  static const String getReportImagesEndpoint = '$baseApiUrl/get_report_images';
  static const String getAdminResponseImagesEndpoint =
      '$baseApiUrl/get_admin_response_images';
  static const String getUserReportsEndpoint = '$baseApiUrl/get_user_reports';

  // Notifications endpoints
  static const String sendNotificationEndpoint =
      '$baseApiUrl/send_notification';
  static const String getUserNotificationsEndpoint =
      '$baseApiUrl/get_user_notifications';
  static const String markNotificationReadEndpoint =
      '$baseApiUrl/mark_notification_read';
  static const String markAllNotificationsReadEndpoint =
      '$baseApiUrl/mark_all_notifications_read';
  static const String getNotificationStatsEndpoint =
      '$baseApiUrl/get_notification_stats';

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
