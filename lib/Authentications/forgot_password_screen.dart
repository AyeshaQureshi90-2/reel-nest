
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  static const Color peachColor = Color(0xFFFDBA9B);
  static const Color blackColor = Color(0xFF08090D);
  static const Color darkTextColor = Color(0xFF29201D);
  static const Color lightFieldColor = Color(0xFFF5F0ED);
  static const Color darkFieldColor = Color(0xFF191A20);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: isError ? peachColor : blackColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? peachColor : blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? blackColor : peachColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      _showMessage(
        'Password reset link sent. Please check your email inbox and spam folder.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          message = 'Password reset is currently unavailable.';
          break;
        default:
          message = 'Unable to send reset link. Please try again.';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required Color textColor,
    required Color iconColor,
  }) {
    return InputDecoration(
      hintText: 'Enter your registered email',
      hintStyle: TextStyle(
        color: textColor.withValues(alpha: 0.55),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        Icons.email_outlined,
        color: iconColor,
      ),
      filled: true,
      fillColor: isDark ? darkFieldColor : lightFieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: textColor.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: iconColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF9E2525),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF9E2525),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? blackColor : peachColor;
    final textColor = isDark ? peachColor : blackColor;
    final secondaryTextColor =
        isDark ? const Color(0xFFD6B8AA) : darkTextColor;
    final iconColor = isDark ? peachColor : const Color(0xFF9B5035);
    final fieldTextColor = isDark ? peachColor : blackColor;

    final buttonBackground = isDark ? blackColor : peachColor;
    final buttonForeground = isDark ? peachColor : blackColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: isDark ? peachColor : blackColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        color: isDark ? blackColor : peachColor,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Enter your registered email address. '
                    'We will send you a secure link to change your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Email Address',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: fieldTextColor),
                    cursorColor: iconColor,
                    decoration: _inputDecoration(
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                    ),
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _resetPassword();
                    },
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

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBackground,
                        foregroundColor: buttonForeground,
                        disabledBackgroundColor:
                            buttonBackground.withValues(alpha: 0.65),
                        disabledForegroundColor:
                            buttonForeground.withValues(alpha: 0.65),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: textColor,
                      ),
                      label: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
