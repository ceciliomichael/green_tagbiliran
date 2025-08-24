import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authService = AuthService();

        // Check if user is already logged in
        if (authService.isLoggedIn && authService.currentUser != null) {
          final user = authService.currentUser!;
          // Navigate based on user role
          switch (user.userRole) {
            case UserRole.admin:
              Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
              break;
            case UserRole.truckDriver:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.truckDriverMain,
              );
              break;
            case UserRole.user:
              Navigator.pushReplacementNamed(context, AppRoutes.main);
              break;
          }
        } else {
          // User is not logged in, go to login screen
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Recycle icon with white color filter
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/recycle.svg',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Loading indicator
              const LoadingIndicator(color: Colors.white, size: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
