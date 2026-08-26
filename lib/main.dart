import 'package:bucky_verse/providers/api_provider.dart';
import 'package:bucky_verse/providers/bucket_provider.dart';
import 'package:bucky_verse/providers/network_provider.dart';
import 'package:bucky_verse/providers/notification_provider.dart';
import 'package:bucky_verse/screens/splash/splash_screen.dart';
import 'package:bucky_verse/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize local notifications
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BucketProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = NotificationProvider();
            // Wire the provider into the service so post() reaches the feed.
            NotificationService.instance.attachProvider(provider);
            return provider;
          },
        ),
      ],
      child: const BuckyVerse(),
    ),
  );
}

class BuckyVerse extends StatelessWidget {
  const BuckyVerse({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BuckyVerse",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
