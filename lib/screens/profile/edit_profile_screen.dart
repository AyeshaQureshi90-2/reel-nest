import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _profileImagePath;
  String? _newImagePath;

  bool _isLoading = true;
  bool _isSaving = false;

  bool get isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? dark : const Color(0xFFF4F5F7);

  Color get cardColor =>
      isDarkMode ? const Color(0xFF1C1B22) : Colors.white;

  Color get imageBackgroundColor =>
      isDarkMode ? const Color(0xFF29202A) : const Color(0xFFE1E3E8);

  Color get primaryTextColor =>
      isDarkMode ? silver : const Color(0xFF252525);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white38 : Colors.black38;

  Color get borderColor =>
      isDarkMode ? const Color(0xFF34313B) : const Color(0xFFD5D7DC);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    _nameController.text = prefs.getString('profile_name') ?? '';
    _emailController.text = prefs.getString('profile_email') ?? '';

    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        _newImagePath = pickedFile.path;
        _profileImagePath = pickedFile.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select image. Please try again.'),
        ),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailPattern =
        RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  Future<String?> _saveProfileImage() async {
    if (_newImagePath == null) {
      return _profileImagePath;
    }

    final directory = await getApplicationDocumentsDirectory();

    final extension = _newImagePath!.contains('.')
        ? _newImagePath!.split('.').last
        : 'jpg';

    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final savedFile = await File(_newImagePath!).copy(
      '${directory.path}/$fileName',
    );

    return savedFile.path;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedImagePath = await _saveProfileImage();

      await prefs.setString(
        'profile_name',
        _nameController.text.trim(),
      );

      await prefs.setString(
        'profile_email',
        _emailController.text.trim(),
      );

      if (savedImagePath != null) {
        await prefs.setString(
          'profile_image_path',
          savedImagePath,
        );
      } else {
        await prefs.remove('profile_image_path');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF2E8B57),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: peach,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 125,
                              width: 125,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: imageBackgroundColor,
                                border: Border.all(
                                  color: peach,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _profileImagePath != null &&
                                        File(_profileImagePath!).existsSync()
                                    ? Image.file(
                                        File(_profileImagePath!),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        color: peach,
                                        size: 75,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            TextButton.icon(
                              onPressed: _isSaving ? null : _pickImage,
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: peach,
                              ),
                              label: const Text(
                                'Change Profile Photo',
                                style: TextStyle(
                                  color: peach,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Full Name',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _nameController,
                        validator: _validateName,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: primaryTextColor),
                        decoration: _inputDecoration(
                          'Enter your name',
                          Icons.person_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Email Address',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: primaryTextColor),
                        decoration: _inputDecoration(
                          'Enter your email',
                          Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: peach,
                            foregroundColor: dark,
                            disabledBackgroundColor: peach.withValues(
                              alpha: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: dark,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
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
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: secondaryTextColor),
      prefixIcon: const Icon(
        Icons.person_outline_rounded,
        color: peach,
      ),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: peach,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    ).copyWith(
      prefixIcon: Icon(icon, color: peach),
    );
  }
}