import 'dart:convert';
import 'dart:io';

import 'package:bucky_verse/models/update_info.dart';
import 'package:bucky_verse/utils/version_compare.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// ── Configuration ────────────────────────────────────────────────────────────
/// Change these two constants to point to a different repository.
const String _kGithubOwner = 'muhammedsuhailma';
const String _kGithubRepo = 'Buckyverse';
const String _kApiUrl =
    'https://api.github.com/repos/$_kGithubOwner/$_kGithubRepo/releases/latest';

 class UpdateService {
  UpdateService._internal();
  static final UpdateService instance = UpdateService._internal();

  UpdateInfo? _cached;
  bool _checked = false;

  /// Singleton [Dio] instance used only by the update service.
  ///
  /// The per-request [Options] in [checkForUpdate] sets
  /// [ResponseType.plain] so that Dio returns the raw JSON string,
  /// which is then decoded manually with [jsonDecode]. This is required
  /// because Dio 5.x does not auto-decode [application/vnd.github+json]
  /// (only [application/json] is auto-decoded).
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ),
  );

  /// Checks GitHub Releases for an update.
  ///
  /// Returns an [UpdateInfo] when a newer version is available.
  /// Returns `null` when:
  ///   - The installed version is already up to date.
  ///   - GitHub is unreachable or the request times out.
  ///   - The JSON response is malformed.
  ///   - There is no APK asset attached to the latest release.
  ///
  /// The result is **cached** — subsequent calls within the same app session
  /// return immediately without hitting the network.
  Future<UpdateInfo?> checkForUpdate() async {
    // ── [TRACE 0] Entry ──────────────────────────────────────────────────────
    debugPrint('[UpdateService] ▶ checkForUpdate() called');

    // Return cached result on subsequent calls.
    if (_checked) {
      debugPrint(
        '[UpdateService] ↩ Already checked this session. '
        'Cached result: ${_cached ?? "no update"}',
      );
      return _cached;
    }

    try {
      // ── [TRACE 1] Read installed version ─────────────────────────────────
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version;
      debugPrint(
        '[UpdateService] [1] Installed version: "$installedVersion" '
        '(buildNumber=${packageInfo.buildNumber})',
      );

      // ── [TRACE 2] Hit GitHub API ──────────────────────────────────────────
      debugPrint('[UpdateService] [2] GET $_kApiUrl');
      //
      // ROOT CAUSE FIX: Dio 5.x only auto-decodes JSON when the response
      // Content-Type is exactly "application/json". GitHub returns
      // "application/vnd.github+json", which Dio treats as a raw String
      // rather than decoding it into a Map<String, dynamic>.
      //
      // Previous code:
      //   final response = await _dio.get<Map<String, dynamic>>(_kApiUrl);
      //   final Map<String, dynamic> json = response.data!;   ← TypeError!
      //
      // The cast threw a TypeError (String → Map) which was silently caught,
      // _markChecked(null) was called, and the dialog never appeared.
      //
      // Fix: request the body as plain text (ResponseType.plain) then decode
      // it manually with jsonDecode — reliable regardless of Content-Type.
      //
      final response = await _dio.get<String>(
        _kApiUrl,
        options: Options(responseType: ResponseType.plain),
      );

      debugPrint(
        '[UpdateService] [2] Response status: ${response.statusCode}, '
        'data type: ${response.data.runtimeType}',
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint(
          '[UpdateService] [2] ✗ Unexpected status ${response.statusCode} — aborting.',
        );
        _markChecked(null);
        return null;
      }

      // ── [TRACE 3] Parse fields ────────────────────────────────────────────
      // Manually decode the JSON string from GitHub.
      final Map<String, dynamic> json =
          jsonDecode(response.data!) as Map<String, dynamic>;

      final tagName = (json['tag_name'] as String? ?? '').trim();
      final body = (json['body'] as String? ?? '').trim();
      final assets = json['assets'] as List<dynamic>? ?? [];

      debugPrint(
        '[UpdateService] [3] tag_name="$tagName" '
        'body.length=${body.length} '
        'assets.count=${assets.length}',
      );

      if (tagName.isEmpty) {
        debugPrint('[UpdateService] [3] ✗ tag_name is empty — aborting.');
        _markChecked(null);
        return null;
      }

      // Strip leading 'v'/'V' for semver comparison.
      final latestVersion = (tagName.startsWith('v') || tagName.startsWith('V'))
          ? tagName.substring(1)
          : tagName;

      // ── [TRACE 4] Version comparison ──────────────────────────────────────
      debugPrint(
        '[UpdateService] [4] Comparing: '
        'installed="$installedVersion" vs latest="$latestVersion"',
      );

      final needsUpdate = isNewerVersion(installedVersion, latestVersion);
      debugPrint('[UpdateService] [4] isNewerVersion result: $needsUpdate');

      if (!needsUpdate) {
        debugPrint('[UpdateService] [4] ✓ App is up to date — no dialog.');
        _markChecked(null);
        return null;
      }

      // ── [TRACE 5] Find APK asset ──────────────────────────────────────────
      debugPrint(
        '[UpdateService] [5] Scanning ${assets.length} asset(s) for APK…',
      );

      String? apkUrl;
      for (var i = 0; i < assets.length; i++) {
        final assetMap = assets[i] as Map<String, dynamic>;
        final name = (assetMap['name'] as String? ?? '').toLowerCase();
        final contentType = assetMap['content_type'] as String? ?? '';
        final downloadUrl = assetMap['browser_download_url'] as String? ?? '';

        debugPrint(
          '[UpdateService] [5]   asset[$i] name="$name" '
          'contentType="$contentType"',
        );

        if (name.endsWith('.apk') ||
            contentType == 'application/vnd.android.package-archive') {
          apkUrl = downloadUrl;
          debugPrint('[UpdateService] [5] ✓ APK found: "$name" → $apkUrl');
          break;
        }
      }

      if (apkUrl == null || apkUrl.isEmpty) {
        debugPrint(
          '[UpdateService] [5] ✗ No APK asset in release "$tagName". '
          'Attach a .apk file to the GitHub Release to enable in-app updates.',
        );
        _markChecked(null);
        return null;
      }

      // ── [TRACE 6] Return UpdateInfo ───────────────────────────────────────
      final info = UpdateInfo(
        latestVersion: latestVersion,
        tagName: tagName,
        releaseNotes: body.isEmpty ? 'No release notes provided.' : body,
        apkDownloadUrl: apkUrl,
      );

      debugPrint(
        '[UpdateService] [6] ✓ Update available! '
        'installed=$installedVersion → latest=$latestVersion. '
        'Dialog will be shown.',
      );
      _markChecked(info);
      return info;

      // ── Error handlers ────────────────────────────────────────────────────
    } on DioException catch (e) {
      _handleError('DioException (type=${e.type})', e);
    } on SocketException catch (e) {
      _handleError('SocketException (no internet?)', e);
    } on TypeError catch (e) {
      // Catches runtime type mismatches (e.g. wrong JSON structure from API).
      _handleError('TypeError — unexpected API shape', e);
    } on FormatException catch (e) {
      _handleError('FormatException (malformed response)', e);
    } catch (e, st) {
      debugPrint('[UpdateService] Unexpected error: $e\n$st');
    }

    _markChecked(null);
    return null;
  }

  void _markChecked(UpdateInfo? result) {
    _checked = true;
    _cached = result;
  }

  void _handleError(String label, Object error) {
    debugPrint('[UpdateService] ✗ $label:\n  $error');
  }

  /// Resets the in-memory cache.
  ///
  /// Call this only in tests or when you deliberately want the service to
  /// re-check on the next [checkForUpdate] call.
  @visibleForTesting
  void resetCache() {
    _checked = false;
    _cached = null;
  }
}
