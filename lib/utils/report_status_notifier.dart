/// Utility for generating report status notification messages
class ReportStatusNotifier {
  /// Generate notification title and message for a report status update
  static Map<String, String> getNotificationContent(
    String status,
    String? adminNotes,
  ) {
    String title;
    String message;

    switch (status.toLowerCase()) {
      case 'resolved':
        title = 'Report Resolved ✓';
        message = adminNotes != null && adminNotes.trim().isNotEmpty
            ? 'Your report has been resolved. Admin notes: $adminNotes'
            : 'Your report has been resolved. Thank you for your report!';
        break;
      case 'rejected':
        title = 'Report Rejected';
        message = adminNotes != null && adminNotes.trim().isNotEmpty
            ? 'Your report has been rejected. Reason: $adminNotes'
            : 'Your report has been rejected. Please contact admin for more details.';
        break;
      case 'in_progress':
        title = 'Report In Progress';
        message = adminNotes != null && adminNotes.trim().isNotEmpty
            ? 'Your report is being processed. Update: $adminNotes'
            : 'Your report is being processed. We will update you soon.';
        break;
      default:
        title = 'Report Status Updated';
        message = adminNotes != null && adminNotes.trim().isNotEmpty
            ? 'Your report status has been updated. Notes: $adminNotes'
            : 'Your report status has been updated.';
    }

    return {'title': title, 'message': message};
  }
}

