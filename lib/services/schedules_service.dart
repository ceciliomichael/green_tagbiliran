import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';
import '../constants/supabase_config.dart';

part 'schedules/schedule_result.dart';
part 'schedules/schedule_crud_operations.dart';
part 'schedules/schedule_query_operations.dart';

class SchedulesService {
  static final SchedulesService _instance = SchedulesService._internal();
  factory SchedulesService() => _instance;
  SchedulesService._internal();
}
