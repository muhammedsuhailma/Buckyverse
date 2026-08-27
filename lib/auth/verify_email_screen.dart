import 'dart:async';
import 'dart:io';

import 'package:bucky_verse/auth/loginpage.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _isResending = false;
  bool _isVerifying = false;
  bool _resendDisabled = false;

  // Countdown starts at 60 s (spam prevention)
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── SnackBar helpers ───────────────────────────────────────────────────────

  /// Simple error / neutral snack bar (dark cosmic style).
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF14111D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSuccess
                    ? const Color(0xFF22A45D)
                    : const Color(0xff9B2CFF),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess
                          ? const Color(0xFF22A45D)
                          : const Color(0xff9B2CFF))
                      .withValues(alpha: 0.22),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  color: isSuccess
                      ? const Color(0xFF22A45D)
                      : const Color(0xff9B2CFF),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // ── Countdown ──────────────────────────────────────────────────────────────

  /// Starts a 60-second countdown that disables the Resend button.
  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _resendDisabled = true;
      _countdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        if (mounted) setState(() => _resendDisabled = false);
      }
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _resendEmail() async {
    if (_isResending || _isVerifying || _resendDisabled) return;
    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // After signup the user is intentionally signed out, so currentUser
      // may be null here. This is NOT a session error — we simply cannot
      // resend without an active session. Direct the user to log in.
      if (user == null) {
        debugPrint("VerifyEmail resend: no active session — user must log in.");
        if (!mounted) return;
        _showSnackBar(
          "Please log in first to resend the verification email.",
        );
        return;
      }

      debugPrint("VerifyEmail: resending verification to ${user.email}");
      await user
          .sendEmailVerification()
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      _showSnackBar(
        "Verification email sent again.\nPlease check your Inbox or Spam folder.",
        isSuccess: true,
      );
      _startCountdown();
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "VerifyEmail resend FirebaseAuthException: ${e.code} – ${e.message}",
      );
      if (!mounted) return;

      final String message;
      switch (e.code) {
        case 'too-many-requests':
          message = "Too many requests. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your connection.";
          break;
        default:
          message = e.message ?? "Failed to send email. Please try again.";
      }
      _showSnackBar(message);
    } on TimeoutException {
      debugPrint("VerifyEmail resend: request timed out.");
      if (!mounted) return;
      _showSnackBar("Request timed out. Please try again.");
    } on SocketException {
      debugPrint("VerifyEmail resend: no internet connection.");
      if (!mounted) return;
      _showSnackBar("Network error. Please check your connection.");
    } catch (e) {
      debugPrint("VerifyEmail resend unexpected error: $e");
      if (!mounted) return;
      _showSnackBar("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    if (_isResending || _isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // If no session exists (user was signed out after signup and hasn't
      // logged back in), we cannot perform a server-side reload. Guide them
      // to log in — Firebase will enforce the emailVerified check there.
      if (user == null) {
        debugPrint(
          "VerifyEmail check: no active session — directing user to login.",
        );
        if (!mounted) return;
        _showSnackBar(
          "Please log in. Your verification status will be checked automatically.",
        );
        return;
      }

      debugPrint("VerifyEmail: reloading user ${user.email}");
      await user.reload().timeout(const Duration(seconds: 10));

      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed == null) {
        // Truly unexpected — Firebase evicted the session mid-reload.
        if (!mounted) return;
        _showSnackBar(
          "Your session has expired. Please log in again.",
        );
        return;
      }

      if (refreshed.emailVerified) {
        // Sign out so the user follows the normal login flow.
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;
        _showSnackBar(
          "Email verified successfully.\nYou can now sign in.",
          isSuccess: true,
        );

        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(child: const LoginScreen()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        _showSnackBar(
          "Your email is not verified yet.\nPlease click the verification link first.",
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "VerifyEmail check FirebaseAuthException: ${e.code} – ${e.message}",
      );
      if (!mounted) return;
      _showSnackBar(
        e.message ?? "Verification check failed. Please try again.",
      );
    } on TimeoutException {
      debugPrint("VerifyEmail check: request timed out.");
      if (!mounted) return;
      _showSnackBar("Request timed out. Please try again.");
    } on SocketException {
      debugPrint("VerifyEmail check: no internet.");
      if (!mounted) return;
      _showSnackBar("Network error. Please check your connection.");
    } catch (e) {
      debugPrint("VerifyEmail check unexpected error: $e");
      if (!mounted) return;
      _showSnackBar("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _backToLogin() async {
    // Silently sign out — may already be signed out after signup, ignore errors.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      FadePageRoute(child: const LoginScreen()),
      (route) => false,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: _backToLogin,
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // ── Cosmic icon ──────────────────────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff9B2CFF), Color(0xff009DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff8B35FF).withValues(alpha: 0.45),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Title ────────────────────────────────────────────────────────
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xffB75CFF), Color(0xff33B5FF)],
              ).createShader(bounds),
              child: Text(
                "Verify Your Universe",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Subtitle ─────────────────────────────────────────────────────
            Text(
              "We've sent a verification email to",
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Please verify your email before entering BuckyVerse.",
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Check your Spam/Junk folder if you don't see it.",
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            // ── Resend Button ─────────────────────────────────────────────────
            _CosmicButton(
              label: _resendDisabled
                  ? "Resend available in ${_countdown}s"
                  : "📩  Resend Verification Email",
              isLoading: _isResending,
              isDisabled: _resendDisabled || _isVerifying,
              gradient: const LinearGradient(
                colors: [Color(0xff9B2CFF), Color(0xff009DFF)],
              ),
              onTap: _resendEmail,
            ),

            const SizedBox(height: 16),

            // ── I've Verified Button ──────────────────────────────────────────
            _CosmicButton(
              label: "✅  I've Verified",
              isLoading: _isVerifying,
              isDisabled: _isResending,
              gradient: const LinearGradient(
                colors: [Color(0xff1A6B3C), Color(0xff22A45D)],
              ),
              onTap: _checkVerification,
            ),

            const SizedBox(height: 20),

            // ── Back to Login ─────────────────────────────────────────────────
            GestureDetector(
              onTap: _backToLogin,
              child: Text(
                "⬅  Back to Login",
                style: GoogleFonts.rajdhani(
                  color: const Color(0xff9B2CFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xff9B2CFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable cosmic-themed button ─────────────────────────────────────────────

class _CosmicButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _CosmicButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_CosmicButton> createState() => _CosmicButtonState();
}

class _CosmicButtonState extends State<_CosmicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool inactive = widget.isDisabled || widget.isLoading;

    return GestureDetector(
      onTap: inactive ? null : widget.onTap,
      onTapDown: inactive ? null : (_) => setState(() => _pressed = true),
      onTapUp: inactive ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: inactive ? 0.55 : 1.0,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: widget.gradient,
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.38),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
