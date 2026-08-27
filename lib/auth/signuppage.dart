import 'package:bucky_verse/auth/verify_email_screen.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/screens/mainscreen.dart';
import 'package:bucky_verse/screens/termsandcondition.dart';
import 'package:bucky_verse/services/auth_services.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool agree = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  Future<void> openTerms() async {
    final result = await Navigator.push(
      context,
      SlideFadePageRoute(child: const TermsScreen()),
    );

    if (result == true) {
      setState(() {
        agree = true;
      });
    }
  }

  final AuthService _auth = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff02030F),

      body: Stack(
        children: [
          // ───────────────── BACKGROUND ─────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/logi.png",
              height: size.height * 0.50,
              fit: BoxFit.cover,
            ),
          ),

          // ───────────────── DARK GRADIENT ─────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.25, 0.48, 0.70],
                  colors: [
                    Colors.transparent,
                    const Color(0xff02030F).withValues(alpha: 0.65),
                    const Color(0xff02030F),
                  ],
                ),
              ),
            ),
          ),

          // ───────────────── BACK BUTTON ─────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: size.width * 0.02,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // ───────────────── CONTENT ─────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.38),
                    // ───────────────── BRAND ─────────────────
                    Center(
                      child: Column(
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xffB75CFF), Color(0xff33B5FF)],
                              ).createShader(bounds);
                            },
                            child: Text(
                              "Create your account",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // ───────────── BUCKYVERSE LOGO ─────────────
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Bucky",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: size.width * 0.14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xff9B2CFF),
                                        Color(0xff009DFF),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    "Verse",
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontSize: 55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "One Universe. Infinite Stories.",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ───────────────── FULL NAME ─────────────────
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: inputStyle(
                        "Full Name",
                        Icons.person_2_outlined,
                        null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ───────────────── EMAIL ─────────────────
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: inputStyle(
                        "Email Address",
                        Icons.email_outlined,
                        null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ───────────────── PASSWORD ─────────────────
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: inputStyle(
                        "Password",
                        Icons.lock_outline,
                        IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ───────────────── CONFIRM PASSWORD ─────────────────
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: hideConfirmPassword,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: inputStyle(
                        "Confirm Password",
                        Icons.lock_outline,
                        IconButton(
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            hideConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ───────────────── TERMS ─────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.05,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: const CheckboxThemeData(
                                shape: CircleBorder(),
                              ),
                            ),
                            child: Checkbox(
                              value: agree,
                              activeColor: const Color(0xff9B2CFF),
                              checkColor: Colors.white,
                              onChanged: (_) {
                                if (!agree) {
                                  openTerms();
                                } else {
                                  setState(() {
                                    agree = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                                children: const [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                      color: Color(0xff9B2CFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      color: Color(0xff9B2CFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ───────────────── CREATE ACCOUNT ─────────────────
                    ScaleOnPress(
                      onTap: () async {
                        if (isLoading || isGoogleLoading) return;
                        if (!agree) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please accept the Terms & Privacy Policy",
                              ),
                            ),
                          );
                          return;
                        }

                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all required fields"),
                            ),
                          );
                          return;
                        }

                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match"),
                            ),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          final credential = await _auth.signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          // Send verification email before signing out
                          try {
                            await credential.user?.sendEmailVerification();
                          } catch (e) {
                            debugPrint("Warning: sendEmailVerification failed: $e");
                          }

                          // Sign the user out — they must verify before entering
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          final verifyEmail = emailController.text.trim();

                          // Show a styled success snack before navigating
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 3000),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                content: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14111D),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xff9B2CFF),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xff9B2CFF,
                                        ).withValues(alpha: 0.22),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.mark_email_unread_outlined,
                                        color: Color(0xff9B2CFF),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Verification email sent.\nPlease verify your email before logging in.\nCheck your Spam/Junk folder if you don't see it.",
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                          Navigator.pushReplacement(
                            context,
                            FadePageRoute(
                              child: VerifyEmailScreen(email: verifyEmail),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          debugPrint("FirebaseAuthException during signup: ${e.code} - ${e.message}");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message ?? "Signup failed"),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Error during signup: $e");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Signup failed: $e"),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                      child: Opacity(
                        opacity: agree ? 1 : 0.5,
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
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    "✦  Create Account  ❯",
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ───────────────── OR ─────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.white12),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "OR",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(height: 1, color: Colors.white12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ───────────────── GOOGLE ─────────────────
                    ScaleOnPress(
                      onTap: () async {
                        if (isLoading || isGoogleLoading) return;
                        if (!agree) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please accept the Terms & Privacy Policy first",
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() => isGoogleLoading = true);

                        try {
                          final user = await _auth.signInWithGoogle();

                          if (user == null) return;

                          if (!context.mounted) return;
                          try {
                            await context.read<BucketProvider>().loadBucket();
                          } catch (e) {
                            debugPrint("Bucket loading non-fatal warning: $e");
                          }

                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            FadePageRoute(child: const MainScreen()),
                          );
                        } on FirebaseAuthException catch (e) {
                          debugPrint("FirebaseAuthException during Google signup: ${e.code} - ${e.message}");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.message ?? "Google Sign-In failed",
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Google signup error: $e");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Google Sign-In failed"),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => isGoogleLoading = false);
                          }
                        }
                      },
                      child: Opacity(
                        opacity: agree ? 1 : 0.5,
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isGoogleLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xff9B2CFF),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/google.png",
                                        width: size.width * 0.06,
                                        height: size.width * 0.06,
                                      ),

                                      const SizedBox(width: 12),

                                      Text(
                                        "Continue with Google",
                                        style: GoogleFonts.rajdhani(
                                          color: Colors.black87,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ───────────────── LOGIN ─────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.rajdhani(fontSize: 15),
                            children: const [
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.white54),
                              ),
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(
                                  color: Color(0xff9B2CFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── INPUT STYLE ─────────────────

  InputDecoration inputStyle(String hint, IconData icon, Widget? suffix) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xff8B35FF)),

      suffixIcon: suffix,

      hintText: hint,

      hintStyle: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 17),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff7435FF)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff009DFF)),
      ),
    );
  }
}
