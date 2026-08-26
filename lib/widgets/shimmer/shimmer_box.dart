import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

class ShimmerBox extends StatelessWidget {
  
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    
    this.shape = BoxShape.rectangle,
  });

  const ShimmerBox.circle({super.key, required double size})
    : width = size,
      height = size,
      shape = BoxShape.circle,
      borderRadius = null;
  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1D1827),
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? borderRadius ?? BorderRadius.circular(14)
              : null,
        ),
      ),
    );
  }
}
