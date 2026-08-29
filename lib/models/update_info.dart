/// Immutable data class representing a GitHub Release that has a newer
/// version than the currently installed app.
class UpdateInfo {
  /// Cleaned version string, e.g. "1.2.0" (leading 'v' stripped).
  final String latestVersion;

  /// Raw tag name from GitHub, e.g. "v1.2.0".
  final String tagName;

  /// Release notes / changelog body from the GitHub Release.
  final String releaseNotes;

  /// Direct download URL for the APK asset.
  final String apkDownloadUrl;

  const UpdateInfo({
    required this.latestVersion,
    required this.tagName,
    required this.releaseNotes,
    required this.apkDownloadUrl,
  });

  /// Suggested local filename for the downloaded APK.
  String get apkFileName => 'BuckyVerse-$tagName.apk';

  @override
  String toString() =>
      'UpdateInfo(latestVersion: $latestVersion, tagName: $tagName)';
}
