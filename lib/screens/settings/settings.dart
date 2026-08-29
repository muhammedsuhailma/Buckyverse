import 'package:bucky_verse/auth/loginpage.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:bucky_verse/screens/settings/about_bucky.dart';
import 'package:bucky_verse/screens/settings/account_manager.dart';
import 'package:bucky_verse/screens/settings/edit_profile.dart';
import 'package:bucky_verse/screens/settings/notification_manager.dart';
import 'package:bucky_verse/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "";
  String _build = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _version = info.version;
      _build = info.buildNumber;
    });
  }

  Widget settingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * .015),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * .04,
          vertical: size.height * .017,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF14111D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Row(
          children: [
            Container(
              width: size.width * .11,
              height: size.width * .11,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),

            SizedBox(width: size.width * .035),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
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
              size: 22,
            ),
          ],
        ),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 20,
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
              "Preferences",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: size.height * .015),
            settingsItem(
              context: context,
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              subtitle: "Manage your notifications",
              color: const Color(0xFFA855F7),
              onTap: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(child: const NotificationManagerScreen()),
                );
              },
            ),

            SizedBox(height: size.height * .015),
            Text(
              "Account",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: size.height * .015),
            settingsItem(
              context: context,
              icon: Icons.person_outline_rounded,
              title: "Edit Profile",
              subtitle: "Update your profile information",
              color: const Color(0xFF38BDF8),
              onTap: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(
                    child: const EditProfileScreen(
                      username: "LEO",
                      displayTitle: "Universe Explorer",
                      bio: "Exploring every universe.",
                    ),
                  ),
                );
              },
            ),

            settingsItem(
              context: context,
              icon: Icons.manage_accounts_outlined,
              title: "Account Manager",
              subtitle: "Manage your BuckyVerse accounts",
              color: const Color(0xFFA855F7),
              onTap: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(child: const AccountManagerScreen()),
                );
              },
            ),

            settingsItem(
              context: context,
              icon: Icons.info_outline_rounded,
              title: "About BuckyVerse",
              subtitle: _version.isEmpty ? "Loading..." : "Version $_version",
              color: const Color(0xFF22C55E),
              onTap: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(
                    child: AboutBuckyVerseScreen(
                      version: _version,
                      buildNumber: _build,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: size.height * .022),
            GestureDetector(
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF14111D),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      "Are you sure you want to logout?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (shouldLogout != true) return;

                try {
                  await AuthService().logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    FadePageRoute(child: const LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
                }
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
                      "Logout",
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
