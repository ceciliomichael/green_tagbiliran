class OnboardingData {
  final String image;
  final String title;
  final String description;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingConstants {
  static const List<OnboardingData> onboardingPages = [
    OnboardingData(
      image: 'assets/images/onboarding/onboarding1.png',
      title: 'Track your garbage truck',
      description:
          'Know where the garbage truck is and don\'t miss to dump your trash',
    ),
    OnboardingData(
      image: 'assets/images/onboarding/onboarding2.png',
      title: 'Click & Upload',
      description:
          'Click and upload anytime, anywhere and your complaint will be filed',
    ),
    OnboardingData(
      image: 'assets/images/onboarding/onboarding3.png',
      title: '3R\'s for Life',
      description: 'Segregate your waste and learn',
    ),
  ];
}
