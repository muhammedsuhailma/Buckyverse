import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';

/// Cosmic connection-restored overlay.
/// Shown for ~600ms when internet is regained, then fades out automatically.
class ConnectionRestoredOverlay extends StatefulWidget {
  const ConnectionRestoredOverlay({super.key});

  @override
  State<ConnectionRestoredOverlay> createState() =>
      _ConnectionRestoredOverlayState();
}

class _ConnectionRestoredOverlayState extends State<ConnectionRestoredOverlay>
    with TickerProviderStateMixin {
  // Master fade: fades the whole overlay in then out
  late AnimationController _masterFade;
  // Wave sweep
  late AnimationController _waveController;
  // Glow expand
  late AnimationController _glowController;
  // Particle sparkle
  late AnimationController _particleController;

  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;
  late Animation<double> _waveAnim;
  late Animation<double> _glowAnim;

  late List<_Particle> _particles;

  bool _done = false;

  @override
  void initState() {
    super.initState();

    final rng = Random();
    _particles = List.generate(
      24,
      (_) => _Particle(
        angle: rng.nextDouble() * 2 * pi,
        distance: rng.nextDouble() * 0.35 + 0.05,
        radius: rng.nextDouble() * 2.5 + 1.0,
        delay: rng.nextDouble() * 0.4,
      ),
    );

    _masterFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterFade,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _masterFade,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _waveAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    HapticFeedback.lightImpact();

    // Fade in overlay
    await _masterFade.animateTo(0.3);

    // Wave, glow, particles in parallel
    _waveController.forward();
    _glowController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    HapticFeedback.lightImpact();

    // Hold for a moment
    await Future.delayed(const Duration(milliseconds: 400));

    // Fade out
    await _masterFade.animateTo(1.0);

    if (mounted && !_done) {
      _done = true;
      context.read<NetworkProvider>().onRestoredAnimationComplete();
    }
  }

  @override
  void dispose() {
    _masterFade.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  double get _opacity {
    final t = _masterFade.value;
    if (t <= 0.3) return _fadeIn.value;
    if (t <= 0.7) return 1.0;
    return _fadeOut.value;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterFade,
        _waveController,
        _glowController,
        _particleController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.clamp(0.0, 1.0),
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withValues(alpha: 0.82),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding radial glow
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GlowPainter(_glowAnim.value),
                  ),
                ),

                // Wave sweep
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _waveAnim.value,
                    child: Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withValues(alpha: 0.18),
                            const Color(0xFF9D00FF).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Glowing particles
                CustomPaint(
                  size: size,
                  painter: _ParticlePainter(
                    _particleController.value,
                    _particles,
                    Offset(size.width / 2, size.height / 2),
                    size.width * 0.3,
                  ),
                ),

                // Text content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing checkmark icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                        border: Border.all(
                          color: const Color(0xFF9D00FF).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9D00FF).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wifi_rounded,
                        color: Color(0xFF9D00FF),
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      "Connection Restored",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Welcome back to your universe.",
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFF9D00FF),
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle, distance, radius, delay;
  _Particle({
    required this.angle,
    required this.distance,
    required this.radius,
    required this.delay,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final Offset center;
  final double maxRadius;

  _ParticlePainter(this.progress, this.particles, this.center, this.maxRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final t = ((progress - p.delay) / (1.0 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final r = maxRadius * p.distance * t;
      final dx = center.dx + r * cos(p.angle);
      final dy = center.dy + r * sin(p.angle);
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      paint.color = const Color(0xFFB57BFF).withValues(alpha: opacity * 0.9);
      canvas.drawCircle(Offset(dx, dy), p.radius * (1 - t * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _GlowPainter extends CustomPainter {
  final double progress;
  _GlowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.6 * progress;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withValues(alpha: 0.25 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.progress != progress;
}
