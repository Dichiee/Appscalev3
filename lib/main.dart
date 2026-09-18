import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_boxes.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();
  runApp(const AppScaleApp());
}

class AppScaleApp extends StatelessWidget {
  const AppScaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppScale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScale),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}