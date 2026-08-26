import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Profile section that introduces BuckyVerse features.
/// Displayed inside ProfileScreen below ContinueJourney.
class DiscoverBuckyVerse extends StatelessWidget {
  const DiscoverBuckyVerse({super.key});

  static const _features = [
    _FeatureItem(
      emoji: '🔍',
      title: 'Universal Search',
      body: 'Find Anime, Movies, Series and K-Dramas in one tap.',
    ),
    _FeatureItem(
      emoji: '🌐',
      title: 'Language Explorer',
      body: 'Browse Hindi, Malayalam, Tamil, Korean, Japanese & more.',
    ),
    _FeatureItem(
      emoji: '🪣',
      title: 'Bucket Tracking',
      body: 'Track what you\'re watching, planning or completed.',
    ),
    _FeatureItem(
      emoji: '📡',
      title: 'Smart Offline',
      body: 'We detect connection loss and reconnect automatically.',
    ),
    _FeatureItem(
      emoji: '✨',
      title: 'Cosmic Refresh',
      body: 'Shake your phone anytime to refresh the universe.',
    ),
    _FeatureItem(
      emoji: '🔔',
      title: 'Notifications',
      body: 'Cosmic alerts for trending content and your bucket.',
    ),
    _FeatureItem(
      emoji: '🪐',
      title: 'Hidden Easter Eggs',
      body: 'Something rare awaits those who explore the cosmos…',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * .05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Discover BuckyVerse',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: size.width * .052,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .018),

          // Feature cards
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * .012),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * .042,
                  vertical: size.height * .016,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF13111E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .07),
                  ),
                ),
                child: Row(
                  children: [
                    // Emoji icon
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(f.emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                    SizedBox(width: size.width * .038),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: size.width * .041,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            f.body,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: size.width * .034,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String emoji;
  final String title;
  final String body;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.body,
  });
}
