import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BucketFilterItem {
  final String title;
  final IconData icon;

  const BucketFilterItem(this.title, this.icon);
}

class BucketFilter extends StatefulWidget {
  const BucketFilter({super.key});

  @override
  State<BucketFilter> createState() => _BucketFilterState();
}

class _BucketFilterState extends State<BucketFilter> {
  final filters = [
    BucketFilterItem("All", Icons.dashboard_rounded),
    BucketFilterItem("Planning", Icons.event_available_rounded),
    BucketFilterItem("Watching", Icons.play_circle_fill_rounded),
    BucketFilterItem("Completed", Icons.task_alt_rounded),
    BucketFilterItem("Favorites", Icons.favorite_border_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<BucketProvider>();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: size.width * .05),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = provider.selectedFilter == filters[index].title;
          return GestureDetector(
            onTap: () {
              provider.changeFilter(filters[index].title);
            },
            child: AnimatedScale(
              scale: selected ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? getSelectedColor(index)
                      : const Color(0xFF17141F),

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: selected
                        ? getSelectedColor(index)
                        : Colors.white.withValues(alpha: .08),
                  ),

                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: getSelectedColor(index).withValues(alpha: .45),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filters[index].icon,
                      size: 18,
                      color: selected ? Colors.white : const Color(0xFFB5B0C7),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      filters[index].title,
                      style: GoogleFonts.rajdhani(
                        color: selected
                            ? Colors.white
                            : const Color(0xFFB5B0C7),
                        fontSize: 15,
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

Color getSelectedColor(int index) {
  switch (index) {
    case 0:
      return const Color(0xFF6366F1); // All (Indigo)

    case 1:
      return const Color(0xFFA855F7); // Planning

    case 2:
      return const Color(0xFF06B6D4); // Watching

    case 3:
      return const Color(0xFF22C55E); // Completed

    case 4:
      return const Color(0xFFEC4899); // Favorites

    default:
      return const Color(0xFFA855F7);
  }
}
