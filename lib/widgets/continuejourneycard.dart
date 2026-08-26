import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

class ContinueJourneyCard extends StatelessWidget {
  final String image;
  final String title;
  final String category;
  final String lastOpened;
  final VoidCallback? onTap;

  const ContinueJourneyCard({
    super.key,
    required this.image,
    required this.title,
    required this.category,
    required this.lastOpened,
    this.onTap,
  });

  LinearGradient get categoryGradient {
    switch (category) {
      case "⚡ Anime":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff7C3AED), Color(0xff3B0764)],
        );

      case "🎬 Movies":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff2563EB), Color(0xff1E3A8A)],
        );

      case "📺 Series":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff0891B2), Color(0xff164E63)],
        );

      case "🌸 K-Drama":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xffDB2777), Color(0xff831843)],
        );

      default:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff7C3AED), Color(0xff3B0764)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 23, 2, 30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xff2C2143).withValues(alpha: .45)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8B5CF6).withValues(alpha: .08),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Hero(
                tag: "new_$title",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MediaImage(
                    image: image,
                    width: 68,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: categoryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.rajdhani(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color.fromARGB(255, 75, 61, 87),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
