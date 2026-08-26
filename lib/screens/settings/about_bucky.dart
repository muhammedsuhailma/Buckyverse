import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutBuckyVerseScreen extends StatelessWidget {
  const AboutBuckyVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About BuckyVerse",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            size.width * .05,
            size.height * .025,
            size.width * .05,
            size.height * .04,
          ),
          child: Column(
            children: [
              // Logo
              Container(
                width: size.width * .28,
                height: size.width * .28,
                padding: EdgeInsets.all(size.width * .045),
                decoration: BoxDecoration(
                  color: const Color(0xFF14111D),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFA855F7).withValues(alpha: .25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: .18),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/images/buckyverseicon.png",
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * .028),
              Text(
                "BUCKYVERSE",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "One universe. Infinite stories.",
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFA855F7),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: size.height * .035),
              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF14111D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: Column(
                  children: [
                    Text(
                      "ABOUT",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "BuckyVerse brings anime, movies, series and "
                      "K-Drama into one personal entertainment universe.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * .022),
              // Universes
              Row(
                children: [
                  Expanded(
                    child: _universeChip(
                      context: context,
                      icon: "⚡",
                      title: "Anime",
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _universeChip(
                      context: context,
                      icon: "🎬",
                      title: "Movies",
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * .012),
              Row(
                children: [
                  Expanded(
                    child: _universeChip(
                      context: context,
                      icon: "📺",
                      title: "Series",
                      color: const Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _universeChip(
                      context: context,
                      icon: "🌸",
                      title: "K-Drama",
                      color: const Color(0xFFDB2777),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * .035),
              Text(
                "Version 1.0.0",
                style: GoogleFonts.rajdhani(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Made with Flutter",
                style: GoogleFonts.rajdhani(
                  color: Colors.white24,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _universeChip({
    required String icon,
    required String title,
    required Color color,
    required BuildContext context,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height * .018,
        horizontal: size.width * .03,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 19)),

          SizedBox(width: size.width * .02),
          Text(
            title,
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
