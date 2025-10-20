import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';

class AdminReportsStatsRow extends StatelessWidget {
  final List<Report> allReports;

  const AdminReportsStatsRow({
    super.key,
    required this.allReports,
  });

  int _getStatusCount(ReportStatus status) {
    return allReports.where((report) => report.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStatCard(
            count: _getStatusCount(ReportStatus.pending),
            label: 'Pending',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            count: _getStatusCount(ReportStatus.inProgress),
            label: 'In Progress',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            count: _getStatusCount(ReportStatus.resolved),
            label: 'Resolved',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required int count, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

