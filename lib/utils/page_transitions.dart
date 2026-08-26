import 'package:flutter/material.dart';

/// A route transition that fades in the next screen.
/// Ideal for bottom tab transitions.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}

/// A route transition that fades and slides up the next screen slightly.
/// Ideal for detail pages.
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideFadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.04), // slight 4% slide-up
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}

/// A helper widget that shrinks the child slightly on press.
class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ScaleOnPress({super.key, required this.child, this.onTap});

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// A high-performance, package-free skeleton shimmer widget.
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shape;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 12,
    this.shape,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.shape != null
                ? null
                : BorderRadius.circular(widget.borderRadius),
            shape: widget.shape is CircleBorder
                ? BoxShape.circle
                : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1.0, -0.3),
              end: Alignment(_animation.value + 1.0, 0.3),
              colors: const [
                Color(0xFF120D1A),
                Color(0xFF221733),
                Color(0xFF120D1A),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animates value counts from their previous values to their new values.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          val.toInt().toString(),
          style: style,
        );
      },
    );
  }
}

/// Animates child widget with staggered fade-in and slide-up animations.
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double slideOffset;

  const FadeInSlide({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 280),
    this.slideOffset = 16.0,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Stagger based on index, up to a maximum delay of 300ms to keep animations fast
    final int delayMs = (widget.index * 35).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
