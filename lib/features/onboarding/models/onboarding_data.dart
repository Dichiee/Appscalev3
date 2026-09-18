class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  static const slides = [
    OnboardingData(
      image: 'assets/images/onboarding_1.png',
      title: 'Track. Monitor.\nNourish.',
      subtitle:
          "Monitor every child's growth and nutrition status with accurate records and real-time tracking.",
    ),
    OnboardingData(
      image: 'assets/images/onboarding_2.png',
      title: 'Plan. Provide.\nImprove.',
      subtitle:
          'Manage programs and interventions effectively to help children get the nutrition they need.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_3.png',
      title: 'Stronger Data.\nStronger Community.',
      subtitle:
          'Make informed decisions, generate reports, and build a healthier community together.',
    ),
  ];
}