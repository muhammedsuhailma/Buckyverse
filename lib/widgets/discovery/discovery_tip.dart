import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A themed bottom sheet used to surface first-time feature tips.
/// Show with [DiscoveryTip.show].
class DiscoveryTip extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final VoidCallback? onDismiss;

  const DiscoveryTip({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    this.onDismiss,
  });

  /// Shows the tip as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String emoji,
    required String title,
    required String body,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => DiscoveryTip(
        emoji: emoji,
        title: title,
        body: body,
        onDismiss: onDismiss ?? () => Navigator.pop(context),
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
          // Pill indicator
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 14),

          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(
            body,
            style: GoogleFonts.rajdhani(
              color: Colors.white60,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Got it button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: onDismiss ?? () => Navigator.pop(context),
              child: Text(
                'Got it  ✦',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
