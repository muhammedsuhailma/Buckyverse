import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BucketHeader extends StatelessWidget {
  const BucketHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * .05,
        right: size.width * .05,
        top: MediaQuery.of(context).padding.top + 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "MY",
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: size.width * .075,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                "BUCKYVERSE",
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFA855F7),
                  fontSize: size.width * .075,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            "Your personal entertainment universe",
            style: GoogleFonts.rajdhani(
              color: const Color(0xFF8B5CF6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
