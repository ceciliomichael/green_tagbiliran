import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../utils/date_formatter.dart';
import 'report_status_badge.dart';

class UserReportDetailInfoCard extends StatelessWidget {
  final Report report;

  const UserReportDetailInfoCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ReportStatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.assignment_outlined,
            'Report ID: ${report.id.substring(0, 8)}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, report.fullName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, report.phone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, report.barangay),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_outlined,
            DateFormatter.formatDateTime(report.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

