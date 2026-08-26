import 'package:bucky_verse/auth/loginpage.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/screens/mainscreen.dart';
import 'package:bucky_verse/screens/welcomepage.dart';
import 'package:bucky_verse/utils/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _hasNavigated = false;

  Future<void> _goNext() async {
    final prefs = await SharedPreferences.getInstance();

    final bool seenWelcome = prefs.getBool('seenWelcome') ?? false;
    final User? user = FirebaseAuth.instance.currentUser;

    debugPrint("seenWelcome: $seenWelcome");
    debugPrint("User: ${user?.email}");

    if (!mounted) return;

    if (!seenWelcome) {
      Navigator.pushReplacement(
        context,
        FadePageRoute(child: const WelcomeScreen()),
      );
    } else if (user != null) {
      // Load bucket from Firestore before opening Home
      await context.read<BucketProvider>().loadBucket();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        FadePageRoute(child: const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        FadePageRoute(child: const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/bv.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.play();
        }
      });

    _videoController.addListener(() {
      if (!_hasNavigated &&
          _videoController.value.isInitialized &&
          _videoController.value.position >= _videoController.value.duration) {
        _hasNavigated = true;
        _goNext();
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _videoController.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: RepaintBoundary(
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
              )
            : const SizedBox.expand(child: ColoredBox(color: Colors.black)),
      ),
    );
  }
}
