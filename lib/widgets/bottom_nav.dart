import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuckyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BuckyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xff05030E).withValues(alpha: .96),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: .08), width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 4,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: "assets/icons/home.png",
                    label: "Home",
                    selected: currentIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  _NavItem(
                    icon: "assets/icons/explorer.png",
                    label: "Explore",
                    selected: currentIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                  _NavItem(
                    icon: "assets/icons/bucket.png",
                    label: "Bucket",
                    selected: currentIndex == 2,
                    onTap: () => onChanged(2),
                  ),
                  _NavItem(
                    icon: "assets/icons/profile.png",
                    label: "Profile",
                    selected: currentIndex == 3,
                    onTap: () => onChanged(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const active = Color(0xffA855F7);
    const inactive = Color(0xff6E6792);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              scale: selected ? 1.08 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xffA855F7).withValues(alpha: .10)
                      : Colors.transparent,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xffA855F7).withValues(alpha: .22),
                            blurRadius: 14,
                            spreadRadius: -3,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Image.asset(
                  icon,
                  width: 27,
                  height: 27,
                  color: selected ? active : inactive,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: GoogleFonts.rajdhani(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selected ? active : inactive,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
