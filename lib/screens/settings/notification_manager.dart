import 'package:bucky_verse/screens/settings/notification_permission_page.dart';
import 'package:bucky_verse/services/discovery_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationManagerScreen extends StatefulWidget {
  const NotificationManagerScreen({super.key});

  @override
  State<NotificationManagerScreen> createState() =>
      _NotificationManagerScreenState();
}

class _NotificationManagerScreenState extends State<NotificationManagerScreen> {
  bool notificationsEnabled = false; // start disabled until permission granted
  bool newReleases = true;
  bool trendingUpdates = true;
  bool recommendations = true;
  bool appUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionState();
  }

  Future<void> _loadPermissionState() async {
    final seen = !(await DiscoveryService.instance.shouldShowNotificationPermission());
    if (mounted) setState(() => notificationsEnabled = seen);
  }

  Future<void> _handleNotificationsToggle(bool value) async {
    if (value) {
      // Show custom permission page first
      final granted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const NotificationPermissionPage(),
        ),
      );
      if (!mounted) return;
      setState(() => notificationsEnabled = granted ?? false);
    } else {
      setState(() {
        notificationsEnabled = false;
        newReleases = false;
        trendingUpdates = false;
        recommendations = false;
        appUpdates = false;
      });
    }
  }

  Widget notificationSwitch({
    required Size size,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * .015),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .04,
        vertical: size.height * .016,
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
                    fontSize: size.width * .041,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: size.width * .034,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFA855F7),
            activeTrackColor: const Color(0xFFA855F7).withValues(alpha: .35),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
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
          "Notifications",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 18,
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
            size.height * .04,
          ),
          children: [
            Text(
              "GENERAL",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: size.height * .015),

            notificationSwitch(
              size: size,
              icon: Icons.notifications_active_outlined,
              title: "Notifications",
              subtitle: "Allow BuckyVerse notifications",
              color: const Color(0xFFA855F7),
              value: notificationsEnabled,
              onChanged: _handleNotificationsToggle,
            ),

            SizedBox(height: size.height * .022),

            Text(
              "CONTENT",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: size.height * .015),

            notificationSwitch(
              size: size,
              icon: Icons.movie_outlined,
              title: "New Releases",
              subtitle: "Get notified when new titles are added",
              color: const Color(0xFF38BDF8),
              value: newReleases,
              onChanged: (value) {
                setState(() {
                  newReleases = value;
                });
              },
            ),

            notificationSwitch(
              size: size,
              icon: Icons.local_fire_department_outlined,
              title: "Trending Updates",
              subtitle: "Updates about trending titles",
              color: const Color(0xFFF97316),
              value: trendingUpdates,
              onChanged: (value) {
                setState(() {
                  trendingUpdates = value;
                });
              },
            ),

            notificationSwitch(
              size: size,
              icon: Icons.auto_awesome_outlined,
              title: "Recommendations",
              subtitle: "Get personalized recommendations",
              color: const Color(0xFFE879F9),
              value: recommendations,
              onChanged: (value) {
                setState(() {
                  recommendations = value;
                });
              },
            ),

            SizedBox(height: size.height * .022),

            Text(
              "APP",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            notificationSwitch(
              size: size,
              icon: Icons.system_update_outlined,
              title: "App Updates",
              subtitle: "Important BuckyVerse updates",
              color: const Color(0xFF22C55E),
              value: appUpdates,
              onChanged: (value) {
                setState(() {
                  appUpdates = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
