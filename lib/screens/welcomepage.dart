import 'package:bucky_verse/auth/loginpage.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}


class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fade = Tween<double>(begin: 0, end: 1).animate(controller);

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff02030F),

      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned(
            top: -76,
            bottom: -20,
            left: 0,
            right: 0,

            child: Image.asset(
              "assets/images/bvw.png",

              fit: BoxFit.cover,

              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            left: size.width * 0.08,
            right: size.width * 0.08,
            bottom: size.height * 0.02,

            child: FadeTransition(
              opacity: fade,

              child: Column(
                children: [
                  // ENTER BUTTON
                  ScaleOnPress(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool('seenWelcome', true);

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        FadePageRoute(child: const LoginScreen()),
                      );
                    },

                    child: Container(
                      height: 56,
                      constraints: const BoxConstraints(
                        minHeight: 56,
                        maxHeight: 62,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,

                          colors: [Color(0xff9B2CFF), Color(0xff009DFF)],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(
                              255,
                              113,
                              28,
                              116,
                            ).withValues(alpha: 0.55),

                            blurRadius: 22,

                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 5),

                            child: Text(
                              "✦",

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Text(
                            "Enter Your Verse",

                            style: GoogleFonts.rajdhani(
                              color: Colors.white,

                              fontSize: 20,

                              fontWeight: FontWeight.bold,

                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(width: 35),

                          const Icon(
                            Icons.arrow_forward_ios_rounded,

                            color: Colors.white,

                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // SIGN IN
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
