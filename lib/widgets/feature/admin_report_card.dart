import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../ui/report_status_badge.dart';

class AdminReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onUpdate;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const AdminReportCard({
    super.key,
    required this.report,
    required this.onUpdate,
    required this.onDetails,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
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
            _buildHeader(),
            const SizedBox(height: 12),
            _buildDescription(),
            const SizedBox(height: 12),
            _buildMetadata(),
            if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAdminNotes(),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ReportStatusBadge(status: report.status),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      report.issueDescription,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Row(
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
          _formatDate(report.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        if (report.hasImage) ...[
          const SizedBox(width: 16),
          const Icon(
            Icons.image_outlined,
            size: 16,
            color: AppColors.primaryGreen,
          ),
        ],
      ],
    );
  }

  Widget _buildAdminNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Notes:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            report.adminNotes!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onUpdate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                'Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            tooltip: 'Delete Report',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

