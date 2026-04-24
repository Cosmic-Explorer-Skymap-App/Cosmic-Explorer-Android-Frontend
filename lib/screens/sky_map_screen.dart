import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../data/constellations_data.dart';
import '../models/constellation.dart';
import '../services/astronomy_math.dart';
import '../services/sensor_service.dart';
import '../services/location_service.dart';
import '../data/planets_data.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';
import '../services/iss_service.dart';
import '../models/celestial_position.dart';

class SkyMapScreen extends StatefulWidget {
  const SkyMapScreen({super.key});

  @override
  State<SkyMapScreen> createState() => _SkyMapScreenState();
}

class _SkyMapScreenState extends State<SkyMapScreen> {
  final SensorService _sensor = SensorService();
  double? _lat, _lon;
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  Timer? _issTimer;
  bool _showCalibrationHint = true;
  CelestialPosition? _issPos;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _sensor.start();

    final pos = await LocationService.getCurrentPosition();
    _lat = pos?.latitude ?? 41.0082;
    _lon = pos?.longitude ?? 28.9784;
    
    if (pos == null && mounted) {
      _error = AppLocalizations.of(context)!.skyMapLocationError;
    }

    // Initial ISS fetch
    await _fetchIss();

    setState(() => _loading = false);

    // Refresh UI at ~30fps
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (mounted) setState(() {});
    });

    // Fetch ISS every 5 seconds
    _issTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchIss());

    // Hide calibration hint after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _showCalibrationHint = false);
    });
  }

  @override
  void dispose() {
    _sensor.stop();
    _refreshTimer?.cancel();
    _issTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchIss() async {
    final data = await IssService.getCurrentLocation();
    if (data != null && _lat != null && _lon != null) {
      final pos = AstronomyMath.satelliteHorizontal(
        satLatDeg: data['latitude'],
        satLonDeg: data['longitude'],
        satAltKm: data['altitude'],
        obsLatDeg: _lat!,
        obsLonDeg: _lon!,
      );
      if (mounted) {
        setState(() {
          _issPos = pos;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.skyMapScreenTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.skyMapLoadingSensors,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    // Premium lock removed as per user request

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Sky canvas
          CustomPaint(
            painter: _SkyPainter(
              constellations: constellationsData,
              deviceAz: _sensor.azimuth,
              deviceAlt: _sensor.altitude,
              E: _sensor.E,
              N: _sensor.N,
              U: _sensor.U,
              lat: _lat!,
              lon: _lon!,
              dateTime: DateTime.now().toUtc(),
              l10n: AppLocalizations.of(context)!,
              langCode: Localizations.localeOf(context).languageCode,
              issPos: _issPos,
            ),
            size: Size.infinite,
          ),

          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Back button & info
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Az: ${(_sensor.azimuth * 180 / pi).toStringAsFixed(0)}°  '
                      'Alt: ${(_sensor.altitude * 180 / pi).toStringAsFixed(0)}°',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Calibration hint
          if (_showCalibrationHint)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SpaceTheme.nebulaPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: SpaceTheme.nebulaPurple.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.skyMapCalibrationHint,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error banner
          if (_error != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _error!,
                  style:
                      const TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Compass direction
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: SpaceTheme.nebulaPurple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _compassDirection(context, _sensor.azimuth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _compassDirection(BuildContext context, double azRad) {
    final l10n = AppLocalizations.of(context)!;
    final deg = (azRad * 180 / pi) % 360;
    if (deg < 22.5 || deg >= 337.5) return l10n.skyMapCompassN;
    if (deg < 67.5) return l10n.skyMapCompassNE;
    if (deg < 112.5) return l10n.skyMapCompassE;
    if (deg < 157.5) return l10n.skyMapCompassSE;
    if (deg < 202.5) return l10n.skyMapCompassS;
    if (deg < 247.5) return l10n.skyMapCompassSW;
    if (deg < 292.5) return l10n.skyMapCompassW;
    return l10n.skyMapCompassNW;
  }
}

/// CustomPainter that renders constellations, Sun, and Moon.
class _SkyPainter extends CustomPainter {
  final List<Constellation> constellations;
  final double deviceAz;
  final double deviceAlt;
  final List<double> E;
  final List<double> N;
  final List<double> U;
  final double lat, lon;
  final DateTime dateTime;
  final AppLocalizations l10n;
  final String langCode;
  final CelestialPosition? issPos;

  _SkyPainter({
    required this.constellations,
    required this.deviceAz,
    required this.deviceAlt,
    required this.E,
    required this.N,
    required this.U,
    required this.lat,
    required this.lon,
    required this.dateTime,
    required this.l10n,
    required this.langCode,
    this.issPos,
  });

  static const double _fovRad = 70 * pi / 180;

  /// Project a celestial point (alt, az) to screen coordinates.
  /// Uses true 3D rotation matrix from SensorService vectors (E, N, U).
  /// Returns null if the point is behind the camera.
  Offset? _project(double alt, double az, Size size, double scale) {
    // 1. Star vector in World ENU (East, North, Up)
    double sx = cos(alt) * sin(az); 
    double sy = cos(alt) * cos(az); 
    double sz = sin(alt);           

    // 2. Project onto device axes (since E, N, U are world axes expressed in device frame)
    // dx = Right (+X), dy = Top (+Y), dz = Out of screen (+Z)
    double dx = sx * E[0] + sy * N[0] + sz * U[0];
    double dy = sx * E[1] + sy * N[1] + sz * U[1];
    double dz = sx * E[2] + sy * N[2] + sz * U[2];

    // 3. Visibility check (Z < 0 means in front of the back camera)
    if (dz >= 0) return null;

    // 4. Perspective projection onto Z = -1 plane
    // In Flutter, +X is right, but +Y is DOWN (opposite of device dy)
    double px = dx / -dz;
    double py = dy / -dz;

    double screenX = size.width / 2 + px * scale;
    double screenY = size.height / 2 - py * scale; // Invert Y

    // Filter points too far off-screen
    if (screenX < -150 || screenX > size.width + 150 || screenY < -150 || screenY > size.height + 150) {
      return null;
    }
    return Offset(screenX, screenY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lstH = AstronomyMath.lst(dateTime, lon);
    final scale = size.width / (2 * tan(_fovRad / 2));

    final starPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 10,
    );
    final constellationLabelStyle = TextStyle(
      color: SpaceTheme.stellarGold.withValues(alpha: 0.8),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    // ─── Draw constellations ─────────────────────────────────
    for (final c in constellations) {
      final List<Offset?> screenPositions = [];
      bool anyVisible = false;

      for (final star in c.stars) {
        final pos = AstronomyMath.equatorialToHorizontal(
          raHours: star.raHours,
          decDegrees: star.decDegrees,
          latDeg: lat,
          lstHours: lstH,
        );

        final sp = _project(pos.altitude, pos.azimuth, size, scale);
        screenPositions.add(sp);
        if (sp != null) anyVisible = true;
      }

      if (!anyVisible) continue;

      // Lines
      for (final line in c.lines) {
        final p1 = screenPositions[line[0]];
        final p2 = screenPositions[line[1]];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, linePaint);
        }
      }

      // Stars
      for (int i = 0; i < c.stars.length; i++) {
        final sp = screenPositions[i];
        if (sp == null) continue;

        final star = c.stars[i];
        final radius = (4.0 - star.magnitude * 0.6).clamp(1.5, 5.0);

        // Glow
        starPaint.color = Colors.white.withValues(alpha: 0.12);
        canvas.drawCircle(sp, radius * 2.5, starPaint);

        // Core
        starPaint.color = Colors.white;
        canvas.drawCircle(sp, radius, starPaint);

        // Label
        if (star.name.isNotEmpty && star.magnitude < 2.5) {
          final tp = TextPainter(
            text: TextSpan(text: star.name, style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, sp + Offset(radius + 4, -tp.height / 2));
        }
      }

      // Constellation label
      final visiblePositions = screenPositions.whereType<Offset>().toList();
      if (visiblePositions.isNotEmpty) {
        double cx = 0, cy = 0;
        for (final p in visiblePositions) {
          cx += p.dx;
          cy += p.dy;
        }
        cx /= visiblePositions.length;
        cy /= visiblePositions.length;

        final tp = TextPainter(
          text: TextSpan(text: c.name, style: constellationLabelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - 20 - tp.height));
      }
    }

    // ─── Draw Messier Objects ─────────────────────────────────
    final messierPaint = Paint()..style = PaintingStyle.fill;
    
    for (final m in famousMessiers) {
      final pos = AstronomyMath.equatorialToHorizontal(
        raHours: m.raHours,
        decDegrees: m.decDegrees,
        latDeg: lat,
        lstHours: lstH,
      );

      final sp = _project(pos.altitude, pos.azimuth, size, scale);
      if (sp == null) continue;

      final radius = (6.0 - m.magnitude * 0.4).clamp(2.0, 10.0);

      // Outer Glow
      messierPaint.color = const Color(0xFF00E5FF).withValues(alpha: 0.15);
      messierPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(sp, (radius * 3.0).clamp(2.0, 30.0), messierPaint);

      // Core (fuzz)
      messierPaint.color = const Color(0xFF84FFFF).withValues(alpha: 0.4);
      messierPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(sp, radius.clamp(2.0, 10.0), messierPaint);
      
      messierPaint.maskFilter = null; // Cleanup
      
      final tp = TextPainter(
        text: TextSpan(
            text: "${m.id} (${m.name})", 
            style: TextStyle(
              color: const Color(0xFF84FFFF).withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, sp + Offset(radius.clamp(2.0, 10.0) + 4, -tp.height / 2));
    }

    // ─── Draw Planets ─────────────────────────────────────────
    final planets = getPlanetsData(langCode);
    final planetPaint = Paint()..style = PaintingStyle.fill;
    
    for (final p in planets) {
      if (p.id == 'earth') continue; // Earth is where we are

      final pos = AstronomyMath.planetHorizontal(
        planetId: p.id,
        latDeg: lat,
        lonDeg: lon,
        dateTime: dateTime,
      );

      final sp = _project(pos.altitude, pos.azimuth, size, scale);
      if (sp == null) continue;

      // Make inner planets slightly larger for visibility
      final radius = p.id == 'jupiter' ? 6.0 : p.id == 'venus' ? 5.5 : p.id == 'saturn' ? 5.0 : 4.0;
      final color1 = Color(p.colors[0]);
      final color2 = Color(p.colors.length > 1 ? p.colors[1] : p.colors[0]);
      
      // Glow
      planetPaint.color = color1.withValues(alpha: 0.3);
      planetPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(sp, radius * 2.5, planetPaint);

      // Core
      planetPaint.color = color2;
      planetPaint.maskFilter = null;
      canvas.drawCircle(sp, radius, planetPaint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
            text: p.name,
            style: TextStyle(
              color: color1.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, sp + Offset(radius + 4, -tp.height / 2));
    }

    // ─── Draw Sun ────────────────────────────────────────────
    final sunPos = AstronomyMath.sunHorizontal(
      latDeg: lat, lonDeg: lon, dateTime: dateTime,
    );
    final sunScreen = _project(sunPos.altitude, sunPos.azimuth, size, scale);
    if (sunScreen != null) {
      // Outer glow
      final sunGlow = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      canvas.drawCircle(sunScreen, 40, sunGlow);

      // Medium glow
      sunGlow.color = const Color(0xFFFFD54F).withValues(alpha: 0.3);
      sunGlow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(sunScreen, 18, sunGlow);

      // Core
      final sunCore = Paint()..color = const Color(0xFFFFE082);
      canvas.drawCircle(sunScreen, 10, sunCore);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: l10n.skyMapSunLabel,
          style: TextStyle(
            color: const Color(0xFFFFD54F),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, sunScreen + Offset(-tp.width / 2, 16));
    }

    // ─── Draw Moon ───────────────────────────────────────────
    final moonPos = AstronomyMath.moonHorizontal(
      latDeg: lat, lonDeg: lon, dateTime: dateTime,
    );
    final moonScreen =
        _project(moonPos.altitude, moonPos.azimuth, size, scale);
    if (moonScreen != null) {
      // Outer glow
      final moonGlow = Paint()
        ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(moonScreen, 30, moonGlow);

      // Moon body
      final moonPaint = Paint()..color = const Color(0xFFECEFF1);
      canvas.drawCircle(moonScreen, 9, moonPaint);

      // Subtle darker edge for depth
      final moonEdge = Paint()
        ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(moonScreen, 9, moonEdge);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: l10n.skyMapMoonLabel,
          style: TextStyle(
            color: const Color(0xFFB0BEC5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, moonScreen + Offset(-tp.width / 2, 14));
    }

    // ─── Draw ISS ────────────────────────────────────────────
    if (issPos != null) {
      final issScreen = _project(issPos!.altitude, issPos!.azimuth, size, scale);
      if (issScreen != null) {
        final issPaint = Paint()..style = PaintingStyle.fill;
        
        // Glow
        issPaint.color = Colors.lightBlueAccent.withValues(alpha: 0.3);
        issPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(issScreen, 12, issPaint);

        // Core
        issPaint.color = Colors.white;
        issPaint.maskFilter = null;
        canvas.drawCircle(issScreen, 4, issPaint);

        // Label
        final tp = TextPainter(
          text: const TextSpan(
            text: "ISS",
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, issScreen + Offset(-tp.width / 2, 10));
        
        // Satellite Emoji
        TextPainter(
          text: const TextSpan(text: '🛰️', style: TextStyle(fontSize: 16)),
          textDirection: TextDirection.ltr,
        )..layout()..paint(canvas, issScreen + Offset(-10, -26));
      }
    }

    // ─── Horizon line ────────────────────────────────────────
    // Draw horizon dynamically matching curved 3D projection
    final horizonPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Path horizonPath = Path();
    bool isFirst = true;

    for (int azDeg = 0; azDeg <= 360; azDeg += 4) {
      final double az = azDeg * pi / 180.0;
      final pt = _project(0.0, az, size, scale);
      
      if (pt != null) {
        if (isFirst) {
          horizonPath.moveTo(pt.dx, pt.dy);
          isFirst = false;
        } else {
          horizonPath.lineTo(pt.dx, pt.dy);
        }
      } else {
        isFirst = true;
      }
    }
    canvas.drawPath(horizonPath, horizonPaint);

    // Label for Horizon at the center AZ
    final centerHorizon = _project(0.0, deviceAz, size, scale);
    if (centerHorizon != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: l10n.skyMapHorizonLabel,
          style: TextStyle(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(centerHorizon.dx - tp.width / 2, centerHorizon.dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => true;
}

class FamousMessier {
  final String id;
  final String name;
  final double raHours;
  final double decDegrees;
  final double magnitude;

  const FamousMessier({
    required this.id,
    required this.name,
    required this.raHours,
    required this.decDegrees,
    required this.magnitude,
  });
}

const List<FamousMessier> famousMessiers = [
  FamousMessier(id: "M31", name: "Andromeda", raHours: 0.712, decDegrees: 41.27, magnitude: 3.4),
  FamousMessier(id: "M42", name: "Orion Bulutsusu", raHours: 5.588, decDegrees: -5.39, magnitude: 4.0),
  FamousMessier(id: "M45", name: "Pleiades (Ülker)", raHours: 3.79, decDegrees: 24.11, magnitude: 1.6),
  FamousMessier(id: "M13", name: "Herkül Kümesi", raHours: 16.695, decDegrees: 36.46, magnitude: 5.8),
  FamousMessier(id: "M51", name: "Girdap Galaksisi", raHours: 13.498, decDegrees: 47.19, magnitude: 8.4),
];

