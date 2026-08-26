import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String displayTitle;
  final String bio;

  const EditProfileScreen({
    super.key,
    required this.username,
    required this.displayTitle,
    required this.bio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController usernameController;
  late TextEditingController titleController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);

    titleController = TextEditingController(text: widget.displayTitle);

    bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    usernameController.dispose();
    titleController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void saveProfile() {
    final username = usernameController.text.trim();
    final title = titleController.text.trim();
    final bio = bioController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty.")),
      );
      return;
    }

    Navigator.pop(context, {
      "username": username,
      "displayTitle": title,
      "bio": bio,
    });
  }

  Widget profileField({
    required Size size,
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),

        SizedBox(height: size.height * .01),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: size.width * .042,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: const Color(0xFFA855F7),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.rajdhani(
              color: Colors.white30,
              fontSize: size.width * .039,
            ),
            filled: true,
            fillColor: const Color(0xFF14111D),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * .04,
              vertical: size.height * .018,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: .06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: .06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Color(0xFFA855F7),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
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
          "Edit Profile",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            size.width * .05,
            size.height * .02,
            size.width * .05,
            size.height * .04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: size.width * .23,
                      height: size.width * .23,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: .25),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: size.width * .12,
                      ),
                    ),

                    SizedBox(height: size.height * .015),
                    Text(
                      "Edit your profile information",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white54,
                        fontSize: size.width * .036,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * .035),
              profileField(
                size: size,
                label: "USERNAME",
                hint: "Enter your username",
                controller: usernameController,
              ),

              SizedBox(height: size.height * .025),
              profileField(
                size: size,
                label: "DISPLAY TITLE",
                hint: "Enter your display title",
                controller: titleController,
              ),

              SizedBox(height: size.height * .025),
              profileField(
                size: size,
                label: "BIO",
                hint: "Tell us something about yourself",
                controller: bioController,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // Save button
              GestureDetector(
                onTap: saveProfile,
                child: Container(
                  width: double.infinity,
                  height: size.height * .07,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: .25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 21,
                      ),

                      SizedBox(width: size.width * .02),
                      Text(
                        "SAVE CHANGES",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: size.width * .041,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
