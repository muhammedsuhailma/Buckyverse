import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

/// Manages the list of in-app notifications and their read/unread state.
/// Consumed by [NotificationScreen] and the Home bell indicator.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _items = [];

  List<NotificationItem> get items => List.unmodifiable(_items);

  /// True when at least one notification is unread.
  bool get hasUnread => _items.any((n) => !n.isRead);

  /// Number of unread notifications.
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Add a new notification (unread by default).
  /// Inserts at the top so newest appears first.
  void add(NotificationItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  /// Mark a single notification as read by its id.
  void markRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    if (_items[index].isRead) return; // already read — no rebuild needed
    _items[index].isRead = true;
    notifyListeners();
  }

  /// Mark every notification as read at once.
  void markAllRead() {
    bool changed = false;
    for (final item in _items) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
