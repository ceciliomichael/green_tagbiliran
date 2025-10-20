import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/auth_service.dart';
import '../../widgets/ui/user_report_detail_info_card.dart';
import '../../widgets/ui/report_description_card.dart';
import '../../widgets/ui/report_images_card.dart';
import '../../widgets/ui/report_admin_notes_card.dart';
import '../../widgets/ui/report_admin_response_images_card.dart';

class UserReportDetailScreen extends StatefulWidget {
  final Report report;

  const UserReportDetailScreen({super.key, required this.report});

  @override
  State<UserReportDetailScreen> createState() => _UserReportDetailScreenState();
}

class _UserReportDetailScreenState extends State<UserReportDetailScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Report Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            UserReportDetailInfoCard(report: widget.report),
            const SizedBox(height: 16),
            ReportDescriptionCard(description: widget.report.issueDescription),
            const SizedBox(height: 16),
            if (currentUser != null)
              ReportImagesCard(
                reportId: widget.report.id,
                userId: currentUser.id,
                hasImage: widget.report.hasImage,
              ),
            const SizedBox(height: 16),
            ReportAdminNotesCard(adminNotes: widget.report.adminNotes),
            const SizedBox(height: 16),
            if (currentUser != null)
              ReportAdminResponseImagesCard(
                reportId: widget.report.id,
                userId: currentUser.id,
                hasAdminResponseImage: widget.report.hasAdminResponseImage,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

