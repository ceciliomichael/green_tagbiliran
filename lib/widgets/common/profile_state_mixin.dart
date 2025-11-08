import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

mixin ProfileStateMixin<T extends StatefulWidget> on State<T> {
  final AuthService _authService = AuthService();
  bool _isRefreshing = false;

  AuthService get authService => _authService;
  bool get isRefreshing => _isRefreshing;

  @override
  void initState() {
    super.initState();
    _checkAndRefreshUserData();
  }

  Future<void> _checkAndRefreshUserData() async {
    final user = _authService.currentUser;
    if (user == null || user.firstName.isEmpty || user.lastName.isEmpty) {
      await refreshUserData();
    }
  }

  Future<void> refreshUserData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await _authService.refreshCurrentUser();
      if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to load profile data'),
            backgroundColor: const Color(0xFFE74C3C), // AppColors.error
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C), // AppColors.error
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
