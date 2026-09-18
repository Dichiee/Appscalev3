import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';

/// Wraps every primary screen (Home, List, Program, Reports). The nav
/// bar — including Add — is the single bottomNavigationBar; there is no
/// separate floating layer anymore.
class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTabSelected: onTabSelected,
        onAddPressed: onAddPressed,
      ),
    );
  }
}