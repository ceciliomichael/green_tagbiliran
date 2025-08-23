import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class IssueStatusScreen extends StatefulWidget {
  const IssueStatusScreen({super.key});

  @override
  State<IssueStatusScreen> createState() => _IssueStatusScreenState();
}

class _IssueStatusScreenState extends State<IssueStatusScreen> {
  // TODO: In a real app, this would come from a database or API
  final List<IssueReport> _reports = [];

  Widget _buildStatusBadge(IssueStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case IssueStatus.pending:
        backgroundColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        text = 'Pending';
        break;
      case IssueStatus.inProgress:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        text = 'In Progress';
        break;
      case IssueStatus.resolved:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        text = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReportCard(IssueReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report #${report.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  report.barangay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  report.dateSubmitted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Reports Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t submitted any reports yet.\nTap "Click & Complaint" on the home screen to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Report Status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _reports.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Your Reported Issues',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._reports.map((report) => _buildReportCard(report)),
              ],
            ),
    );
  }
}

enum IssueStatus { pending, inProgress, resolved }

class IssueReport {
  final String id;
  final String description;
  final String barangay;
  final String dateSubmitted;
  final IssueStatus status;
  final String? imagePath;

  IssueReport({
    required this.id,
    required this.description,
    required this.barangay,
    required this.dateSubmitted,
    required this.status,
    this.imagePath,
  });
}
