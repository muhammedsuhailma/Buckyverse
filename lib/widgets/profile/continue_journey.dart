import 'package:bucky_verse/features/explorer/presentation/screens/explorer_details.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/widgets/media_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContinueJourney extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const ContinueJourney({super.key, this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<BucketProvider>();

    final items = provider.bucketItems.reversed.take(3).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * .04,
        size.height * .035,
        size.width * .04,
        size.height * .025,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFFA855F7),
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                "Continue Your Journey",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              ScaleOnPress(
                onTap: () {
                  onSeeAll?.call();
                },
                child: Row(
                  children: [
                    Text(
                      "See All",
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFA855F7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFA855F7),
                      size: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .02),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final bucketItem = entry.value;
            final item = bucketItem.data;

            return FadeInSlide(
              index: index,
              child: ScaleOnPress(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideFadePageRoute(
                      child: ExplorerDetailsScreen(item: item),
                    ),
                  );
                },
                child: Container(
                  height: size.height * .14,
                  margin: EdgeInsets.only(bottom: size.height * .015),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11101A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: .06)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: MediaImage(
                          image: (item["image"] ?? "").toString(),
                          width: size.width * .21,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: size.width * .035),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item["title"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: size.width * .045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                item["type"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Icon(
                                    _statusIcon(bucketItem.status),
                                    color: _statusColor(bucketItem.status),
                                    size: 16,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    bucketItem.status,
                                    style: GoogleFonts.rajdhani(
                                      color: _statusColor(bucketItem.status),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            bucketItem.status,
                          ).withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bucketItem.status,
                          style: GoogleFonts.rajdhani(
                            color: _statusColor(bucketItem.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white38,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Watching":
        return const Color(0xFF38BDF8);

      case "Completed":
        return const Color(0xFF22C55E);

      case "Planning":
        return const Color(0xFFA855F7);

      default:
        return Colors.white;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Watching":
        return Icons.play_circle_fill_rounded;

      case "Completed":
        return Icons.check_circle_rounded;

      case "Planning":
        return Icons.schedule_rounded;

      default:
        return Icons.circle_outlined;
    }
  }
}
