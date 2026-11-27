
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isGuest = false;

  void _continueAsGuest() {
    setState(() {
      _isGuest = true;
    });
  }

  void _requireLogin() {
    setState(() {
      _isGuest = false;
    });

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF08090D),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFDBA9B),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Something went wrong. Please restart the app.',
              ),
            ),
          );
        }

        if (snapshot.data != null) {
          return HomeScreen(
            isGuest: false,
            onRequireLogin: _requireLogin,
          );
        }

        if (_isGuest) {
          return HomeScreen(
            isGuest: true,
            onRequireLogin: _requireLogin,
          );
        }

        return LoginScreen(
          onContinueAsGuest: _continueAsGuest,
        );
      },
    );
  }
}
