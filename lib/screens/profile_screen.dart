
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile/edit_profile_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/about_reel_nest_screen.dart';
import 'profile/help_support_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  String? profileName;
  String? profileEmail;
  String? profileImagePath;

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
      isDarkMode ? Colors.white54 : Colors.black54;

  Color get arrowColor =>
      isDarkMode ? Colors.white38 : Colors.black38;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      profileName = prefs.getString('profile_name');
      profileEmail = prefs.getString('profile_email');
      profileImagePath = prefs.getString('profile_image_path');
    });
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutReelNestScreen(),
      ),
    );
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (profileImagePath != null &&
        File(profileImagePath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(profileImagePath!),
          width: 115,
          height: 115,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Icon(
      Icons.person_rounded,
      color: peach,
      size: 70,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 25),

              Container(
                height: 115,
                width: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: imageBackgroundColor,
                  border: Border.all(
                    color: peach,
                    width: 2,
                  ),
                ),
                child: _buildProfileImage(),
              ),

              const SizedBox(height: 18),

              Text(
                profileName?.isNotEmpty == true
                    ? profileName!
                    : 'Welcome to ReelNest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                profileEmail?.isNotEmpty == true
                    ? profileEmail!
                    : 'Your personal entertainment space',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 35),

              _buildProfileOption(
                Icons.person_outline_rounded,
                'Edit Profile',
                _openEditProfile,
              ),

              _buildProfileOption(
                Icons.favorite_border_rounded,
                'My Favorites',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),

              _buildProfileOption(
                Icons.settings_outlined,
                'Settings',
                _openSettings,
              ),

              _buildProfileOption(
                Icons.info_outline_rounded,
                'About ReelNest',
                _openAbout,
              ),

              _buildProfileOption(
                Icons.help_outline_rounded,
                'Help & Support',
                _openHelpSupport,
              ),

              const SizedBox(height: 25),

              Text(
                'ReelNest v1.0.0',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: peach,
          size: 25,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: arrowColor,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
