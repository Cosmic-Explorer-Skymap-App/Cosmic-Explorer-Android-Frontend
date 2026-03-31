import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/services/astronomy_math.dart';

void main() {
  group('AstronomyMath', () {
    group('julianDate', () {
      test('J2000.0 epoch should return 2451545.0', () {
        // J2000.0 = 2000-01-01 12:00:00 UTC
        final jd = AstronomyMath.julianDate(
          DateTime.utc(2000, 1, 1, 12, 0, 0),
        );
        expect(jd, closeTo(2451545.0, 0.001));
      });

      test('known date: 2024-03-20 00:00 UTC', () {
        final jd = AstronomyMath.julianDate(
          DateTime.utc(2024, 3, 20, 0, 0, 0),
        );
        // Expected JD for 2024-03-20 00:00 UTC ≈ 2460389.5
        expect(jd, closeTo(2460389.5, 0.01));
      });
    });

    group('GMST', () {
      test('GMST at J2000.0 epoch should be ~18.697 hours', () {
        final gmst = AstronomyMath.gmst(
          DateTime.utc(2000, 1, 1, 12, 0, 0),
        );
        // GMST at J2000.0 ≈ 18.697 hours (280.46° / 15)
        expect(gmst, closeTo(18.697, 0.05));
      });

      test('GMST should be between 0 and 24', () {
        final gmst = AstronomyMath.gmst(DateTime.now().toUtc());
        expect(gmst, greaterThanOrEqualTo(0));
        expect(gmst, lessThan(24));
      });
    });

    group('LST', () {
      test('LST at Greenwich (lon=0) should equal GMST', () {
        final dt = DateTime.utc(2024, 6, 15, 20, 0, 0);
        final gmst = AstronomyMath.gmst(dt);
        final lst = AstronomyMath.lst(dt, 0.0);
        expect(lst, closeTo(gmst, 0.001));
      });

      test('LST at Istanbul (lon≈29°) should be GMST + 29/15', () {
        final dt = DateTime.utc(2024, 6, 15, 20, 0, 0);
        final gmst = AstronomyMath.gmst(dt);
        final lst = AstronomyMath.lst(dt, 29.0);
        var expected = gmst + 29.0 / 15.0;
        expected = expected % 24.0;
        expect(lst, closeTo(expected, 0.001));
      });

      test('LST should always be between 0 and 24', () {
        for (int lon = -180; lon <= 180; lon += 30) {
          final lst = AstronomyMath.lst(DateTime.now().toUtc(), lon.toDouble());
          expect(lst, greaterThanOrEqualTo(0));
          expect(lst, lessThan(24));
        }
      });
    });

    group('equatorialToHorizontal', () {
      test('Polaris should be near zenith from North Pole', () {
        // Polaris: RA ≈ 2.53 hrs, Dec ≈ 89.26°
        final dt = DateTime.utc(2024, 6, 15, 0, 0, 0);
        final lstH = AstronomyMath.lst(dt, 0.0);
        final pos = AstronomyMath.equatorialToHorizontal(
          raHours: 2.53,
          decDegrees: 89.26,
          latDeg: 90.0,
          lstHours: lstH,
        );
        // From North Pole, Polaris should be near 89.26° altitude
        expect(pos.altitudeDegrees, closeTo(89.26, 1.0));
      });

      test('star at Dec=0 should transit at alt=90-lat', () {
        // When HA=0, alt = 90 - |lat - dec|
        // For dec=0, lat=41, HA=0: alt = 90 - 41 = 49°
        final pos = AstronomyMath.equatorialToHorizontal(
          raHours: 10.0,
          decDegrees: 0.0,
          latDeg: 41.0,
          lstHours: 10.0, // HA = 0 at transit
        );
        expect(pos.altitudeDegrees, closeTo(49.0, 0.5));
      });

      test('altitude should be in range -90 to 90', () {
        final dt = DateTime.utc(2024, 3, 20, 12, 0, 0);
        final lstH = AstronomyMath.lst(dt, 29.0);
        final pos = AstronomyMath.equatorialToHorizontal(
          raHours: 5.9,
          decDegrees: 7.4,
          latDeg: 41.0,
          lstHours: lstH,
        );
        expect(pos.altitudeDegrees, greaterThanOrEqualTo(-90));
        expect(pos.altitudeDegrees, lessThanOrEqualTo(90));
      });

      test('azimuth should be in range 0 to 360', () {
        final dt = DateTime.utc(2024, 9, 1, 22, 0, 0);
        final lstH = AstronomyMath.lst(dt, 29.0);
        final pos = AstronomyMath.equatorialToHorizontal(
          raHours: 16.49,
          decDegrees: -26.43,
          latDeg: 41.0,
          lstHours: lstH,
        );
        expect(pos.azimuthDegrees, greaterThanOrEqualTo(0));
        expect(pos.azimuthDegrees, lessThanOrEqualTo(360));
      });
    });

    group('gnomonicProject', () {
      test('center point projects to origin', () {
        final proj = AstronomyMath.gnomonicProject(
          targetAlt: 0.5,
          targetAz: 1.0,
          centerAlt: 0.5,
          centerAz: 1.0,
        );
        expect(proj, isNotNull);
        expect(proj!.x, closeTo(0, 0.001));
        expect(proj.y, closeTo(0, 0.001));
      });

      test('point behind observer returns null', () {
        final proj = AstronomyMath.gnomonicProject(
          targetAlt: 0.5,
          targetAz: 0.0,
          centerAlt: 0.5,
          centerAz: 3.14159, // opposite direction
        );
        expect(proj, isNull);
      });

      test('point above center has positive y', () {
        final proj = AstronomyMath.gnomonicProject(
          targetAlt: 1.0,
          targetAz: 1.0,
          centerAlt: 0.5,
          centerAz: 1.0,
        );
        expect(proj, isNotNull);
        expect(proj!.y, greaterThan(0));
      });
    });

    group('angularSeparation', () {
      test('identical points have zero separation', () {
        final sep =
            AstronomyMath.angularSeparation(0.5, 1.0, 0.5, 1.0);
        expect(sep, closeTo(0, 0.001));
      });

      test('opposite points have pi separation', () {
        final sep = AstronomyMath.angularSeparation(
          0.5, 0.0, -0.5, 3.14159,
        );
        // Should be close to pi (but depends on exact values)
        expect(sep, greaterThan(2.5));
      });
    });
  });
}
