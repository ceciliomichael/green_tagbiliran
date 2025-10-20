import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';

class ReportStatusBadge extends StatelessWidget {
  final ReportStatus status;

  const ReportStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.text,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return _StatusConfig(
          backgroundColor: AppColors.textSecondary.withValues(alpha: 0.1),
          textColor: AppColors.textSecondary,
          text: 'Pending',
        );
      case ReportStatus.inProgress:
        return _StatusConfig(
          backgroundColor: const Color(0xFFFFF3CD),
          textColor: const Color(0xFF856404),
          text: 'In Progress',
        );
      case ReportStatus.resolved:
        return _StatusConfig(
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
          textColor: AppColors.primaryGreen,
          text: 'Resolved',
        );
      case ReportStatus.rejected:
        return _StatusConfig(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          textColor: AppColors.error,
          text: 'Rejected',
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final String text;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.text,
  });
}
