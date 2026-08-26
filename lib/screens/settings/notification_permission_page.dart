import 'package:bucky_verse/services/discovery_service.dart';
import 'package:bucky_verse/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom notification permission page.
/// Shown the first time the user visits Notification settings,
/// BEFORE any OS permission dialog is triggered.
class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  bool _requesting = false;

  Future<void> _enable() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    await DiscoveryService.instance.markNotificationPermissionSeen();
    final granted = await NotificationService.instance.requestPermission();

    if (!mounted) return;
    Navigator.pop(context, granted);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09080F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * .08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * .06),

              // Glowing bell
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA855F7).withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.30),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  '🔔',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 44),
                ),
              ),

              SizedBox(height: size.height * .04),

              Text(
                'Stay in the Loop',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * .018),

              Text(
                'BuckyVerse will notify you about new trending releases, '
                'bucket reminders, and cosmic updates — only what matters.',
                style: GoogleFonts.rajdhani(
                  color: Colors.white54,
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * .04),

              // Highlights
              _featureRow('🌌', 'New trending content alerts'),
              _featureRow('🪣', 'Bucket & wishlist reminders'),
              _featureRow('✨', 'Cosmic refresh notifications'),

              const Spacer(),

              // Enable button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _requesting ? null : _enable,
                  child: _requesting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Enable Notifications',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              SizedBox(height: size.height * .015),

              TextButton(
                onPressed: () async {
                  await DiscoveryService.instance
                      .markNotificationPermissionSeen();
                  if (!context.mounted) return;
                  Navigator.pop(context, false);
                },
                child: Text(
                  'Not now',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                ),
              ),

              SizedBox(height: size.height * .02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
