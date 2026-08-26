import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

class BucketStats extends StatelessWidget {
  const BucketStats({super.key});

  Widget statCard({
    required int count,
    required String title,
    required Color countColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ScaleOnPress(
        onTap: onTap,
        child: Container(
          height: 90,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF121018),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCounter(
                value: count,
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: countColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFF7C6F99),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
      child: Row(
        children: [
          statCard(
            count: provider.totalCount,
            title: "Total",
            countColor: const Color(0xFFA855F7),
            onTap: () => provider.changeFilter("All"),
          ),

          statCard(
            count: provider.watchingCount,
            title: "Watching",
            countColor: const Color(0xFF38BDF8),
            onTap: () => provider.changeFilter("Watching"),
          ),

          statCard(
            count: provider.completedCount,
            title: "Done",
            countColor: const Color(0xFF22C55E),
            onTap: () => provider.changeFilter("Completed"),
          ),

          statCard(
            count: provider.favoritesCount,
            title: "Faves",
            countColor: const Color(0xFFEC4899),
            onTap: () => provider.changeFilter("Favorites"),
          ),
        ],
      ),
    );
  }
}
