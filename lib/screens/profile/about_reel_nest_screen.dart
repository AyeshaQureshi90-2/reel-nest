
import 'package:flutter/material.dart';

class AboutReelNestScreen extends StatelessWidget {
  const AboutReelNestScreen({super.key});

  static const Color peach = Color(0xFFFDBA9B);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color dark = Color(0xFF08090D);

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDarkMode ? dark : const Color(0xFFF4F5F7);

    final cardColor =
        isDarkMode ? const Color(0xFF1C1B22) : Colors.white;

    final primaryTextColor =
        isDarkMode ? silver : const Color(0xFF252525);

    final secondaryTextColor =
        isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
        title: Text(
          'About ReelNest',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: peach.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.movie_creation_rounded,
                  color: peach,
                  size: 55,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'ReelNest',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your Personal Entertainment Space',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              _buildSection(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                title: 'About the App',
                icon: Icons.info_outline_rounded,
                description:
                    'ReelNest is an entertainment discovery app '
                    'that helps you explore movies, TV shows, anime '
                    'and cartoons in one place. Discover content, '
                    'explore different categories and keep track '
                    'of your favorite titles.',
              ),

              const SizedBox(height: 16),

              _buildSection(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                title: 'Explore Entertainment',
                icon: Icons.movie_filter_outlined,
                description:
                    'Browse trending movies, Indian movies, '
                    'Pakistani movies, popular anime and cartoons '
                    'through different collections.',
              ),

              const SizedBox(height: 16),

              _buildSection(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                title: 'Search & Categories',
                icon: Icons.search_rounded,
                description:
                    'Find entertainment titles using the search '
                    'feature and explore content through organized '
                    'categories.',
              ),

              const SizedBox(height: 16),

              _buildSection(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                title: 'My Favorites',
                icon: Icons.favorite_border_rounded,
                description:
                    'Save your favorite titles and access them '
                    'easily whenever you want.',
              ),

              const SizedBox(height: 16),

              _buildSection(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                title: 'Our Purpose',
                icon: Icons.stars_rounded,
                description:
                    'Our goal is to provide a simple and enjoyable '
                    'way to discover entertainment with a clean '
                    'interface and a personalized experience.',
              ),

              const SizedBox(height: 28),

              Text(
                'Made with Flutter',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'ReelNest v1.0.0',
                style: TextStyle(
                  color: peach,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: peach, size: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
