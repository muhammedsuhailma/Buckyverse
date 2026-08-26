import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/network_service.dart';

enum NetworkState { online, offline }

/// Provider that listens to [NetworkService] and drives UI reactivity.
/// Manages: isOnline, retry, reconnect animation gating.
class NetworkProvider extends ChangeNotifier {
  NetworkProvider() {
    _init();
  }

  NetworkState _state = NetworkState.online;
  bool _showRestoredAnimation = false;
  bool _isRetrying = false;

  NetworkState get state => _state;
  bool get isOnline => _state == NetworkState.online;
  bool get showRestoredAnimation => _showRestoredAnimation;
  bool get isRetrying => _isRetrying;

  StreamSubscription<bool>? _sub;

  void _init() {
    // Sync initial state from service
    _state = NetworkService.instance.isOnline
        ? NetworkState.online
        : NetworkState.offline;

    _sub = NetworkService.instance.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(bool online) {
    if (online && _state == NetworkState.offline) {
      // Was offline → now online: trigger restored animation
      _state = NetworkState.online;
      _showRestoredAnimation = true;
      notifyListeners();
    } else if (!online && _state == NetworkState.online) {
      // Was online → now offline
      _state = NetworkState.offline;
      _showRestoredAnimation = false;
      notifyListeners();
    }
  }

  /// Called by [ConnectionRestoredOverlay] when it finishes animating.
  void onRestoredAnimationComplete() {
    _showRestoredAnimation = false;
    notifyListeners();
  }

  /// Called by the Retry button in offline state.
  Future<void> retry() async {
    if (_isRetrying) return;
    _isRetrying = true;
    notifyListeners();

    final back = await NetworkService.instance.retry();
    if (!back) {
      // Still offline
      _isRetrying = false;
      notifyListeners();
    }
    // If back online, _onChanged fires and updates state;
    // clean up retrying flag after a brief delay
    await Future.delayed(const Duration(milliseconds: 300));
    _isRetrying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
