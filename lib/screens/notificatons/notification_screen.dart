import 'package:bucky_verse/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all notifications read as soon as the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        leading: ScaleOnPress(
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        title: Text(
          "NOTIFICATIONS",
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),

        centerTitle: true,
      ),

      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final notifications = provider.items;

          // ── Empty State ─────────────────────────────────────────────────
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "🔔",
                    style: TextStyle(fontSize: 56),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "No Notifications",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      "We'll let you know when something exciting happens in your universe.",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white38,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Notification List ───────────────────────────────────────────
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifications[index];

              return FadeInSlide(
                index: index,
                child: GestureDetector(
                  onTap: () {
                    // Mark as read immediately on tap
                    if (!n.isRead) {
                      provider.markRead(n.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15121C),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFA855F7)
                            .withValues(alpha: n.isRead ? .10 : .25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA855F7).withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            n.icon,
                            style: const TextStyle(fontSize: 23),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                n.body,
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                n.relativeTime,
                                style: GoogleFonts.rajdhani(
                                  color: const Color(0xFFA855F7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Unread dot
                        if (!n.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFA855F7),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
