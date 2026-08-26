import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MediaBucketCard extends StatefulWidget {
  final String title;
  final String image;
  final String type;
  final String rating;
  final String year;
  final double progress;
  final Color accentColor;
  final String status;
  final VoidCallback? onTap;

  const MediaBucketCard({
    super.key,
    required this.title,
    required this.image,
    required this.type,
    required this.rating,
    required this.year,
    required this.progress,
    required this.accentColor,
    required this.status,
    this.onTap,
  });
  @override
  State<MediaBucketCard> createState() => _MediaBucketCardState();
}

class _MediaBucketCardState extends State<MediaBucketCard> {
  bool isPressed = false;

  LinearGradient getGenreGradient() {
    switch (widget.type) {
      case "Anime":
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff7C3AED), Color(0xff3B0764)],
        );

      case "Movie":
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

  Widget getgenretext() {
    final type = widget.type.toUpperCase();

    if (type.contains("ANIME")) {
      return const Text("⚡");
    }

    if (type.contains("MOVIE")) {
      return const Text("🎬");
    }

    if (type.contains("SERIES")) {
      return const Text("📺");
    }

    if (type.contains("DRAMA")) {
      return const Text("🌸");
    }

    return const Text("🌌");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onTap,

      onTapDown: (_) {
        setState(() => isPressed = true);
      },

      onTapUp: (_) {
        setState(() => isPressed = false);
      },

      onTapCancel: () {
        setState(() => isPressed = false);
      },

      child: AnimatedScale(
        scale: isPressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(
            horizontal: size.width * .05,
            vertical: size.height * .012,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 23, 2, 30),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: .18),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: size.height * .115,
            child: Row(
              children: [
                Hero(
                  tag: widget.title,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MediaImage(
                      image: widget.image,
                      width: size.width * .16,
                      height: size.height * .115,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: getGenreGradient(),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: getGenreGradient().colors.first
                                  .withValues(alpha: .28),
                              blurRadius: 10,
                              spreadRadius: -2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getgenretext(),

                            const SizedBox(width: 4),
                            const SizedBox(width: 5),

                            Text(
                              widget.type,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: size.width * .045,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            widget.rating,
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF8B5CF6),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "•",
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF8B5CF6),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            widget.year,
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFF8B5CF6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Colors.white.withValues(alpha: .45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
