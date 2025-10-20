import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../constants/supabase_config.dart';
import 'package:flutter/foundation.dart';

part 'reports/reports_result.dart';
part 'reports/reports_user_operations.dart';
part 'reports/reports_admin_operations.dart';
part 'reports/reports_image_operations.dart';

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

}
