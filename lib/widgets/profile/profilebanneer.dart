import 'dart:io';

import 'package:bucky_verse/screens/settings/settings.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileBanner extends StatefulWidget {
  const ProfileBanner({super.key});

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  final user = FirebaseAuth.instance.currentUser;
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final imagePath = prefs.getString('profile_image');

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);

      if (await file.exists()) {
        if (!mounted) return;

        setState(() {
          _profileImage = file;
        });
      }
    }
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedImage == null) {
      return;
    }

    final file = File(pickedImage.path);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_image', file.path);

    if (!mounted) return;

    setState(() {
      _profileImage = file;
    });
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14111D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Change Profile Photo",
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _imageOption(
                        icon: Icons.camera_alt_rounded,
                        title: "Camera",
                        onTap: () {
                          Navigator.pop(context);

                          _pickProfileImage(ImageSource.camera);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _imageOption(
                        icon: Icons.photo_library_rounded,
                        title: "Gallery",
                        onTap: () {
                          Navigator.pop(context);

                          _pickProfileImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ScaleOnPress(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1825),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFA855F7), size: 28),

            const SizedBox(height: 8),

            Text(
              title,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(context, SlideFadePageRoute(child: const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, size.width * .05, size.height * .01),
      child: Container(
        height: size.height * .28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: const DecorationImage(
            image: AssetImage("assets/images/profban.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: .25),
                Colors.black.withValues(alpha: .55),
                Colors.black.withValues(alpha: .82),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: size.height * .017,
                right: size.width * .02,
                child: ScaleOnPress(
                  onTap: () => _openSettings(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF14111D).withValues(alpha: .80),
                      border: Border.all(
                        color: const Color(0xFFA855F7).withValues(alpha: .20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withValues(alpha: .20),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(size.width * .055),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: size.width * .24,
                          height: size.width * .24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFA855F7),
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : const AssetImage("assets/images/demon.jpeg")
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ScaleOnPress(
                            onTap: _showImagePicker,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF09080F),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: size.width * .05),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ??
                                user?.email?.split('@').first ??
                                "Explorer",
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: size.width * .06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            user?.email ?? "",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFA855F7,
                              ).withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Universe Explorer",
                              style: GoogleFonts.rajdhani(
                                color: const Color(0xFFA855F7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            "Building your entertainment universe.",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
