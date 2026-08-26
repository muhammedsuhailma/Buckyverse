import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final ScrollController controller = ScrollController();

  bool reachedBottom = false;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final max = controller.position.maxScrollExtent;

      setState(() {
        progress = max == 0 ? 0 : (controller.offset / max).clamp(0.0, 1.0);

        if (!reachedBottom && controller.offset >= max - 20) {
          reachedBottom = true;
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff02030F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xff9B2CFF), Color(0xff33B5FF)],
            ).createShader(bounds);
          },
          child: Text(
            "Terms of Service",
            style: GoogleFonts.rajdhani(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .04),

                  borderRadius: BorderRadius.circular(22),

                  border: Border.all(
                    color: const Color(0xff9B2CFF).withValues(alpha: .25),
                  ),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 42,
                      color: Color(0xff9B2CFF),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Welcome to BuckyVerse",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Please read the Terms of Service carefully before creating your account.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xff9B2CFF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      reachedBottom
                          ? "✔ You've reached the end"
                          : "⬇ Scroll to continue",
                      style: GoogleFonts.rajdhani(
                        color: reachedBottom
                            ? Colors.greenAccent
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .04),

                    borderRadius: BorderRadius.circular(22),

                    border: Border.all(color: Colors.white10),
                  ),

                  child: SingleChildScrollView(
                    controller: controller,

                    child: Text(
                      '''
1. Acceptance of Terms

By creating a BuckyVerse account, you agree to these Terms of Service and all applicable laws and regulations.

2. Account Responsibility

• Keep your account credentials secure.
• You are responsible for all activity that occurs under your account.
• Do not share your password with anyone.

3. Community Guidelines

BuckyVerse is built to provide a safe and enjoyable experience for everyone.

You agree not to:
• Upload illegal or harmful content.
• Harass, threaten, or abuse other users.
• Attempt to exploit, hack, or disrupt the platform.
• Use bots or automated tools without authorization.

4. Content Ownership

You retain ownership of the content you create.

By submitting content, you grant BuckyVerse permission to display and process it within the application to provide its services.

5. Privacy

Your privacy is important to us.

Your personal information is handled according to our Privacy Policy and will never be sold without your consent.

6. Service Availability

While we strive to provide uninterrupted service, maintenance, updates, or technical issues may occasionally affect availability.

7. Updates to These Terms

These Terms may be updated from time to time. Continued use of BuckyVerse after changes become effective constitutes your acceptance of the revised Terms.

8. Account Termination

We reserve the right to suspend or terminate accounts that violate these Terms or misuse the platform.

9. Disclaimer

BuckyVerse is provided "as is" without warranties of any kind, either express or implied.

10. Contact

If you have any questions regarding these Terms, please contact the BuckyVerse support team.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Thank you for taking the time to read these Terms of Service.

We hope you enjoy exploring the BuckyVerse universe.

Happy Bucket Listing! 🚀''',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  reachedBottom
                      ? "You can now accept the Terms."
                      : "Read until the end to unlock the button.",
                  style: GoogleFonts.rajdhani(
                    color: reachedBottom ? Colors.greenAccent : Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: reachedBottom
                    ? () {
                        Navigator.pop(context, true);
                      }
                    : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: reachedBottom ? 1 : .5,
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
                          spreadRadius: 1,
                        ),
                      ],
                    ),

                    child: Center(
                      child: Text(
                        "✦  I Agree & Continue  ❯",
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

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
