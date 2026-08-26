import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bucky_verse/utils/page_transitions.dart';

enum WatchStatus { planning, watching, completed }

class StatusSelector extends StatelessWidget {
  final WatchStatus selectedStatus;
  final ValueChanged<WatchStatus> onChanged;

  const StatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            title: "Planning",
            iconPath: "assets/images/hour.png",
            color: const Color(0xffA855F7),
            selected: selectedStatus == WatchStatus.planning,
            onTap: () => onChanged(WatchStatus.planning),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _StatusCard(
            title: "Watching",
            iconPath: "assets/images/watching.png",
            color: const Color(0xff3B82F6),
            selected: selectedStatus == WatchStatus.watching,
            onTap: () => onChanged(WatchStatus.watching),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _StatusCard(
            title: "Completed",
            iconPath: "assets/images/complete.png",
            color: const Color(0xff22C55E),
            selected: selectedStatus == WatchStatus.completed,
            onTap: () => onChanged(WatchStatus.completed),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.iconPath,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize;
    double iconLeft;
    double iconTop;

    switch (title) {
      case "Planning":
        iconSize = 45;
        iconLeft = 0;
        iconTop = 3;
        break;

      case "Watching":
        iconSize = 46;
        iconLeft = 0;
        iconTop = 6;
        break;

      case "Completed":
        iconSize = 40;
        iconLeft = 2;
        iconTop = 7;
        break;

      default:
        iconSize = 48;
        iconLeft = 2;
        iconTop = 10;
    }
    return ScaleOnPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? const [Color(0xff241738), Color(0xff181221)]
                : const [Color(0xff17151F), Color(0xff111019)],
          ),
          border: Border.all(
            width: 1.2,
            color: selected ? color : Colors.white.withValues(alpha: .08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: .25),
                    blurRadius: 24,
                    spreadRadius: -8,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Positioned(
              left: iconLeft,
              top: iconTop,
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              left: 46,
              right: 8,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: .72),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 8,
              bottom: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? color.withValues(alpha: .15) : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? color.withValues(alpha: .7)
                        : Colors.white.withValues(alpha: .15),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
