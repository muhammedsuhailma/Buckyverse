import 'package:shared_preferences/shared_preferences.dart';

/// Manages first-time feature discovery tips.
/// Each tip is shown exactly once and then persisted in SharedPreferences.
class DiscoveryService {
  DiscoveryService._internal();
  static final DiscoveryService instance = DiscoveryService._internal();

  SharedPreferences? _prefs;

  Future<void> _ensureLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _kSearch = 'discovery_search';
  static const _kExploreLanguage = 'discovery_explore_language';
  static const _kShake = 'discovery_shake';
  static const _kShakeIntro = 'discovery_shake_intro';
  static const _kOffline = 'discovery_offline';
  static const _kNotificationPermission = 'discovery_notification_permission';

  // ── Public helpers ────────────────────────────────────────────────────────

  Future<bool> shouldShowSearchTip() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kSearch) ?? false);
  }

  Future<void> markSearchSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kSearch, true);
  }

  Future<bool> shouldShowExploreLangTip() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kExploreLanguage) ?? false);
  }

  Future<void> markExploreLangSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kExploreLanguage, true);
  }

  Future<bool> shouldShowShakeIntroTip() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kShakeIntro) ?? false);
  }

  Future<void> markShakeIntroSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kShakeIntro, true);
  }

  Future<bool> shouldShowShakeTip() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kShake) ?? false);
  }

  Future<void> markShakeSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kShake, true);
  }

  Future<bool> shouldShowOfflineTip() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kOffline) ?? false);
  }

  Future<void> markOfflineSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kOffline, true);
  }

  Future<bool> shouldShowNotificationPermission() async {
    await _ensureLoaded();
    return !(_prefs!.getBool(_kNotificationPermission) ?? false);
  }

  Future<void> markNotificationPermissionSeen() async {
    await _ensureLoaded();
    await _prefs!.setBool(_kNotificationPermission, true);
  }
}
