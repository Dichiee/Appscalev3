import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/hive_boxes.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../shell/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _settings = SettingsRepository();

  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rememberMe = _settings.rememberMe;
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await _settings.setRememberMe(_rememberMe);

    // TODO: replace with real auth once backend/Hive user store is ready.
    await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/images/appscale_logo.png', width: 130),
              const SizedBox(height: 12),
              Text('BNS Health Monitoring', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Barangay Nutrition Scholar Portal',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('Municipality of Gasan', style: AppTextStyles.body),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome BNS!', style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter username or email',
                      icon: Icons.person_outline,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Password',
                      hint: 'Enter password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primaryGreen,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('Remember Me', style: AppTextStyles.body, softWrap: false),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: navigate to forgot-password flow
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.body.copyWith(color: AppColors.darkGreen, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Login',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}