import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/edit_name_dialog.dart';
import '../../widgets/common/edit_barangay_dialog.dart';
import '../../widgets/common/edit_phone_dialog.dart';
import '../../widgets/common/language_picker.dart';

mixin ProfileActionsMixin<T extends StatefulWidget> on State<T> {
  AuthService get authService;

  void showLanguagePicker() {
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguagePicker(
        currentLocale: currentLocale,
        onLanguageChanged: (locale) {
          MainApp.setLocale(context, locale);
          setState(() {}); // Refresh the screen
        },
      ),
    );
  }

  void showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.logout,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            l10n.confirmLogoutMsg,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Store dialog context before async operation
                final dialogContext = context;
                await authService.logout();
                if (mounted && dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Close dialog
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      this.context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.logout,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditNameDialog() {
    final user = authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => EditNameDialog(
        firstName: user.firstName,
        lastName: user.lastName,
        onSave: updateUserName,
      ),
    );
  }

  void showEditBarangayDialog() {
    final user = authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => EditBarangayDialog(
        currentBarangay: user.barangay,
        onSave: updateUserBarangay,
      ),
    );
  }

  void showEditPhoneDialog() {
    final user = authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) =>
          EditPhoneDialog(currentPhone: user.phone, onSave: updateUserPhone),
    );
  }

  Future<void> updateUserName(String firstName, String lastName) async {
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final result = await authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        barangay: user.barangay,
      );

      if (result.success) {
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Name updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to update name'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> updateUserBarangay(String barangay) async {
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final result = await authService.updateUserProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        barangay: barangay,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Barangay updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update barangay'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating barangay: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> updateUserPhone(String phone) async {
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final result = await authService.updateUserProfile(
        firstName: user.firstName,
        lastName: user.lastName,
        barangay: user.barangay,
        phone: phone,
      );

      if (result.success) {
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? 'Phone number updated successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to update phone number'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating phone number: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
