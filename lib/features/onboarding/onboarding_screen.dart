import 'package:flutter/material.dart';
import '../../data/local/hive_boxes.dart';
import '../../shared/widgets/app_button.dart';
import '../auth/login_screen.dart';
import 'models/onboarding_data.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == OnboardingData.slides.length - 1;

  void _next() {
    if (_isLastPage) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await SettingsRepository().setSeenOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingData.slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) =>
                    OnboardingPage(data: OnboardingData.slides[index]),
              ),
            ),
            PageIndicator(
              count: OnboardingData.slides.length,
              activeIndex: _currentPage,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AppButton(
                label: _isLastPage ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}