import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Accurate device orientation service using a 3D rotation matrix.
///
/// Computes the exact 3D orientation of the device (roll, pitch, yaw) 
/// so the sky globe can be correctly rotated, matching the camera 
/// line of sight (-Z axis) and the user's screen plane.
class SensorService {
  double _smoothAz = 0.0; // UI display
  double _smoothAlt = 0.0; // UI display

  // Smoothed sensor values
  double _ax = 0, _ay = 0, _az = -9.8;
  double _mx = 20, _my = 0, _mz = -40;

  // Smoothed basis vectors (World axes in Device frame)
  List<double> _E = [1, 0, 0];
  List<double> _N = [0, 1, 0];
  List<double> _U = [0, 0, 1];

  bool _initialized = false;
  StreamSubscription? _accelSub;
  StreamSubscription? _magSub;

  static const double _sensorAlpha = 0.15;
  static const double _orientAlpha = 0.3;

  double get azimuth => _smoothAz;
  double get altitude => _smoothAlt;
  
  List<double> get E => _E;
  List<double> get N => _N;
  List<double> get U => _U;

  void start() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _ax += _sensorAlpha * (e.x - _ax);
      _ay += _sensorAlpha * (e.y - _ay);
      _az += _sensorAlpha * (e.z - _az);
      _computeOrientation();
    });

    _magSub = magnetometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _mx += _sensorAlpha * (e.x - _mx);
      _my += _sensorAlpha * (e.y - _my);
      _mz += _sensorAlpha * (e.z - _mz);
      _computeOrientation();
    });
  }

  void _computeOrientation() {
    // ── Up vector (Normalized Accelerometer) ─────────────────
    // At rest on table -> [0,0,9.8]. We want U=[0,0,1].
    final lenA = sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (lenA < 0.1) return;
    double ux = _ax / lenA;
    double uy = _ay / lenA;
    double uz = _az / lenA;

    // ── East = M x U ───────────────────────────────────────
    double ex = _my * uz - _mz * uy;
    double ey = _mz * ux - _mx * uz;
    double ez = _mx * uy - _my * ux;
    final lenE = sqrt(ex * ex + ey * ey + ez * ez);
    if (lenE < 0.01) return;
    ex /= lenE;
    ey /= lenE;
    ez /= lenE;

    // ── North = U x East ───────────────────────────────────
    double nx = uy * ez - uz * ey;
    double ny = uz * ex - ux * ez;
    double nz = ux * ey - uy * ex;

    // Line of sight is device -Z axis (out the back of the camera)
    // Vector in world ENU:
    // v_E = [0,0,-1] • E = -ez
    // v_N = [0,0,-1] • N = -nz
    // v_U = [0,0,-1] • U = -uz
    double wE = -ez;
    double wN = -nz;
    double wU = -uz;

    final hLen = sqrt(wE * wE + wN * wN);
    double rawAlt = atan2(wU, hLen);
    
    // Azimuth of the center of screen (North->East)
    double rawAz = atan2(wE, wN);
    if (rawAz < 0) rawAz += 2 * pi;

    if (!_initialized) {
      _E = [ex, ey, ez];
      _N = [nx, ny, nz];
      _U = [ux, uy, uz];
      _smoothAz = rawAz;
      _smoothAlt = rawAlt;
      _initialized = true;
      return;
    }

    // Smooth vectors uniformly
    _E[0] += _orientAlpha * (ex - _E[0]);
    _E[1] += _orientAlpha * (ey - _E[1]);
    _E[2] += _orientAlpha * (ez - _E[2]);

    _N[0] += _orientAlpha * (nx - _N[0]);
    _N[1] += _orientAlpha * (ny - _N[1]);
    _N[2] += _orientAlpha * (nz - _N[2]);

    _U[0] += _orientAlpha * (ux - _U[0]);
    _U[1] += _orientAlpha * (uy - _U[1]);
    _U[2] += _orientAlpha * (uz - _U[2]);

    // Re-normalize smoothed vectors
    for (var vec in [_E, _N, _U]) {
      double l = sqrt(vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2]);
      if (l > 0) {
        vec[0] /= l; vec[1] /= l; vec[2] /= l;
      }
    }

    _smoothAlt += _orientAlpha * (rawAlt - _smoothAlt);

    var dAz = rawAz - _smoothAz;
    if (dAz > pi) dAz -= 2 * pi;
    if (dAz < -pi) dAz += 2 * pi;
    _smoothAz += _orientAlpha * dAz;
    if (_smoothAz < 0) _smoothAz += 2 * pi;
    if (_smoothAz >= 2 * pi) _smoothAz -= 2 * pi;
  }

  void stop() {
    _accelSub?.cancel();
    _magSub?.cancel();
  }
}
