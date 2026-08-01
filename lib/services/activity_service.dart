import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

enum ActivityState { idle, walking, running }

/// Detects whether the user is likely running, combining:
/// 1) Accelerometer jerk/variance (fast, works indoors, no GPS lock needed)
/// 2) GPS speed, once available, as a confirming signal
///
/// This is a lightweight heuristic (not a full step-counting/ML pipeline),
/// tuned to be a reasonable trigger for switching into "Active Mode".
class ActivityService extends ChangeNotifier {
  static const int _windowSize = 40; // ~2s at 20Hz-ish sensor rate
  final List<double> _magnitudeWindow = [];

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<Position>? _positionSub;

  ActivityState _state = ActivityState.idle;
  ActivityState get state => _state;

  double _currentSpeedMps = 0; // meters/second from GPS
  double get currentSpeedMps => _currentSpeedMps;

  double _totalDistanceMeters = 0;
  double get totalDistanceMeters => _totalDistanceMeters;

  Position? _lastPosition;
  DateTime? _sessionStart;
  DateTime? get sessionStart => _sessionStart;

  Future<void> start() async {
    _sessionStart ??= DateTime.now();

    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccel);

    final permission = await _ensureLocationPermission();
    if (permission) {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen(_onPosition);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void _onAccel(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    _magnitudeWindow.add(magnitude);
    if (_magnitudeWindow.length > _windowSize) {
      _magnitudeWindow.removeAt(0);
    }
    if (_magnitudeWindow.length >= _windowSize) {
      _evaluateState();
    }
  }

  void _onPosition(Position position) {
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      // Ignore GPS jitter noise below 1m.
      if (distance > 1) {
        _totalDistanceMeters += distance;
      }
    }
    _lastPosition = position;
    _currentSpeedMps = position.speed.clamp(0, 20);
    _evaluateState();
    notifyListeners();
  }

  void _evaluateState() {
    if (_magnitudeWindow.isEmpty) return;

    final mean = _magnitudeWindow.reduce((a, b) => a + b) / _magnitudeWindow.length;
    final variance = _magnitudeWindow
            .map((m) => (m - mean) * (m - mean))
            .reduce((a, b) => a + b) /
        _magnitudeWindow.length;

    // Rough, tunable thresholds: running produces noticeably higher
    // accelerometer variance than walking or being stationary, and (when
    // available) a GPS speed above brisk-walking pace confirms it.
    final bool highVariance = variance > 6.0;
    final bool moderateVariance = variance > 2.0;
    final bool gpsConfirmsRun = _currentSpeedMps > 2.2; // ~8 km/h+
    final bool gpsConfirmsWalk = _currentSpeedMps > 0.8;

    ActivityState next;
    if (highVariance || gpsConfirmsRun) {
      next = ActivityState.running;
    } else if (moderateVariance || gpsConfirmsWalk) {
      next = ActivityState.walking;
    } else {
      next = ActivityState.idle;
    }

    if (next != _state) {
      _state = next;
      notifyListeners();
    }
  }

  double get paceMinPerKm {
    if (_currentSpeedMps <= 0.1) return 0;
    final minPerMeter = 1 / (_currentSpeedMps * 60);
    return minPerMeter * 1000;
  }

  void reset() {
    _totalDistanceMeters = 0;
    _sessionStart = DateTime.now();
    _lastPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}
