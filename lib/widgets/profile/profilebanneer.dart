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

// ─────────────────────────────────────────────────────────────────────────────
// ProfileBanner
// ─────────────────────────────────────────────────────────────────────────────

class ProfileBanner extends StatefulWidget {
  const ProfileBanner({super.key});

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner> {
  File? _profileImage;

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // ── Image persistence ──────────────────────────────────────────────────────

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        if (!mounted) return;
        setState(() => _profileImage = file);
      }
    }
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedImage == null) return;

    final file = File(pickedImage.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', file.path);

    if (!mounted) return;
    setState(() => _profileImage = file);
  }

  // ── Snack helper ───────────────────────────────────────────────────────────

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

  // ── Combined Edit Profile sheet ────────────────────────────────────────────

  void _showEditProfileSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return _EditProfileSheet(
          currentImage: _profileImage,
          onImagePicked: (File file) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('profile_image', file.path);
            if (!mounted) return;
            setState(() => _profileImage = file);
          },
          onPickImage: _pickProfileImage,
          onUsernameSaved: () {
            if (mounted) setState(() {});
          },
          showCosmicSnack: (message, {bool isSuccess = false}) {
            if (mounted) _showCosmicSnack(context, message, isSuccess: isSuccess);
          },
        );
      },
    );
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  void _openSettings() {
    Navigator.push(context, SlideFadePageRoute(child: const SettingsScreen()));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
            image: AssetImage('assets/images/profban.png'),
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
              // ── Settings button ────────────────────────────────────────
              Positioned(
                top: size.height * .017,
                right: size.width * .02,
                child: ScaleOnPress(
                  onTap: _openSettings,
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

              // ── Main content ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(size.width * .055),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Avatar + edit button ─────────────────────────────
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
                                  : const AssetImage(
                                          'assets/images/demon.jpeg')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Edit button — opens combined sheet
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ScaleOnPress(
                            onTap: _showEditProfileSheet,
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

                    // ── User info ────────────────────────────────────────
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                FirebaseAuth.instance.currentUser?.email
                                    ?.split('@')
                                    .first ??
                                'Explorer',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: size.width * .054,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _user?.email ?? '',
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
                              color: const Color(0xFFA855F7).withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Universe Explorer',
                              style: GoogleFonts.rajdhani(
                                color: const Color(0xFFA855F7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            'Building your entertainment universe.',
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

// ─────────────────────────────────────────────────────────────────────────────
// _EditProfileSheet  — owns its own controller & focus node lifecycle
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final File? currentImage;
  final Future<void> Function(File) onImagePicked;
  final Future<void> Function(ImageSource) onPickImage;
  final VoidCallback onUsernameSaved;
  final void Function(String message, {bool isSuccess}) showCosmicSnack;

  const _EditProfileSheet({
    required this.currentImage,
    required this.onImagePicked,
    required this.onPickImage,
    required this.onUsernameSaved,
    required this.showCosmicSnack,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _usernameCtrl;
  late final FocusNode _usernameFocus;
  bool _isSaving = false;
  File? _localImage;

  /// Regex: letters, digits, spaces, underscores, hyphens only.
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9 _-]+$');

  @override
  void initState() {
    super.initState();
    _localImage = widget.currentImage;

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentName = currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        '';

    _usernameCtrl = TextEditingController(text: currentName);
    _usernameFocus = FocusNode();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validate(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return 'Username cannot be empty.';
    if (name.length < 3) return 'Username must be at least 3 characters.';
    if (name.length > 25) return 'Username cannot exceed 25 characters.';
    if (!_usernameRegex.hasMatch(name)) {
      return 'Only letters, numbers, spaces, _ and - are allowed.';
    }
    return null;
  }

  // ── Pick image ─────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close this sheet first
    await widget.onPickImage(source);
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;

    final error = _validate(_usernameCtrl.text);
    if (error != null) {
      widget.showCosmicSnack(error);
      return;
    }

    final newName = _usernameCtrl.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentName = currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        '';

    // No change — just close
    if (newName == currentName) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    // Capture navigator before async gap
    final nav = Navigator.of(context);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No authenticated user found.',
        );
      }

      // 1. Update FirebaseAuth displayName
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
            .update({'username': newName}).timeout(const Duration(seconds: 8));
        debugPrint('EditProfileSheet: Firestore username updated.');
      } on FirebaseException catch (e) {
        debugPrint(
            'EditProfileSheet: Firestore warning: ${e.code} – ${e.message}');
      } on TimeoutException {
        debugPrint('EditProfileSheet: Firestore update timed out (non-fatal).');
      }

      debugPrint("EditProfileSheet: displayName updated to '$newName'.");

      if (!mounted) return;

      // Close sheet, then refresh parent banner + show success snack
      nav.pop();
      widget.onUsernameSaved();
      widget.showCosmicSnack(
        '✅ Username updated successfully.',
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'EditProfileSheet FirebaseAuthException: ${e.code} – ${e.message}');
      if (!mounted) return;
      widget.showCosmicSnack(
          e.message ?? 'Failed to update username. Please try again.');
    } on TimeoutException {
      debugPrint('EditProfileSheet: request timed out.');
      if (!mounted) return;
      widget.showCosmicSnack('Request timed out. Please try again.');
    } on SocketException {
      debugPrint('EditProfileSheet: no internet.');
      if (!mounted) return;
      widget.showCosmicSnack('Network error. Please check your connection.');
    } catch (e) {
      debugPrint('EditProfileSheet unexpected error: $e');
      if (!mounted) return;
      widget.showCosmicSnack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14111D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),

              // ── Drag handle ─────────────────────────────────────────────
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              // ── Title ───────────────────────────────────────────────────
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xffB75CFF), Color(0xff33B5FF)],
                ).createShader(bounds),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Profile picture preview ─────────────────────────────────
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA855F7),
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: _localImage != null
                        ? FileImage(_localImage!)
                        : const AssetImage('assets/images/demon.jpeg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Change photo row ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _imageOption(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _imageOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Divider ─────────────────────────────────────────────────
              Divider(
                color: Colors.white.withValues(alpha: .07),
                height: 1,
                indent: 20,
                endIndent: 20,
              ),

              const SizedBox(height: 20),

              // ── Username label ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Username TextField ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameCtrl,
                  focusNode: _usernameFocus,
                  maxLength: 25,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    counterStyle: GoogleFonts.rajdhani(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                    hintText: 'Enter your username',
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
                  onSubmitted: (_) => _save(),
                  textInputAction: TextInputAction.done,
                ),
              ),

              const SizedBox(height: 24),

              // ── Save Changes button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: _isSaving ? null : _save,
                  child: AnimatedOpacity(
                    opacity: _isSaving ? 0.6 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff9B2CFF),
                            Color(0xff009DFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff9B2CFF).withValues(alpha: 0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 17,
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
        ),
      ),
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
}
