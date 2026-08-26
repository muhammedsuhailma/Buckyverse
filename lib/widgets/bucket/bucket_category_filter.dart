import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BucketCategoryItem {
  final String title;
  final String emoji;

  const BucketCategoryItem(this.title, this.emoji);
}

class BucketCategoryFilter extends StatelessWidget {
  const BucketCategoryFilter({super.key});

  static const List<BucketCategoryItem> _categories = [
    BucketCategoryItem("All", "🌍"),
    BucketCategoryItem("Anime", "⚡"),
    BucketCategoryItem("Movies", "🎬"),
    BucketCategoryItem("Series", "📺"),
    BucketCategoryItem("K-Drama", "🌸"),
  ];

  Color _chipColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF6366F1); // All — Indigo
      case 1:
        return const Color(0xFF7C3AED); // Anime — Purple
      case 2:
        return const Color(0xFF2563EB); // Movies — Blue
      case 3:
        return const Color(0xFF0891B2); // Series — Cyan
      case 4:
        return const Color(0xFFDB2777); // K-Drama — Pink
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<BucketProvider>();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: size.width * .05),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = provider.selectedCategory == cat.title;
          final color = _chipColor(index);

          return GestureDetector(
            onTap: () => provider.changeCategory(cat.title),
            child: AnimatedScale(
              scale: selected ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? color : const Color(0xFF17141F),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selected
                        ? color
                        : Colors.white.withValues(alpha: .08),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: .45),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat.title,
                      style: GoogleFonts.rajdhani(
                        color: selected
                            ? Colors.white
                            : const Color(0xFFB5B0C7),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
