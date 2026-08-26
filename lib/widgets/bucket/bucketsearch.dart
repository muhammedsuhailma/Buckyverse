import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BucketSearch extends StatelessWidget {
  const BucketSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * .05),
      child: SingleChildScrollView(
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF17111F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                context.read<BucketProvider>().changeSearch(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8B5CF6),
                ),
                hintText: "Search your bucket...",
                hintStyle: GoogleFonts.rajdhani(
                  color: Colors.white38,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
