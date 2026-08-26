import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium Instagram-style animated bucket button with spring pop & sparkle burst.
class AnimatedBucketButton extends StatefulWidget {
  final bool isAdded;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const AnimatedBucketButton({
    super.key,
    required this.isAdded,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  State<AnimatedBucketButton> createState() => _AnimatedBucketButtonState();
}

class _AnimatedBucketButtonState extends State<AnimatedBucketButton>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _heartScale;
  late Animation<double> _sparkleProgress;

  late AnimationController _pressController;
  late Animation<double> _buttonScale;

  bool _isLocallyAdded = false;
  bool _textShowingAdded = false;

  @override
  void initState() {
    super.initState();
    _isLocallyAdded = widget.isAdded;
    _textShowingAdded = widget.isAdded;

    // Heart spring pop animation (300ms, scale 1.0 -> 1.35 -> 0.92 -> 1.0)
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 38.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.35,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 34.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 28.0,
      ),
    ]).animate(_popController);

    _sparkleProgress = CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOutQuad,
    );

    _popController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _textShowingAdded = true;
          });
        }
      }
    });

    // Tactile button press depth animation
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedBucketButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isAdded != widget.isAdded) {
      _isLocallyAdded = widget.isAdded;
      _textShowingAdded = widget.isAdded;
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (!_isLocallyAdded && !_popController.isAnimating) {
      HapticFeedback.lightImpact();

      setState(() {
        _isLocallyAdded = true;
      });

      _pressController.forward().then((_) {
        if (mounted) _pressController.reverse();
      });

      // Wait for the heart animation to finish
      await _popController.forward(from: 0);

      // Now update Firestore
      widget.onTap?.call();
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIsAdded = widget.isAdded || _isLocallyAdded;
    final effectiveTextAdded = _textShowingAdded;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScale.value,
            child: Container(
              height: widget.height,
              width: widget.width ?? double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Button Background Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/images/add.png", fit: BoxFit.fill),
              ),
            ),

            // Content: Heart Icon + Sparkles + Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heart & Sparkles Container
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Sparkle Burst Custom Painter
                      AnimatedBuilder(
                        animation: _sparkleProgress,
                        builder: (context, _) {
                          if (_popController.isAnimating) {
                            return CustomPaint(
                              size: const Size(56, 56),
                              painter: SparkleBurstPainter(
                                progress: _sparkleProgress.value,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Heart Icon with Scale Pop Transition
                      AnimatedBuilder(
                        animation: _heartScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _popController.isAnimating
                                ? _heartScale.value
                                : 1.0,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          effectiveIsAdded
                              ? "assets/images/added.png"
                              : "assets/images/addtobu.png",
                          key: ValueKey(effectiveIsAdded),
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // Button Label
                SizedBox(
                  width: 124,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      effectiveTextAdded ? "Added" : "Add to Bucket",
                      key: ValueKey(effectiveTextAdded),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle configuration for radial sparkle burst.
class _SparkleParticle {
  final double angle; // In radians
  final double distance; // Target max distance in pixels
  final double size; // Max radius / star radius
  final Color color;
  final bool isStar;

  const _SparkleParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.isStar,
  });
}

/// CustomPainter rendering 8 delicate sci-fi sparkles in purple/pink/white palette.
class SparkleBurstPainter extends CustomPainter {
  final double progress;

  static final List<_SparkleParticle> _particles = [
    const _SparkleParticle(
      angle: -math.pi / 2, // Top
      distance: 28.0,
      size: 3.5,
      color: Color(0xFFFFFFFF), // White star
      isStar: true,
    ),
    const _SparkleParticle(
      angle: -math.pi / 4, // Top-Right
      distance: 26.0,
      size: 2.8,
      color: Color(0xFFC084FC), // Light purple
      isStar: false,
    ),
    const _SparkleParticle(
      angle: 0.0, // Right
      distance: 30.0,
      size: 3.2,
      color: Color(0xFFEC4899), // Pink star
      isStar: true,
    ),
    const _SparkleParticle(
      angle: math.pi / 4, // Bottom-Right
      distance: 25.0,
      size: 2.4,
      color: Color(0xFFE879F9), // Fuchsia dot
      isStar: false,
    ),
    const _SparkleParticle(
      angle: math.pi / 2, // Bottom
      distance: 27.0,
      size: 3.2,
      color: Color(0xFFA855F7), // Purple star
      isStar: true,
    ),
    const _SparkleParticle(
      angle: 3 * math.pi / 4, // Bottom-Left
      distance: 25.0,
      size: 2.5,
      color: Color(0xFFFFFFFF), // White dot
      isStar: false,
    ),
    const _SparkleParticle(
      angle: math.pi, // Left
      distance: 29.0,
      size: 3.4,
      color: Color(0xFFFF4D6D), // Bright pink star
      isStar: true,
    ),
    const _SparkleParticle(
      angle: -3 * math.pi / 4, // Top-Left
      distance: 26.0,
      size: 2.8,
      color: Color(0xFFDDD6FE), // Lavender dot
      isStar: false,
    ),
  ];

  SparkleBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Eased motion outward
    final double moveEase = Curves.easeOutCubic.transform(progress);

    // Opacity: quick fade in (0 -> 0.15), smooth fade out (0.15 -> 1.0)
    final double opacity;
    if (progress < 0.15) {
      opacity = progress / 0.15;
    } else {
      opacity = (1.0 - progress) / 0.85;
    }

    final double clampedOpacity = opacity.clamp(0.0, 1.0);

    // Scale curve: pop in, peak around 0.35, then gently shrink
    final double scale;
    if (progress < 0.35) {
      scale = (progress / 0.35).clamp(0.0, 1.0);
    } else {
      scale = ((1.0 - progress) / 0.65).clamp(0.0, 1.0);
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final particle in _particles) {
      final double dist = lerpDouble(10.0, particle.distance, moveEase)!;
      final double x = center.dx + math.cos(particle.angle) * dist;
      final double y = center.dy + math.sin(particle.angle) * dist;
      final particlePos = Offset(x, y);

      final currentSize = particle.size * scale;
      if (currentSize <= 0.2) continue;

      paint.color = particle.color.withValues(
        alpha: clampedOpacity * (particle.color.a),
      );

      if (particle.isStar) {
        _draw4PointStar(canvas, particlePos, currentSize, paint);
      } else {
        canvas.drawCircle(particlePos, currentSize * 0.85, paint);
      }
    }
  }

  /// Draws a 4-pointed sparkle star with soft concave arcs.
  void _draw4PointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    final double crossR = radius * 1.15;
    final double innerR = radius * 0.22;

    path.moveTo(center.dx, center.dy - crossR);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + crossR, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + crossR);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - crossR, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - crossR);
    path.close();

    // Central micro glow point
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, innerR, paint);
  }

  @override
  bool shouldRepaint(covariant SparkleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
