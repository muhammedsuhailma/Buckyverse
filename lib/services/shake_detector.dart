import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Lightweight accelerometer-based shake detector using sensors_plus.
/// Calls [onShake] when a shake is detected.
class ShakeDetector {
  final VoidCallback onShake;

  /// Minimum magnitude of the acceleration vector delta to count as a shake.
  final double threshold;

  /// Minimum time between two consecutive shake triggers.
  final Duration debounce;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _lastShake;
  AccelerometerEvent? _lastEvent;
  bool _active = false;

  ShakeDetector({
    required this.onShake,
    this.threshold = 12.0,
    this.debounce = const Duration(milliseconds: 1500),
  });

  /// Start listening for shakes.
  void start() {
    if (_active) return;
    _active = true;

    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onEvent, onError: (e) {
      debugPrint('[ShakeDetector] Error: $e');
    });
  }

  void _onEvent(AccelerometerEvent event) {
    if (!_active) return;

    final prev = _lastEvent;
    _lastEvent = event;

    if (prev == null) return;

    final dx = event.x - prev.x;
    final dy = event.y - prev.y;
    final dz = event.z - prev.z;

    final magnitude = sqrt(dx * dx + dy * dy + dz * dz);

    if (magnitude >= threshold) {
      final now = DateTime.now();
      if (_lastShake == null ||
          now.difference(_lastShake!) >= debounce) {
        _lastShake = now;
        onShake();
      }
    }
  }

  /// Pause shake detection (e.g., while refresh is running).
  void pause() {
    _active = false;
  }

  /// Resume after a pause.
  void resume() {
    _active = _sub != null;
  }

  /// Stop listening entirely.
  void stop() {
    _active = false;
    _sub?.cancel();
    _sub = null;
    _lastEvent = null;
    _lastShake = null;
  }
}
