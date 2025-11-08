import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../widgets/ui/profile_header.dart';
import '../../widgets/ui/account_information_section.dart';
import '../../widgets/ui/actions_section.dart';
import '../../widgets/common/profile_state_mixin.dart';
import '../../widgets/common/profile_actions_mixin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with ProfileStateMixin<ProfileScreen>, ProfileActionsMixin<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              onPressed: refreshUserData,
              icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
              tooltip: 'Refresh Profile',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshUserData,
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              ProfileHeader(user: user),

              const SizedBox(height: 16),

              // Account Information Section
              AccountInformationSection(
                user: user,
                formatDate: formatDate,
                onEditName: showEditNameDialog,
                onEditPhone: showEditPhoneDialog,
                onEditBarangay: showEditBarangayDialog,
              ),

              const SizedBox(height: 32),

              // Actions Section
              ActionsSection(
                onShowReportStatus: () {
                  Navigator.pushNamed(context, AppRoutes.issueStatus);
                },
                onShowLanguagePicker: showLanguagePicker,
                onShowHelpSupport: () {
                  Navigator.pushNamed(context, AppRoutes.helpSupport);
                },
                onShowLogoutDialog: showLogoutDialog,
              ),

              const SizedBox(height: 32),

              // App Version
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.appVersion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
