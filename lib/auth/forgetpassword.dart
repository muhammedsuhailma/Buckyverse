import 'dart:async';
import 'dart:io';

import 'package:bucky_verse/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _auth = AuthService();

  bool loading = false;
  bool _isPressed = false;

  // Valid email regex
  static final _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    // Guard against multiple taps
    if (loading) return;

    final email = emailController.text.trim();

    // ── Validation ──────────────────────────────────────────────────────────
    if (email.isEmpty) {
      _showSnackBar("Please enter your email address.");
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      _showSnackBar("Please enter a valid email address.");
      return;
    }

    setState(() => loading = true);

    try {
      debugPrint("ForgotPassword: sending reset email to $email");

      await _auth
          .resetPassword(email)
          .timeout(const Duration(seconds: 10));

      debugPrint("ForgotPassword: reset email sent successfully.");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 5500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF14111D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xff9B2CFF),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff9B2CFF).withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.mark_email_read_rounded,
                  color: Color(0xFF22A45D),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Reset Link Sent 🚀",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Password reset email sent.\n\nIf you don't receive it within a few minutes, please check your Spam or Junk folder.",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Give the user ~800 ms to start reading before navigating away
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      debugPrint(
        "ForgotPassword FirebaseAuthException: ${e.code} – ${e.message}",
      );
      if (!mounted) return;

      final String message;
      switch (e.code) {
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        case 'user-not-found':
          // May not be thrown when email enumeration protection is on,
          // but handle it if Firebase does return it.
          message = "No account found with this email.";
          break;
        case 'too-many-requests':
          message = "Too many requests. Please try again later.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your connection.";
          break;
        default:
          message = e.message ?? "Something went wrong. Please try again.";
      }

      _showSnackBar(message);

    } on TimeoutException {
      debugPrint("ForgotPassword: request timed out.");
      if (!mounted) return;
      _showSnackBar("Request timed out. Please try again.");

    } on SocketException {
      debugPrint("ForgotPassword: no internet connection.");
      if (!mounted) return;
      _showSnackBar("Network error. Please check your connection.");

    } catch (e) {
      debugPrint("ForgotPassword unexpected error: $e");
      if (!mounted) return;
      _showSnackBar("Something went wrong. Please try again.");

    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.rajdhani(fontSize: 15),
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF1A6B3C)
            : const Color(0xFF1E1B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Text(
              "Forgot Password",
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Enter your registered email address and we'll send you a password reset link.",
              style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 16),
            ),

            const SizedBox(height: 40),

            Text(
              "Email Address",
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 17),
              onSubmitted: (_) => _sendResetLink(),
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: GoogleFonts.rajdhani(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xff8B35FF),
                ),
                filled: true,
                fillColor: const Color(0xff14111D),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xff7435FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xff009DFF)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ─── Send Reset Link Button ───────────────────────────────────
            // NOTE: Using GestureDetector instead of ScaleOnPress here because
            // ScaleOnPress.onTap is typed as VoidCallback (not Future<void>),
            // which causes async handlers to be fire-and-forgotten, silently
            // swallowing exceptions and preventing UI state updates.
            GestureDetector(
              onTap: _sendResetLink,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Container(
                  height: 58,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xff9B2CFF), Color(0xff009DFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff8B35FF).withValues(alpha: .45),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Send Reset Link",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
