import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

class CategoryCapsule extends StatelessWidget {
  final String title;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  final Gradient gradient;

  const CategoryCapsule({
    super.key,
    required this.title,
    required this.emoji,
    required this.selected,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: selected ? gradient : null,
          color: selected ? null : const Color(0xff1A1626),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xff302447),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xff9E9AAE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
