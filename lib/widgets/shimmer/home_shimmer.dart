import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * .05,
          vertical: size.height * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                const ShimmerBox.circle(size: 55),

                const Spacer(),

                const ShimmerBox.circle(size: 42),
              ],
            ),

            SizedBox(height: size.height * .03),

            /// Greeting
            const ShimmerBox(width: 180, height: 22),

            const SizedBox(height: 10),

            const ShimmerBox(width: 120, height: 16),

            SizedBox(height: size.height * .025),

             const ShimmerBox(width: double.infinity, height: 55),

            SizedBox(height: size.height * .03),

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

            /// Trending Title
            const ShimmerBox(width: 150, height: 20),

            SizedBox(height: size.height * .02),

            /// Trending Cards
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 18),
                itemBuilder: (_, _) {
                  return const ShimmerBox(
                    width: 180,
                    height: 260,
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                  );
                },
              ),
            ),

            SizedBox(height: size.height * .035),

            /// Continue Journey Title
            const ShimmerBox(width: 170, height: 20),

            SizedBox(height: size.height * .02),

            /// Continue Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => SizedBox(height: size.height * .015),
              itemBuilder: (_, _) {
                return const ShimmerBox(
                  width: double.infinity,
                  height: 105,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
