import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../models/user.dart';
import 'profile_info_card.dart';

class AccountInformationSection extends StatelessWidget {
  final User? user;
  final String Function(DateTime?) formatDate;
  final VoidCallback onEditName;
  final VoidCallback onEditPhone;
  final VoidCallback onEditBarangay;

  const AccountInformationSection({
    super.key,
    required this.user,
    required this.formatDate,
    required this.onEditName,
    required this.onEditPhone,
    required this.onEditBarangay,
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
          child: Text(
            l10n.accountInformation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Account Details
        ProfileInfoCard(
          title: l10n.fullName,
          value: user?.fullName ?? 'N/A',
          icon: Icons.person_outline,
          onTap: onEditName,
        ),

        ProfileInfoCard(
          title: l10n.phoneNumber,
          value: user?.phone ?? 'N/A',
          icon: Icons.phone_outlined,
          onTap: onEditPhone,
        ),

        ProfileInfoCard(
          title: 'Barangay',
          value: user?.barangay ?? 'N/A',
          icon: Icons.location_city_outlined,
          onTap: onEditBarangay,
        ),

        ProfileInfoCard(
          title: l10n.memberSince,
          value: formatDate(user?.createdAt),
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}
