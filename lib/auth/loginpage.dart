import 'package:bucky_verse/auth/forgetpassword.dart';
import 'package:bucky_verse/auth/signuppage.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/screens/mainscreen.dart';
import 'package:bucky_verse/services/auth_services.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  bool isLoading = false;
  bool isGoogleLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff02030F),

      body: Stack(
        children: [
          // ───────────────── BACKGROUND IMAGE ─────────────────
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
                              "Welcome back to",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // BuckyVerse logo text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Bucky",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 55,
                                  fontWeight: FontWeight.w500,
                                  wordSpacing: 1,
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

                    const SizedBox(height: 10),

                    // ───────────────── EMAIL ─────────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 26),

                          // ───────────────── EMAIL ─────────────────
                          Text(
                            "Email Address",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            decoration: inputStyle(
                              "Enter your email",
                              Icons.email_outlined,
                              null,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }

                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return "Enter a valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // ───────────────── PASSWORD ─────────────────
                          Text(
                            "Password",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: hidePassword,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            decoration: inputStyle(
                              "Enter your password",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Password is required";
                              }

                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // ───────────────── FORGOT PASSWORD ─────────────────
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ───────────────── FORGOT PASSWORD ─────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideFadePageRoute(
                              child: const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xff9B2CFF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ───────────────── SIGN IN BUTTON ─────────────────
                    ScaleOnPress(
                      onTap: () async {
                        if (isLoading || isGoogleLoading) return;
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        setState(() => isLoading = true);

                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          await AuthService().login(
                            email: email,
                            password: password,
                          );

                          if (!context.mounted) return;
                          // Load the user's bucket from Firestore
                          try {
                            await context.read<BucketProvider>().loadBucket();
                          } catch (e) {
                            debugPrint("Bucket loading non-fatal warning: $e");
                          }

                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            SlideFadePageRoute(child: const MainScreen()),
                          );
                        } on FirebaseAuthException catch (e) {
                          debugPrint(
                            "FirebaseAuthException in login: ${e.code} - ${e.message}",
                          );
                          String message;

                          switch (e.code) {
                            case 'invalid-email':
                              message = "Invalid email address.";
                              break;

                            case 'invalid-credential':
                            case 'wrong-password':
                              message = "Incorrect email or password.";
                              break;

                            case 'user-not-found':
                              message = "No account found with this email.";
                              break;

                            case 'too-many-requests':
                              message = "Too many attempts. Try again later.";
                              break;

                            default:
                              message = e.message ?? "Login failed.";
                          }

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          debugPrint("Error during login: $e");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login failed: $e")),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
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
                              color: const Color(
                                0xff8B35FF,
                              ).withValues(alpha: .45),
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
                                  "✦  Sign In  ❯",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ───────────────── OR DIVIDER ─────────────────
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

                    // ───────────────── GOOGLE BUTTON ─────────────────
                    ScaleOnPress(
                      onTap: () async {
                        if (isLoading || isGoogleLoading) return;

                        setState(() => isGoogleLoading = true);

                        try {
                          final userCredential = await AuthService()
                              .signInWithGoogle();

                          if (userCredential == null) {
                            return;
                          }

                          if (!context.mounted) return;
                          try {
                            await context.read<BucketProvider>().loadBucket();
                          } catch (e) {
                            debugPrint("Bucket loading non-fatal warning: $e");
                          }

                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            SlideFadePageRoute(child: const MainScreen()),
                          );
                        } on FirebaseAuthException catch (e) {
                          debugPrint(
                            "FirebaseAuthException in Google sign in: ${e.code} - ${e.message}",
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.message ?? "Google Sign-In failed",
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Google Sign-In error: $e");
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

                    const SizedBox(height: 28),

                    // ───────────────── SIGN UP ─────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideFadePageRoute(child: const Signuppage()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.rajdhani(fontSize: 15),
                            children: const [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.white54),
                              ),
                              TextSpan(
                                text: "Sign Up",
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
      errorStyle: GoogleFonts.rajdhani(color: Colors.redAccent, fontSize: 13),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
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
