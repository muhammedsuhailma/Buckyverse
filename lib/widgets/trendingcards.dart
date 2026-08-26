import 'package:bucky_verse/utils/hero_tag.dart';
import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

class TrendingCard extends StatelessWidget {
  final String image;
  final String title;
  final String category;
  final String rating;
  final double width;
  final double height;
  final double borderRadius;
  final String year;
  final VoidCallback? onTap;
  final int id;
  final String tagPrefix;

  const TrendingCard({
    super.key,
    required this.image,
    required this.title,
    required this.category,
    required this.rating,
    required this.year,
    this.onTap,
    required this.id,
    this.tagPrefix = "",
    this.width = 158,
    this.height = 235,
    this.borderRadius = 20,
  });

  LinearGradient get categoryGradient {
    switch (category) {
      case "Anime":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff7C3AED), Color(0xff3B0764)],
        );

      case "Movies":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff2563EB), Color(0xff1E3A8A)],
        );

      case "Series":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff0891B2), Color(0xff164E63)],
        );

      case "K-Drama":
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
    final tag = heroTag(category: category, id: id, prefix: tagPrefix);

    return SizedBox(
      width: width,
      height: height,

      child: ScaleOnPress(
        onTap: onTap,
        child: Stack(
          children: [
            Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MediaImage(image: image, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.55, 0.75, 1.0],
                            colors: [
                              const Color.fromARGB(0, 0, 0, 0),
                              Colors.transparent,
                              const Color.fromARGB(205, 0, 0, 0),
                              const Color.fromARGB(205, 0, 0, 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(13, 11, 9, 9),
                              Colors.transparent,
                              const Color.fromARGB(
                                255,
                                30,
                                28,
                                28,
                              ).withValues(alpha: .25),
                              const Color.fromARGB(
                                153,
                                0,
                                0,
                                0,
                              ).withValues(alpha: .92),
                            ],
                            stops: const [0.0, .55, .78, 1],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: categoryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: categoryGradient.colors.first.withValues(alpha: 
                                .28,
                              ),
                              blurRadius: 10,
                              spreadRadius: -2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            year,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
