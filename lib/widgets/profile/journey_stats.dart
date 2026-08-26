import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

class JourneyStats extends StatelessWidget {
  const JourneyStats({super.key});

  Widget statCard({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF14111D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .05)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .06), blurRadius: 8)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),

              const SizedBox(height: 6),

              AnimatedCounter(
                value: value,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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

    final provider = context.watch<BucketProvider>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * .04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: Color(0xFFA855F7),
                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                "Your Journey",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .02),
          Row(
            children: [
              statCard(
                value: provider.globalTotalCount,
                title: "Total",
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFFA855F7),
              ),

              statCard(
                value: provider.globalWatchingCount,
                title: "Watching",
                icon: Icons.play_circle_fill,
                color: const Color(0xFF38BDF8),
              ),

              statCard(
                value: provider.globalCompletedCount,
                title: "Done",
                icon: Icons
                    .verified_user_rounded, // Replace with your custom shield asset later
                color: const Color(0xFF22C55E),
              ),

              statCard(
                value: provider.globalFavoritesCount,
                title: "Favorites",
                icon: Icons.favorite_rounded,
                color: const Color(0xFFEC4899),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
