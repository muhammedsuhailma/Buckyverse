import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class ExploreShimmer extends StatelessWidget {
  const ExploreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .05,
        vertical: size.height * .02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search Bar
          const ShimmerBox(width: double.infinity, height: 55),

          SizedBox(height: size.height * .025),

          /// Category Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) {
                return const ShimmerBox(
                  width: 90,
                  height: 42,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                );
              },
            ),
          ),

          SizedBox(height: size.height * .03),

          /// Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 18,
              childAspectRatio: .65,
            ),
            itemBuilder: (_, _) {
              return const ShimmerBox(
                width: double.infinity,
                height: 220,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              );
            },
          ),
        ],
      ),
    );
  }
}
