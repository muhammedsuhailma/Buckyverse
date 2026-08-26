import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton network service that monitors real connectivity.
/// Uses connectivity_plus for change events + validates with actual socket ping.
class NetworkService {
  NetworkService._internal();
  static final NetworkService instance = NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _controller;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged {
    _controller ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasNetwork = results.any(
          (r) => r != ConnectivityResult.none,
        );

        if (!hasNetwork) {
          _update(false);
          return;
        }

        // Validate with actual socket ping even if connectivity reports online
        final reachable = await _checkInternet();
        _update(reachable);
      },
    );

    // Initial check
    _checkAndUpdate();
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _checkAndUpdate() async {
    final results = await _connectivity.checkConnectivity();
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);

    if (!hasNetwork) {
      _update(false);
      return;
    }

    final reachable = await _checkInternet();
    _update(reachable);
  }

  void _update(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    debugPrint('[NetworkService] isOnline = $online');
    _controller?.add(online);
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Force a recheck (used by retry button).
  Future<bool> retry() async {
    await _checkAndUpdate();
    return _isOnline;
  }

  void dispose() {
    _subscription?.cancel();
    _controller?.close();
    _controller = null;
  }
}
