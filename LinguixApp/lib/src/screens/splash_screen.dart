import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      final user = FirebaseAuth.instance.currentUser;

      Navigator.pushReplacementNamed(
        context,
        user != null ? '/home' : '/login',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient, // Navy-to-black gradient
        ),
        child: FadeTransition(
          opacity: _animation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.translate,
                  size: 80,
                  color: AppTheme.accentTeal, // Teal for icons
                ),
                const SizedBox(height: 20),
                Text(
                  "Linguix",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white, // White for contrast on gradient
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}