
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF19151A),
              dark,
              Color(0xFF171116),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ReelNest Custom Logo
              Image.asset(
                'assets/images/reel_nest_splash.png',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 35),

              // App Name
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Reel',
                      style: TextStyle(
                        color: silver,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Nest',
                      style: TextStyle(
                        color: peach,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                'Your World of Movies',
                style: TextStyle(
                  color: silver,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 18),

              const Icon(
                Icons.auto_awesome,
                color: peach,
                size: 25,
              ),

              const Spacer(),

              // Loading Section
              const Icon(
                Icons.local_movies_rounded,
                color: peach,
                size: 32,
              ),

              const SizedBox(height: 12),

              const Text(
                'Loading...',
                style: TextStyle(
                  color: silver,
                  fontSize: 15,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 75),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: Color(0xFF343039),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(peach),
                  ),
                ),
              ),


              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
