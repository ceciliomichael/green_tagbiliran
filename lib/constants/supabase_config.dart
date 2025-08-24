class SupabaseConfig {
  // TODO: Replace these with your actual Supabase project credentials
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

  // Reports endpoints
  static const String submitReportEndpoint = '$baseApiUrl/submit_report';
  static const String getAllReportsEndpoint = '$baseApiUrl/get_all_reports';
  static const String updateReportStatusEndpoint =
      '$baseApiUrl/update_report_status';
  static const String getReportImagesEndpoint = '$baseApiUrl/get_report_images';
  static const String getUserReportsEndpoint = '$baseApiUrl/get_user_reports';

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
