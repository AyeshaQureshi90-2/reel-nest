import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  bool isDarkMode = true;

  final List<String> genres = [
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Thriller',
    'Animation',
    'Adventure',
  ];

  List<String> selectedGenres = [];

  bool get isCurrentlyDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isCurrentlyDark ? dark : const Color(0xFFF4F5F7);

  Color get cardColor =>
      isCurrentlyDark ? const Color(0xFF1C1B22) : Colors.white;

  Color get textColor =>
      isCurrentlyDark ? silver : const Color(0xFF222222);

  Color get secondaryTextColor =>
      isCurrentlyDark ? Colors.white54 : Colors.black54;

  Color get arrowColor =>
      isCurrentlyDark ? Colors.white38 : Colors.black38;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      isDarkMode = prefs.getBool('is_dark_mode') ?? true;
      selectedGenres = prefs.getStringList('selected_genres') ?? [];
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_dark_mode', value);

    if (!mounted) return;

    setState(() {
      isDarkMode = value;
    });

    appThemeMode.value =
        value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _saveGenres() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_genres', selectedGenres);
  }

  void _openGenrePreferences() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Preferences',
                    style: const TextStyle(
                      color: peach,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your favorite movie genres.',
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: genres.map((genre) {
                      final isSelected =
                          selectedGenres.contains(genre);

                      return FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        selectedColor: peach,
                        backgroundColor: backgroundColor,
                        checkmarkColor: dark,
                        labelStyle: TextStyle(
                          color: isSelected ? dark : textColor,
                        ),
                        onSelected: (selected) {
                          modalSetState(() {
                            if (selected) {
                              selectedGenres.add(genre);
                            } else {
                              selectedGenres.remove(genre);
                            }
                          });

                          setState(() {});
                          _saveGenres();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: peach,
                        foregroundColor: dark,
                      ),
                      onPressed: () =>
                          Navigator.pop(modalContext),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Reset Settings?',
            style: TextStyle(color: peach),
          ),
          content: Text(
            'Your appearance and content preferences will '
            'be restored to their default values.',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: textColor),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Reset',
                style: TextStyle(color: peach),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('is_dark_mode');
    await prefs.remove('selected_genres');

    if (!mounted) return;

    setState(() {
      isDarkMode = true;
      selectedGenres = [];
    });

    appThemeMode.value = ThemeMode.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings restored to default values.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: peach),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOption(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
            trailing: Switch(
              value: isDarkMode,
              activeThumbColor: peach,
              onChanged: _saveTheme,
            ),
            onTap: () => _saveTheme(!isDarkMode),
          ),
          _buildOption(
            icon: Icons.movie_filter_outlined,
            title: 'Content Preferences',
            subtitle: selectedGenres.isEmpty
                ? 'Choose your favorite genres'
                : selectedGenres.join(', '),
            onTap: _openGenrePreferences,
          ),
          _buildOption(
            icon: Icons.restart_alt_rounded,
            title: 'Reset Settings',
            subtitle: 'Restore default settings',
            onTap: _resetSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: peach,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 12,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: arrowColor,
              size: 16,
            ),
        onTap: onTap,
      ),
    );
  }
}