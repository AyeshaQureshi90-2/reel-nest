
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;

  appThemeMode.value =
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const ReelNestApp());
}

class ReelNestApp extends StatelessWidget {
  const ReelNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ReelNest',
          themeMode: currentTheme,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFDBA9B),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF08090D),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFDBA9B),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
