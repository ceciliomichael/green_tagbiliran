part of '../reports_service.dart';

class ReportsResult {
  final bool success;
  final String? error;
  final List<Report>? reports;
  final Report? report;
  final List<ReportImage>? images;
  final List<AdminResponseImage>? adminResponseImages;
  final String? message;
  final int? totalCount;

  ReportsResult({
    required this.success,
    this.error,
    this.reports,
    this.report,
    this.images,
    this.adminResponseImages,
    this.message,
    this.totalCount,
  });
}

