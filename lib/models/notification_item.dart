/// A single in-app notification item.
class NotificationItem {
  final String id;
  final String icon;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  /// Human-readable relative timestamp (e.g. "2 min ago", "1 hour ago").
  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? "min" : "mins"} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? "hour" : "hours"} ago';
    }
    final d = diff.inDays;
    return '$d ${d == 1 ? "day" : "days"} ago';
  }
}
