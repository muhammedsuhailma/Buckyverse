import 'package:flutter/material.dart';

class MediaImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MediaImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade900,
        child: const Icon(
          Icons.broken_image,
          color: Colors.white54,
        ),
      );
    }

    if (image.startsWith("http://") || image.startsWith("https://")) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade900,
            child: const Icon(
              Icons.broken_image,
              color: Colors.white54,
            ),
          );
        },
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade900,
          child: const Icon(
            Icons.broken_image,
            color: Colors.white54,
          ),
        );
      },
    );
  }
}