part of '../schedules_service.dart';

class ScheduleResult {
  final bool success;
  final String? error;
  final Schedule? schedule;
  final List<Schedule>? schedules;
  final String? message;
  final int? schedulesCreated;

  ScheduleResult({
    required this.success,
    this.error,
    this.schedule,
    this.schedules,
    this.message,
    this.schedulesCreated,
  });
}

