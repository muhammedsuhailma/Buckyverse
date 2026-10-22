/// Pure-Dart semantic version comparison utilities.
///
/// Only handles dot-separated numeric segments (major.minor.patch).
/// Leading 'v' or 'V' prefixes are stripped automatically so both
/// "1.2.0" and "v1.2.0" are handled correctly.
library;

/// Returns `true` when [latest] is strictly newer than [installed].
///
/// Non-numeric segments are treated as 0.
/// If either string is empty or unparseable, returns `false` (no update).
bool isNewerVersion(String installed, String latest) {
  final a = _parse(installed);
  final b = _parse(latest);

  final length = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (bv > av) return true;
    if (bv < av) return false;
  }
  return false; // equal
}

/// Strips a leading 'v'/'V' and splits on '.' into integer segments.
List<int> _parse(String version) {
  var v = version.trim();
  if (v.startsWith('v') || v.startsWith('V')) {
    v = v.substring(1);
  }
  return v.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
}
