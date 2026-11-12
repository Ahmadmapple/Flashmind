import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF192A3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFF3C279),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Flash Mind',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: Color(0xFF192A3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Small reviews. Lasting memory.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

