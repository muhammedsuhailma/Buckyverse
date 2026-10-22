import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data model for a single Coming Soon roadmap card.
class ComingSoonFeature {
  final String emoji;
  final String title;
  final String body;

  const ComingSoonFeature({
    required this.emoji,
    required this.title,
    required this.body,
  });
}

/// Roadmap section displayed on the Profile screen below ContinueJourney.
/// Replaces the old "Discover BuckyVerse" section.
class ComingSoonSection extends StatelessWidget {
  const ComingSoonSection({super.key});

  static const _roadmap = <ComingSoonFeature>[
    ComingSoonFeature(
      emoji: '🤖',
      title: 'AI Recommendations',
      body:
          'Receive personalised Anime, Movies, Series and K-Dramas based on your interests.',
    ),
    ComingSoonFeature(
      emoji: '📺',
      title: 'Auto Episode Tracking',
      body: 'Episodes update automatically while you watch.',
    ),
    ComingSoonFeature(
      emoji: '🔄',
      title: 'Smart Status Sync',
      body:
          'Planning → Watching → Completed updates automatically after finishing episodes.',
    ),
    ComingSoonFeature(
      emoji: '👥',
      title: 'Add Friends',
      body: 'Connect with friends and build your entertainment universe.',
    ),
    ComingSoonFeature(
      emoji: '💜',
      title: 'Friend Recommendations',
      body: 'Discover users with similar watchlists and interests.',
    ),
    ComingSoonFeature(
      emoji: '📊',
      title: 'Viewing Insights',
      body:
          'Track watch time, favourite genres, monthly activity and streaks.',
    ),
    ComingSoonFeature(
      emoji: '☁',
      title: 'Cross Device Sync',
      body: 'Continue your journey seamlessly across all devices.',
    ),
    ComingSoonFeature(
      emoji: '🚀',
      title: 'More Features',
      body: 'Many exciting improvements are already in development.',
    ),
  ];

  void _onCardTap(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF14111D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFA855F7),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.22),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🚀', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'This feature is coming in a future BuckyVerse update!',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * .05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────
          Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Coming Soon',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: size.width * .052,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'The next evolution of your entertainment universe.',
            style: GoogleFonts.rajdhani(
              color: Colors.white54,
              fontSize: size.width * .035,
              height: 1.4,
            ),
          ),

          SizedBox(height: size.height * .018),

          // ── Cards ─────────────────────────────────────────────────────
          ...List.generate(_roadmap.length, (i) {
            final feature = _roadmap[i];
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * .012),
              child: _ComingSoonCard(
                feature: feature,
                size: size,
                onTap: () => _onCardTap(context),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Private card widget ────────────────────────────────────────────────────────

class _ComingSoonCard extends StatefulWidget {
  final ComingSoonFeature feature;
  final Size size;
  final VoidCallback onTap;

  const _ComingSoonCard({
    required this.feature,
    required this.size,
    required this.onTap,
  });

  @override
  State<_ComingSoonCard> createState() => _ComingSoonCardState();
}

class _ComingSoonCardState extends State<_ComingSoonCard> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.97);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.04),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Emoji icon ───────────────────────────────────────────
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  widget.feature.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),

              SizedBox(width: size.width * .038),

              // ── Text ─────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feature.title,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: size.width * .041,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.feature.body,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white54,
                        fontSize: size.width * .034,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── COMING SOON badge ────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B2CFF), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.40),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'COMING\nSOON',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
