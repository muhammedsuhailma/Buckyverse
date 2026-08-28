import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A themed bottom sheet used to showcase upcoming BuckyVerse features.
/// Show with [DiscoveryTip.show].
///
/// The widget always dismisses itself using its own [BuildContext].
/// Callers do NOT need to supply [onDismiss]; the parameter is accepted
/// only for backward compatibility and is intentionally ignored — the
/// widget pops itself safely from within [build], so it can never
/// reference a disposed caller context.
class DiscoveryTip extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const DiscoveryTip({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
  });

  /// Shows the discovery tip / roadmap as a modal bottom sheet.
  ///
  /// Supports two calling conventions:
  ///
  /// **Old (feature tip):**
  /// ```dart
  /// DiscoveryTip.show(context, emoji: '🔍', title: '…', body: '…');
  /// ```
  ///
  /// **New (default roadmap):**
  /// ```dart
  /// DiscoveryTip.show(context);
  /// ```
  ///
  /// The [onDismiss] parameter is accepted for API compatibility but is
  /// intentionally ignored — the widget always pops itself using its own
  /// internal context, which is always valid.
  static Future<void> show(
    BuildContext context, {
    String? emoji,
    String? title,
    String? body,
    // Accepted for backward compatibility — intentionally unused.
    // The widget dismisses itself via its own BuildContext.
    @Deprecated('No longer needed — DiscoveryTip dismisses itself safely.')
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => DiscoveryTip(
        emoji: emoji ?? '🚀',
        title: title ?? 'More Universes Are Coming',
        body:
            body ??
            """
BuckyVerse is constantly evolving.

✨ Episode Tracking
Automatically track your episode progress.

🔄 Smart Status Sync
Planning → Watching → Completed updates automatically as you finish episodes.

🤖 AI Recommendations
Get personalized Anime, Movies, TV Shows and K-Dramas based on your taste.

👥 Add Friends
Build your own universe by connecting with friends.

💜 Friend Recommendations
Discover people with similar watchlists and interests.

🌌 And many more exciting features are already on our roadmap!

Thank you for being one of our early explorers.
""",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, size.height * .04),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF13111E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(emoji, style: const TextStyle(fontSize: 44)),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            body,
            textAlign: TextAlign.left,
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFA855F7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Every update brings new galaxies to explore.',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              // Always pop using this widget's own BuildContext — never
              // the caller's context — so this is always safe.
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continue Exploring 🚀',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
