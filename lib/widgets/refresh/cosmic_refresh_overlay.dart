import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium cosmic shake-to-refresh overlay.
/// Shows: violet mist sweep, glowing star particles, radial glow, cosmic message.
/// Duration: 700–900ms.
class CosmicRefreshOverlay extends StatefulWidget {
  const CosmicRefreshOverlay({super.key});

  @override
  State<CosmicRefreshOverlay> createState() => _CosmicRefreshOverlayState();
}

class _CosmicRefreshOverlayState extends State<CosmicRefreshOverlay>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _mistController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _textController;

  late Animation<double> _mistAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _textFade;

  late List<_Sparkle> _sparkles;
  late String _message;

  static const List<String> _messages = [
    "Refreshing your Universe...",
    "Discovering new adventures...",
    "Jumping through the multiverse...",
    "Synchronizing constellations...",
    "Scanning new dimensions...",
    "Loading fresh cosmic energy...",
    "Rebuilding your galaxy...",
  ];

  static const List<String> _rareMessages = [
    "✨ A new universe has awakened...",
    "🌌 Rare cosmic anomaly detected.",
    "⭐ The stars aligned just for you.",
    "🪐 Reality successfully recalibrated.",
  ];

  @override
  void initState() {
    super.initState();

    final rng = Random();

    // 1% rare easter egg chance
    if (rng.nextInt(100) == 0) {
      _message = _rareMessages[rng.nextInt(_rareMessages.length)];
    } else {
      _message = _messages[rng.nextInt(_messages.length)];
    }

    _sparkles = List.generate(
      32,
      (_) => _Sparkle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: rng.nextDouble() * 2.8 + 0.8,
        delay: rng.nextDouble() * 0.5,
        speed: rng.nextDouble() * 0.4 + 0.3,
      ),
    );

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _mistController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _mistAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mistController, curve: Curves.easeOut),
    );

    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _animate();
  }

  Future<void> _animate() async {
    HapticFeedback.lightImpact();

    // Fade in
    await _masterController.animateTo(0.15,
        duration: const Duration(milliseconds: 120));

    // Mist sweep + glow + particles
    _mistController.forward();
    _glowController.forward();
    _particleController.forward();
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    HapticFeedback.selectionClick();
  }

  /// Called externally after refresh completes to fade out.
  Future<void> fadeOut() async {
    HapticFeedback.lightImpact();
    await _masterController.animateTo(1.0,
        duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _masterController.dispose();
    _mistController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  double get _fadeOpacity {
    final t = _masterController.value;
    if (t <= 0.15) return t / 0.15;
    if (t <= 0.7) return 1.0;
    return 1.0 - ((t - 0.7) / 0.3).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterController,
        _mistController,
        _glowController,
        _particleController,
        _textController,
      ]),
      builder: (context, _) {
        return Opacity(
          opacity: _fadeOpacity.clamp(0.0, 1.0),
          child: Container(
            color: Colors.black.withValues(alpha: 0.30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mist sweep (violet gradient sliding from left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _mistAnim.value,
                    child: Container(
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withValues(alpha: 0.22),
                            const Color(0xFF9D00FF).withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Radial purple glow
                CustomPaint(
                  size: size,
                  painter: _RadialGlowPainter(_glowAnim.value, size),
                ),

                // Glowing stars / sparkles
                CustomPaint(
                  size: size,
                  painter: _SparklePainter(
                    _particleController.value,
                    _sparkles,
                    size,
                  ),
                ),

                // Cosmic message text
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing orbit icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFF9D00FF).withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D00FF).withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFB57BFF),
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _message,
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: size.width * 0.052,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Sparkle {
  final double x, y, radius, delay, speed;
  _Sparkle({
    required this.x,
    required this.y,
    required this.radius,
    required this.delay,
    required this.speed,
  });
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_Sparkle> sparkles;
  final Size size;

  _SparklePainter(this.progress, this.sparkles, this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final s in sparkles) {
      final t = ((progress - s.delay) / (1.0 - s.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      // Twinkle animation
      final twinkle = sin(t * pi * s.speed * 3).abs().clamp(0.0, 1.0);
      final opacity = twinkle * (1.0 - t * 0.4);

      paint.color = const Color(0xFFB57BFF).withValues(alpha: opacity.clamp(0, 1));

      canvas.drawCircle(
        Offset(s.x * canvasSize.width, s.y * canvasSize.height),
        s.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}

class _RadialGlowPainter extends CustomPainter {
  final double progress;
  final Size size;

  _RadialGlowPainter(this.progress, this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width * 0.65 * progress;

    if (radius <= 0) return;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withValues(alpha: 0.28 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter old) => old.progress != progress;
}
