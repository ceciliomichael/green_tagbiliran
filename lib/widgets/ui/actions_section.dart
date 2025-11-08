import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import 'profile_action_button.dart';

class ActionsSection extends StatelessWidget {
  final VoidCallback onShowReportStatus;
  final VoidCallback onShowLanguagePicker;
  final VoidCallback onShowHelpSupport;
  final VoidCallback onShowLogoutDialog;

  const ActionsSection({
    super.key,
    required this.onShowReportStatus,
    required this.onShowLanguagePicker,
    required this.onShowHelpSupport,
    required this.onShowLogoutDialog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.actions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Action Buttons
        ProfileActionButton(
          title: l10n.reportStatus,
          icon: Icons.assignment_outlined,
          onTap: onShowReportStatus,
        ),

        ProfileActionButton(
          title: l10n.language,
          icon: Icons.language,
          onTap: onShowLanguagePicker,
        ),

        ProfileActionButton(
          title: l10n.helpSupport,
          icon: Icons.help_outline,
          onTap: onShowHelpSupport,
        ),

        ProfileActionButton(
          title: l10n.logout,
          icon: Icons.logout,
          onTap: onShowLogoutDialog,
          color: AppColors.error,
          isDanger: true,
        ),
      ],
    );
  }
}
