import 'dart:math';
import 'package:bucky_verse/services/discovery_service.dart';
import 'package:bucky_verse/widgets/discovery/discovery_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';

/// Beautiful offline state matching the BuckyVerse cosmic visual identity.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Show offline tip once — DiscoveryTip self-dismisses via its own
    // BuildContext, so no caller-context reference is ever held.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final should = await DiscoveryService.instance.shouldShowOfflineTip();
      if (!mounted || !should) return;
      await DiscoveryService.instance.markOfflineSeen();
      if (!mounted) return;
      DiscoveryTip.show(
        context,
        emoji: '📡',
        title: 'You\'re Offline',
        body: 'No worries — we\'ll reconnect automatically once you\'re back online.',
      );
    });

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final network = context.watch<NetworkProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        children: [
          // Background radial glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [Color(0xFF1A0533), Color(0xFF050510)],
                ),
              ),
            ),
          ),

          // Floating stars background
          const Positioned.fill(child: _StarField()),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cosmic Wi-Fi Off icon with glow and float
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_floatAnimation, _glowAnimation]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Container(
                        width: size.width * 0.38,
                        height: size.width * 0.38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D00FF)
                                  .withValues(alpha: _glowAnimation.value * 0.5),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: size.width * 0.38,
                              height: size.width * 0.38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF9D00FF)
                                      .withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Icon
                            Icon(
                              Icons.wifi_off_rounded,
                              size: size.width * 0.2,
                              color: const Color(0xFF9D00FF),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.05),

                // Title
                Text(
                  "You're Offline",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: size.width * 0.075,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Text(
                    "Looks like your connection drifted\ninto another universe.",
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF6B5B9E),
                      fontSize: size.width * 0.042,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: size.height * 0.06),

                // Retry button
                _RetryButton(isRetrying: network.isRetrying),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final bool isRetrying;
  const _RetryButton({required this.isRetrying});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _scaleController.reverse();
    await _scaleController.forward();
    HapticFeedback.selectionClick();
    if (mounted) {
      context.read<NetworkProvider>().retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRetrying ? null : _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9D00FF)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9D00FF).withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isRetrying)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              const SizedBox(width: 10),
              Text(
                widget.isRetrying ? "Checking..." : "Retry",
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight star field rendered with Canvas for performance.
class _StarField extends StatefulWidget {
  const _StarField();

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _stars = List.generate(
      60,
      (_) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 1.8 + 0.4,
        speed: rng.nextDouble() * 0.3 + 0.05,
        phase: rng.nextDouble() * 2 * pi,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
      builder: (_, _) => CustomPaint(
        painter: _StarPainter(_stars, _controller.value),
      ),
    );
  }
}

class _Star {
  final double x, y, radius, speed, phase;
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;

  _StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final opacity =
          (0.3 + 0.7 * sin(star.phase + progress * 2 * pi * star.speed))
              .clamp(0.1, 1.0);
      paint.color = const Color(0xFFB57BFF).withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.progress != progress;
}
