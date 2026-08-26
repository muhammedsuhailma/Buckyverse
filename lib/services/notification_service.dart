import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_item.dart';
import '../providers/notification_provider.dart';

/// Reusable notification service for BuckyVerse local notifications.
///
/// Handles both:
///   1. OS-level local notifications (flutter_local_notifications).
///   2. In-app notification feed via [NotificationProvider].
///
/// Designed for easy future migration to FCM push notifications:
/// - Keep this interface stable.
/// - Replace [_plugin.show] calls with FCM sends in the future.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Attach the provider after it's registered in the widget tree.
  NotificationProvider? _provider;

  void attachProvider(NotificationProvider provider) {
    _provider = provider;
  }

  static const String _channelId = 'buckyverse_channel';
  static const String _channelName = 'BuckyVerse';
  static const String _channelDescription =
      'BuckyVerse local notifications for cosmic updates and reminders.';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.high,
  );

  /// Initialise the plugin. Call once during app startup.
  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _initialized = true;
    debugPrint('[NotificationService] Initialized.');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Tapped notification: ${response.payload}');
    // Future: handle deep-link navigation here.
  }

  // ---------------------------------------------------------------------------
  // Core post method — fires OS notification AND adds to in-app feed.
  // ---------------------------------------------------------------------------

  Future<void> post({
    required int id,
    required String icon,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    // 1. OS notification
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );

    // 2. In-app feed
    _provider?.add(
      NotificationItem(
        id: '${id}_${DateTime.now().millisecondsSinceEpoch}',
        icon: icon,
        title: title,
        body: body,
        timestamp: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pre-built Cosmic Journey Notifications
  // ---------------------------------------------------------------------------

  Future<void> notifyContinueJourney() => post(
        id: 101,
        icon: '🌌',
        title: 'BuckyVerse',
        body: 'Continue your journey.',
        payload: 'continue_journey',
      );

  Future<void> notifyBucketWaiting() => post(
        id: 102,
        icon: '🪣',
        title: 'Your Bucket',
        body: 'Your bucket is waiting.',
        payload: 'bucket',
      );

  Future<void> notifyNewAnime() => post(
        id: 103,
        icon: '⚡',
        title: 'New Anime',
        body: 'New trending Anime available.',
        payload: 'anime',
      );

  Future<void> notifyFreshMovies() => post(
        id: 104,
        icon: '🎬',
        title: 'Fresh Movies',
        body: 'Fresh movies have arrived.',
        payload: 'movies',
      );

  Future<void> notifyTopPicks() => post(
        id: 105,
        icon: '✨',
        title: "Today's Picks",
        body: "Discover today's top picks.",
        payload: 'explore',
      );

  // ---------------------------------------------------------------------------
  // Permission helpers (Android 13+)
  // ---------------------------------------------------------------------------

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }
}
