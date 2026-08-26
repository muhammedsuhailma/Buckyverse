import 'package:flutter/material.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;

  const ShimmerWidget({super.key, required this.child});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
              colors: const [
                Color(0xFF14111D),
                Color(0xFF25212F),
                Color(0xFF14111D),
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
