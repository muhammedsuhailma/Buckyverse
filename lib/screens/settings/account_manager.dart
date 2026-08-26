import 'package:bucky_verse/auth/loginpage.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountManagerScreen extends StatelessWidget {
  const AccountManagerScreen({super.key});

  Widget accountCard({
    required BuildContext context,
    required String name,
    required String email,
    required String role,
    bool active = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14111D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? const Color(0xFFA855F7).withValues(alpha: .35)
              : Colors.white.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  email,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  role,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFA855F7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "ACTIVE",
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFA855F7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF09080F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          "Account Manager",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: size.width * .05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            size.width * .04,
            size.height * .015,
            size.width * .04,
            size.height * .035,
          ),
          children: [
            Text(
              "CURRENT ACCOUNT",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: size.width * .036,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: size.height * .015),

            accountCard(
              context: context,
              name: "LEO",
              email: "leo@example.com",
              role: "Universe Explorer",
              active: true,
            ),

            SizedBox(height: size.height * .022),

            Text(
              "ACCOUNT",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: size.height * .015),

            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  FadePageRoute(child: const LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * .04,
                  vertical: size.height * .018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF14111D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.switch_account_rounded,
                        color: Color(0xFF38BDF8),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign in with another account",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Switch to another BuckyVerse account",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * .015),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Account creation will be connected later."),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF14111D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFFA855F7),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add another account",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Add another BuckyVerse account",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * .035),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF15121C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        "Sign out?",
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: size.width * .045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "You can sign back in anytime.",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: size.width * .04,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "CANCEL",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Dummy sign out for now."),
                              ),
                            );
                          },
                          child: Text(
                            "SIGN OUT",
                            style: GoogleFonts.rajdhani(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: size.height * .07,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: .25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 21,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Sign Out",
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
