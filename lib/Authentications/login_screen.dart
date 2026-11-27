
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onContinueAsGuest;

  const LoginScreen({
    super.key,
    this.onContinueAsGuest,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final Future<void> _googleSignInInitialization =
      GoogleSignIn.instance.initialize();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  static const Color peachColor = Color(0xFFFDBA9B);
  static const Color blackColor = Color(0xFF08090D);
  static const Color whiteColor = Colors.white;
  static const Color lightFieldColor = Color(0xFFF5F0ED);
  static const Color darkFieldColor = Color(0xFF191A20);
  static const Color darkPeachColor = Color(0xFFE99A78);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isSuccess ? blackColor : whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isSuccess ? peachColor : blackColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      _showMessage(
        'Login successful!',
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignInInitialization;

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        if (!mounted) return;

        _showMessage(
          'Google Sign-In is not supported on this platform.',
        );
        return;
      }

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final OAuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      _showMessage(
        'Google login successful!',
        isSuccess: true,
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }

      _showMessage(
        'Google Sign-In failed. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with a different sign-in method.';
          break;
        case 'invalid-credential':
          message = 'Google authentication failed. Please try again.';
          break;
        case 'operation-not-allowed':
          message = 'Google Sign-In is not enabled in Firebase.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Google login failed.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to sign in with Google. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    required Color iconColor,
    Widget? suffixIcon,
  }) {
    final fieldColor = isDark ? darkFieldColor : lightFieldColor;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: textColor.withValues(alpha: 0.55),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: iconColor,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 19,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: textColor.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: iconColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  ButtonStyle _authButtonStyle({
    required bool isDark,
  }) {
    final buttonBackground = isDark ? blackColor : peachColor;
    final buttonForeground = isDark ? peachColor : blackColor;

    return OutlinedButton.styleFrom(
      backgroundColor: buttonBackground,
      foregroundColor: buttonForeground,
      disabledBackgroundColor:
          buttonBackground.withValues(alpha: 0.6),
      disabledForegroundColor:
          buttonForeground.withValues(alpha: 0.6),
      side: BorderSide.none,
      elevation: 4,
      shadowColor: blackColor.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? blackColor : peachColor;
    final textColor = isDark ? peachColor : blackColor;
    final secondaryTextColor =
        isDark ? const Color(0xFFD6B8AA) : const Color(0xFF514039);
    final iconColor = isDark ? peachColor : const Color(0xFF9B5035);
    final fieldTextColor = isDark ? peachColor : blackColor;

    final buttonBackground = isDark ? blackColor : peachColor;
    final buttonForeground = isDark ? peachColor : blackColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 78,
                      width: 78,
                      decoration: BoxDecoration(
                        color: isDark ? peachColor : blackColor,
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? peachColor : blackColor)
                                .withValues(alpha: 0.18),
                            blurRadius: 15,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.movie_creation_outlined,
                        color: isDark ? blackColor : peachColor,
                        size: 42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  Center(
                    child: Text(
                      'Login to continue watching your favorites.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildLabel('Email Address', textColor),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: iconColor,
                    style: TextStyle(
                      color: fieldTextColor,
                      fontSize: 14,
                    ),
                    decoration: _fieldDecoration(
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 23),

                  _buildLabel('Password', textColor),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    cursorColor: iconColor,
                    style: TextStyle(
                      color: fieldTextColor,
                      fontSize: 14,
                    ),
                    decoration: _fieldDecoration(
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      SizedBox(
                        height: 35,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: isDark ? peachColor : blackColor,
                          checkColor: isDark ? blackColor : peachColor,
                          side: BorderSide(
                            color: textColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                        ),
                      ),

                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBackground,
                        foregroundColor: buttonForeground,
                        disabledBackgroundColor:
                            buttonBackground.withValues(alpha: 0.6),
                        disabledForegroundColor:
                            buttonForeground.withValues(alpha: 0.6),
                        elevation: 4,
                        shadowColor: blackColor.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: buttonForeground,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: textColor.withValues(alpha: 0.35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: textColor.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isLoading ? null : _signInWithGoogle,
                      icon: Icon(
                        Icons.g_mobiledata_rounded,
                        color: buttonForeground,
                        size: 32,
                      ),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: buttonForeground,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: _authButtonStyle(isDark: isDark),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : widget.onContinueAsGuest,
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: buttonForeground,
                      ),
                      label: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: buttonForeground,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: _authButtonStyle(isDark: isDark),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
