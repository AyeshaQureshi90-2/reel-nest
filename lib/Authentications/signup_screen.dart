
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  static const Color peachColor = Color(0xFFFDBA9B);
  static const Color blackColor = Color(0xFF08090D);
  static const Color darkTextColor = Color(0xFF29201D);
  static const Color lightFieldColor = Color(0xFFF5F0ED);
  static const Color darkFieldColor = Color(0xFF191A20);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: blackColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: peachColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: peachColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: peachColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: blackColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 capital letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }

    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }

    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      _showErrorMessage('Please accept Terms & Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await credential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please login.';
          break;

        case 'invalid-email':
          message = 'Invalid email address. Please check your email.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Please choose a stronger password.';
          break;

        case 'operation-not-allowed':
          message = 'Email/Password authentication is not enabled.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'email-already-exists':
          message = 'This email is already in use.';
          break;

        case 'invalid-credential':
          message = 'Invalid account information. Please check your details.';
          break;

        case 'internal-error':
          message = 'A server error occurred. Please try again.';
          break;

        default:
          message = e.message ??
              'Signup failed (${e.code}). Please try again.';
      }

      _showErrorMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showErrorMessage(
        'Something went wrong. Please try again.',
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
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColor,
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

  Widget _buildLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordToggle(
    bool isVisible,
    VoidCallback onPressed,
    Color iconColor,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isVisible
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: iconColor,
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 25,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color: isDark ? peachColor : blackColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.person_add_alt_1,
                        color: isDark ? blackColor : peachColor,
                        size: 38,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      'Join ReelNest and discover your next favorite movie.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildLabel('Full Name', textColor),

                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: fieldTextColor),
                    cursorColor: iconColor,
                    decoration: _inputDecoration(
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }

                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Email Address', textColor),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: fieldTextColor),
                    cursorColor: iconColor,
                    decoration: _inputDecoration(
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

                  const SizedBox(height: 20),

                  _buildLabel('Password', textColor),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: fieldTextColor),
                    cursorColor: iconColor,
                    decoration: _inputDecoration(
                      hint: 'Create a strong password',
                      icon: Icons.lock_outline,
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                      suffixIcon: _buildPasswordToggle(
                        _isPasswordVisible,
                        () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        iconColor,
                      ),
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Password must contain 8 characters, 1 capital letter, 1 number and 1 special character.',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Confirm Password', textColor),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: TextStyle(color: fieldTextColor),
                    cursorColor: iconColor,
                    decoration: _inputDecoration(
                      hint: 'Confirm your password',
                      icon: Icons.lock_reset_outlined,
                      isDark: isDark,
                      textColor: fieldTextColor,
                      iconColor: iconColor,
                      suffixIcon: _buildPasswordToggle(
                        _isConfirmPasswordVisible,
                        () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        iconColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: isDark ? peachColor : blackColor,
                        checkColor: isDark ? blackColor : peachColor,
                        side: BorderSide(
                          color: textColor,
                          width: 1.5,
                        ),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Terms & Conditions',
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
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
