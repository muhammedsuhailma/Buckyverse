import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class BucketShimmer extends StatelessWidget {
  const BucketShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .05,
        vertical: size.height * .02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          const ShimmerBox(width: 180, height: 28),

          SizedBox(height: size.height * .03),

          /// Stats
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: const ShimmerBox(
                    width: double.infinity,
                    height: 90,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * .025),

          /// Search
          const ShimmerBox(width: double.infinity, height: 55),

          SizedBox(height: size.height * .02),

          /// Filter Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const ShimmerBox(
                width: 90,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),

          SizedBox(height: size.height * .03),

          /// Bucket Cards
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: const ShimmerBox(
                width: double.infinity,
                height: 130,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
