import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../constants/onboarding_data.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < OnboardingConstants.onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    final authService = AuthService();

    // Check if user is properly logged in
    if (authService.isLoggedIn && authService.currentUser != null) {
      final user = authService.currentUser!;

      // Navigate based on user role
      switch (user.userRole) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, AppRoutes.adminMain);
          break;
        case UserRole.truckDriver:
          Navigator.pushReplacementNamed(context, AppRoutes.truckDriverMain);
          break;
        case UserRole.user:
          Navigator.pushReplacementNamed(context, AppRoutes.main);
          break;
      }
    } else {
      // If not properly authenticated, go to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        OnboardingConstants.onboardingPages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryGreen
                : AppColors.shadowDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(BuildContext context, OnboardingData data, int index) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get localized title and description based on index
    String title;
    String description;
    
    switch (index) {
      case 0:
        title = l10n.onb1Title;
        description = l10n.onb1Desc;
        break;
      case 1:
        title = l10n.onb2Title;
        description = l10n.onb2Desc;
        break;
      case 2:
        title = l10n.onb3Title;
        description = l10n.onb3Desc;
        break;
      default:
        title = data.title;
        description = data.description;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark.withValues(alpha: 0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(data.image, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: _buildButton(text: l10n.onboardingSkip, onPressed: _skipOnboarding),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: OnboardingConstants.onboardingPages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    context,
                    OnboardingConstants.onboardingPages[index],
                    index,
                  );
                },
              ),
            ),

            // Bottom section with indicators and next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  _buildPageIndicator(),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildButton(
                        text:
                            _currentPage ==
                                OnboardingConstants.onboardingPages.length - 1
                            ? l10n.onboardingGetStarted
                            : l10n.onboardingNext,
                        onPressed: _nextPage,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
