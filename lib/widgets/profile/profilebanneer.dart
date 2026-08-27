import 'dart:async';
import 'dart:io';

import 'package:bucky_verse/screens/settings/settings.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isSavingUsername = false;

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

  // ── Username edit ─────────────────────────────────────────────────────────

  /// Regex: letters, digits, spaces, underscores, hyphens only.
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9 _-]+$');

  void _showCosmicSnack(
    BuildContext ctx,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(ctx)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF14111D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSuccess
                    ? const Color(0xFF22A45D)
                    : const Color(0xff9B2CFF),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess
                          ? const Color(0xFF22A45D)
                          : const Color(0xff9B2CFF))
                      .withValues(alpha: 0.20),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  color: isSuccess
                      ? const Color(0xFF22A45D)
                      : const Color(0xff9B2CFF),
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Future<void> _showEditUsernameDialog() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentName =
        currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        '';

    final controller = TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      barrierDismissible: !_isSavingUsername,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            // ── Validation helper ────────────────────────────────────────
            String? validate(String raw) {
              final name = raw.trim();
              if (name.isEmpty) return "Username cannot be empty.";
              if (name.length < 3) {
                return "Username must be at least 3 characters.";
              }
              if (name.length > 20) {
                return "Username cannot exceed 20 characters.";
              }
              if (!_usernameRegex.hasMatch(name)) {
                return "Only letters, numbers, spaces, _ and - are allowed.";
              }
              return null;
            }

            // ── Save handler ─────────────────────────────────────────────
            Future<void> onSave() async {
              if (_isSavingUsername) return;

              final raw = controller.text;
              final error = validate(raw);
              if (error != null) {
                if (!dialogCtx.mounted) return;
                _showCosmicSnack(dialogCtx, error);
                return;
              }

              final newName = raw.trim();

              // No change — just close
              if (newName == currentName) {
                Navigator.pop(dialogCtx);
                return;
              }

              setDialogState(() => _isSavingUsername = true);
              setState(() => _isSavingUsername = true);

              // Capture context-dependent objects before async gaps
              final dialogNavigator = Navigator.of(dialogCtx);
              final profileScaffold = ScaffoldMessenger.of(context);

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  throw FirebaseAuthException(
                    code: 'no-current-user',
                    message: 'No authenticated user found.',
                  );
                }

                // 1. Update Firebase Auth displayName
                await user
                    .updateDisplayName(newName)
                    .timeout(const Duration(seconds: 10));

                // 2. Reload so currentUser reflects the new displayName
                await user.reload();

                // 3. Update Firestore (non-fatal if it fails)
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({'username': newName}).timeout(
                        const Duration(seconds: 8),
                      );
                  debugPrint("ProfileBanner: Firestore username updated.");
                } on FirebaseException catch (e) {
                  debugPrint(
                    "ProfileBanner: Firestore update warning: ${e.code} – ${e.message}",
                  );
                } on TimeoutException {
                  debugPrint(
                    "ProfileBanner: Firestore update timed out (non-fatal).",
                  );
                }

                debugPrint("ProfileBanner: displayName updated to '$newName'.");

                if (!mounted) return;

                // Close dialog then refresh banner + show snack
                dialogNavigator.pop();
                setState(() {});

                profileScaffold
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
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14111D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF22A45D),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF22A45D,
                              ).withValues(alpha: 0.20),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF22A45D),
                              size: 20,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                "✅ Username updated successfully.",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
              } on FirebaseAuthException catch (e) {
                debugPrint(
                  "ProfileBanner updateDisplayName FirebaseAuthException: ${e.code} – ${e.message}",
                );
                if (!dialogCtx.mounted) return;
                _showCosmicSnack(
                  dialogCtx,
                  e.message ?? "Failed to update username. Please try again.",
                );
              } on TimeoutException {
                debugPrint(
                  "ProfileBanner updateDisplayName: request timed out.",
                );
                if (!dialogCtx.mounted) return;
                _showCosmicSnack(
                  dialogCtx,
                  "Request timed out. Please try again.",
                );
              } on SocketException {
                debugPrint("ProfileBanner updateDisplayName: no internet.");
                if (!dialogCtx.mounted) return;
                _showCosmicSnack(
                  dialogCtx,
                  "Network error. Please check your connection.",
                );
              } catch (e) {
                debugPrint(
                  "ProfileBanner updateDisplayName unexpected error: $e",
                );
                if (!dialogCtx.mounted) return;
                _showCosmicSnack(
                  dialogCtx,
                  "Something went wrong. Please try again.",
                );
              } finally {
                if (mounted) setState(() => _isSavingUsername = false);
                if (dialogCtx.mounted) {
                  setDialogState(() => _isSavingUsername = false);
                }
              }
            }

            // ── Dialog UI ────────────────────────────────────────────────
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF14111D),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xff9B2CFF).withValues(alpha: 0.40),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff9B2CFF).withValues(alpha: 0.18),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xffB75CFF), Color(0xff33B5FF)],
                      ).createShader(bounds),
                      child: Text(
                        "Edit Username",
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "Choose a new display name for your BuckyVerse profile.",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Text field
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 20,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        counterStyle: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        hintText: "Enter your username",
                        hintStyle: GoogleFonts.rajdhani(
                          color: Colors.white30,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFFA855F7),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1B1825),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xff7435FF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xff009DFF),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => onSave(),
                    ),

                    const SizedBox(height: 20),

                    // Buttons row
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSavingUsername
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1825),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white60,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Save
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSavingUsername ? null : onSave,
                            child: AnimatedOpacity(
                              opacity: _isSavingUsername ? 0.6 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff9B2CFF),
                                      Color(0xff009DFF),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xff9B2CFF,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isSavingUsername
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.2,
                                          ),
                                        )
                                      : Text(
                                          "Save",
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
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
      },
    );

    controller.dispose();
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
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  FirebaseAuth.instance.currentUser
                                          ?.displayName ??
                                      FirebaseAuth.instance.currentUser
                                          ?.email
                                          ?.split('@')
                                          .first ??
                                      "Explorer",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: size.width * .054,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _showEditUsernameDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFA855F7,
                                    ).withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Color(0xFFA855F7),
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
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
