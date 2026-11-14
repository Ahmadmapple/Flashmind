import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import 'intermediary_screen.dart';
import 'login_screen.dart';

// Splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await context.read<AuthProvider>().checkLoginStatus();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            isLoggedIn ? const IntermediaryScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80 * s,
              height: 80 * s,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 40 * s,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Flash Mind',
              style: TextStyle(
                fontSize: 32 * s,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Small reviews. Lasting memory.',
              style: TextStyle(fontSize: AppFont.body * s, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}