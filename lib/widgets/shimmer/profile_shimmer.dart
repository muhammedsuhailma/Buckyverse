 import 'package:bucky_verse/widgets/shimmer/shimmer_box.dart';
import 'package:flutter/material.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Profile Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14111D),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                ShimmerBox(
                  width: 90,
                  height: 90,
                  borderRadius: BorderRadius.circular(45),
                ),

                const SizedBox(height: 18),

                ShimmerBox(
                  width: 150,
                  height: 20,
                  borderRadius: BorderRadius.circular(8),
                ),

                const SizedBox(height: 10),

                ShimmerBox(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Journey Stats
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerBox(
                    height: 105,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Continue Journey Cards
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ShimmerBox(
                width: double.infinity,
                height: 112,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}