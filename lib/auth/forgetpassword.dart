import 'package:bucky_verse/services/auth_services.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
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

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: GoogleFonts.rajdhani(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: const Color(0xff14111D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            ScaleOnPress(
              onTap: () async {
                if (loading) return;
                if (emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email.")),
                  );
                  return;
                }

                setState(() => loading = true);

                try {
                  await _auth.resetPassword(emailController.text.trim()).timeout(
                    const Duration(seconds: 10),
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password reset email sent! Check your inbox.",
                      ),
                    ),
                  );

                  Navigator.pop(context);
                } on FirebaseAuthException catch (e) {
                  debugPrint("FirebaseAuthException during password reset: ${e.code} - ${e.message}");
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? "Something went wrong."),
                    ),
                  );
                } catch (e) {
                  debugPrint("Error during password reset: $e");
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to send password reset email: $e"),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xff9B2CFF), Color(0xff009DFF)],
                  ),
                ),
                child: Center(
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
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
          ],
        ),
      ),
    );
  }
}
