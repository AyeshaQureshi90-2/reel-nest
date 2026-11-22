
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: peach.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: peach,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'How can we help you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Find answers to common questions about ReelNest.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'What is ReelNest?',
                answer:
                    'ReelNest is an entertainment discovery app '
                    'where you can explore movies, TV shows, anime '
                    'and cartoons.',
              ),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'How can I search for movies?',
                answer:
                    'Open the Search section and enter the name '
                    'of a movie or show to find available results.',
              ),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'How do I save favorites?',
                answer:
                    'Open a movie or show and use the favorite '
                    'option to add it to your favorites list. '
                    'You can view saved titles from My Favorites.',
              ),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'Can I edit my profile?',
                answer:
                    'Yes. Go to Profile, select Edit Profile, '
                    'and update your name, email or profile picture.',
              ),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'Can I change the app theme?',
                answer:
                    'Yes. Open Settings and choose Light Mode '
                    'or Dark Mode according to your preference.',
              ),

              _buildFaq(
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                question: 'Can I watch full movies in ReelNest?',
                answer:
                    'ReelNest currently focuses on discovering '
                    'entertainment titles and viewing available '
                    'trailers. Full movie playback is not currently '
                    'provided by the app.',
              ),

              const SizedBox(height: 28),

              Text(
                'Need More Help?',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.help_center_rounded,
                      color: peach,
                      size: 35,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'We are here to help!',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'For assistance or feedback, please use '
                      'the app support channel provided by '
                      'the developer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'ReelNest v1.0.0',
                  style: const TextStyle(
                    color: peach,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaq({
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: peach.withValues(alpha: 0.08),
        ),
        child: ExpansionTile(
          iconColor: peach,
          collapsedIconColor: peach,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          title: Text(
            question,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
