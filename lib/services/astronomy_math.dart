import 'dart:math';
import '../models/star.dart';
import '../models/celestial_position.dart';

/// Core astronomical calculations for the sky map.
///
/// All angles in radians unless stated otherwise.
/// Uses standard IAU/Meeus formulas.
class AstronomyMath {
  AstronomyMath._();

  static const double _deg2rad = pi / 180.0;
  static const double _rad2deg = 180.0 / pi;

  /// Julian Date from a [DateTime] (UTC).
  ///
  /// Meeus, Astronomical Algorithms, Ch. 7.
  static double julianDate(DateTime dt) {
    final utc = dt.toUtc();
    int y = utc.year;
    int m = utc.month;
    final double d = utc.day +
        utc.hour / 24.0 +
        utc.minute / 1440.0 +
        utc.second / 86400.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final int a = y ~/ 100;
    final int b = 2 - a + a ~/ 4;

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  /// Greenwich Mean Sidereal Time in hours (0-24).
  ///
  /// Meeus, Ch. 12.
  static double gmst(DateTime dt) {
    final jd = julianDate(dt);
    final t = (jd - 2451545.0) / 36525.0; // Julian centuries from J2000.0
    var siderealDeg = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    siderealDeg = siderealDeg % 360.0;
    if (siderealDeg < 0) siderealDeg += 360.0;
    return siderealDeg / 15.0; // convert degrees to hours
  }

  /// Local Sidereal Time in hours (0-24).
  ///
  /// [longitudeDeg] is the observer's longitude in degrees (East positive).
  static double lst(DateTime dt, double longitudeDeg) {
    var result = gmst(dt) + longitudeDeg / 15.0;
    result = result % 24.0;
    if (result < 0) result += 24.0;
    return result;
  }

  /// Hour Angle in radians.
  ///
  /// [lstHours] is local sidereal time in hours.
  /// [raHours] is right ascension in hours.
  static double hourAngle(double lstHours, double raHours) {
    var ha = (lstHours - raHours) * 15.0 * _deg2rad; // convert to radians
    // Normalize to -π .. π
    while (ha > pi) { ha -= 2 * pi; }
    while (ha < -pi) { ha += 2 * pi; }
    return ha;
  }

  /// Convert equatorial coordinates (RA, Dec) to horizontal (Alt, Az).
  ///
  /// [latDeg] observer latitude in degrees.
  /// [lstHours] local sidereal time in hours.
  /// Returns [CelestialPosition] with altitude and azimuth in radians.
  static CelestialPosition equatorialToHorizontal({
    required double raHours,
    required double decDegrees,
    required double latDeg,
    required double lstHours,
  }) {
    final dec = decDegrees * _deg2rad;
    final lat = latDeg * _deg2rad;
    final ha = hourAngle(lstHours, raHours);

    // Altitude
    final sinAlt = sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha);
    final alt = asin(sinAlt.clamp(-1.0, 1.0));

    // Azimuth
    final cosAz = (sin(dec) - sin(alt) * sin(lat)) / (cos(alt) * cos(lat));
    var az = acos(cosAz.clamp(-1.0, 1.0));
    if (sin(ha) > 0) {
      az = 2 * pi - az;
    }

    return CelestialPosition(altitude: alt, azimuth: az);
  }

  /// Convert a [Star] to horizontal coordinates.
  static CelestialPosition starToHorizontal({
    required Star star,
    required double latDeg,
    required double lonDeg,
    required DateTime dateTime,
  }) {
    final lstH = lst(dateTime, lonDeg);
    return equatorialToHorizontal(
      raHours: star.raHours,
      decDegrees: star.decDegrees,
      latDeg: latDeg,
      lstHours: lstH,
    );
  }

  /// Gnomonic (tangent-plane) projection.
  ///
  /// Projects a point on the celestial sphere onto a flat plane tangent
  /// at the point where the device is pointing.
  ///
  /// [targetAlt], [targetAz] — where the point is (radians).
  /// [centerAlt], [centerAz] — where the device is pointing (radians).
  ///
  /// Returns (x, y) in radians; x positive = right, y positive = up.
  /// Returns null if the point is behind the projection plane (> 90° away).
  static ({double x, double y})? gnomonicProject({
    required double targetAlt,
    required double targetAz,
    required double centerAlt,
    required double centerAz,
  }) {
    // Angular separation
    final cosC = sin(centerAlt) * sin(targetAlt) +
        cos(centerAlt) * cos(targetAlt) * cos(targetAz - centerAz);

    if (cosC <= 0.0) return null; // Behind the observer

    final x = (cos(targetAlt) * sin(targetAz - centerAz)) / cosC;
    final y = (cos(centerAlt) * sin(targetAlt) -
            sin(centerAlt) * cos(targetAlt) * cos(targetAz - centerAz)) /
        cosC;

    return (x: -x, y: y); // Negate x so east is right on screen
  }

  /// Angular separation between two points on the celestial sphere (radians).
  static double angularSeparation(
    double alt1, double az1, double alt2, double az2,
  ) {
    final cosD = sin(alt1) * sin(alt2) +
        cos(alt1) * cos(alt2) * cos(az1 - az2);
    return acos(cosD.clamp(-1.0, 1.0));
  }

  // ──────────────────────────────────────────────────────────
  //  Sun position  (simplified Meeus, Ch. 25)
  // ──────────────────────────────────────────────────────────

  /// Returns Sun equatorial coordinates as (raHours, decDegrees).
  static ({double raHours, double decDegrees}) sunPosition(DateTime dt) {
    final jd = julianDate(dt.toUtc());
    final t = (jd - 2451545.0) / 36525.0;

    // Geometric mean longitude (deg)
    var l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    l0 = l0 % 360;

    // Mean anomaly (deg)
    var m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    m = m % 360;
    final mRad = m * _deg2rad;

    // Equation of center (deg)
    final c = (1.914602 - 0.004817 * t) * sin(mRad) +
        (0.019993 - 0.000101 * t) * sin(2 * mRad) +
        0.000289 * sin(3 * mRad);

    // Sun true longitude (deg)
    final sunLon = (l0 + c) % 360;

    // Apparent longitude (correcting for nutation, simplified)
    final omega = 125.04 - 1934.136 * t;
    final lambda = (sunLon - 0.00569 - 0.00478 * sin(omega * _deg2rad));
    final lambdaRad = lambda * _deg2rad;

    // Obliquity of ecliptic (deg)
    final eps0 = 23.439291 - 0.013004 * t;
    final eps = (eps0 + 0.00256 * cos(omega * _deg2rad)) * _deg2rad;

    // RA, Dec from ecliptic longitude (ecliptic lat ≈ 0 for Sun)
    final ra = atan2(cos(eps) * sin(lambdaRad), cos(lambdaRad));
    final dec = asin(sin(eps) * sin(lambdaRad));

    var raH = (ra * _rad2deg / 15.0) % 24;
    if (raH < 0) raH += 24;

    return (raHours: raH, decDegrees: dec * _rad2deg);
  }

  /// Returns Sun horizontal position for given observer.
  static CelestialPosition sunHorizontal({
    required double latDeg,
    required double lonDeg,
    required DateTime dateTime,
  }) {
    final sun = sunPosition(dateTime);
    final lstH = lst(dateTime.toUtc(), lonDeg);
    return equatorialToHorizontal(
      raHours: sun.raHours,
      decDegrees: sun.decDegrees,
      latDeg: latDeg,
      lstHours: lstH,
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Moon position  (simplified Meeus, Ch. 47 — low precision)
  // ──────────────────────────────────────────────────────────

  /// Returns Moon equatorial coordinates as (raHours, decDegrees).
  static ({double raHours, double decDegrees}) moonPosition(DateTime dt) {
    final jd = julianDate(dt.toUtc());
    final t = (jd - 2451545.0) / 36525.0;

    // Moon's mean longitude (deg)
    var lp = 218.3165 + 481267.8813 * t;
    lp = lp % 360; if (lp < 0) lp += 360;

    // Moon's mean anomaly (deg)
    var mp = 134.9634 + 477198.8676 * t;
    mp = mp % 360; if (mp < 0) mp += 360;

    // Moon's mean elongation (deg)
    var d = 297.8502 + 445267.1115 * t;
    d = d % 360; if (d < 0) d += 360;

    // Sun's mean anomaly (deg)
    var ms = 357.5291 + 35999.0503 * t;
    ms = ms % 360; if (ms < 0) ms += 360;

    // Moon's argument of latitude (deg)
    var f = 93.2720 + 483202.0175 * t;
    f = f % 360; if (f < 0) f += 360;

    final mpR = mp * _deg2rad;
    final dR = d * _deg2rad;
    final msR = ms * _deg2rad;
    final fR = f * _deg2rad;

    // Longitude correction (major terms, degrees)
    final lonCorr = 6.289 * sin(mpR) +
        1.274 * sin(2 * dR - mpR) +
        0.658 * sin(2 * dR) +
        0.214 * sin(2 * mpR) -
        0.186 * sin(msR) -
        0.114 * sin(2 * fR);

    // Latitude correction (major terms, degrees)
    final latCorr = 5.128 * sin(fR) +
        0.281 * sin(mpR + fR) +
        0.278 * sin(mpR - fR) +
        0.173 * sin(2 * dR - fR);

    final moonLon = (lp + lonCorr) * _deg2rad;
    final moonLat = latCorr * _deg2rad;

    // Obliquity
    final eps = (23.439291 - 0.013004 * t) * _deg2rad;

    // Ecliptic → Equatorial
    final ra = atan2(
      sin(moonLon) * cos(eps) - tan(moonLat) * sin(eps),
      cos(moonLon),
    );
    final dec = asin(
      (sin(moonLat) * cos(eps) + cos(moonLat) * sin(eps) * sin(moonLon))
          .clamp(-1.0, 1.0),
    );

    var raH = (ra * _rad2deg / 15.0) % 24;
    if (raH < 0) raH += 24;

    return (raHours: raH, decDegrees: dec * _rad2deg);
  }

  /// Returns Moon horizontal position for given observer.
  static CelestialPosition moonHorizontal({
    required double latDeg,
    required double lonDeg,
    required DateTime dateTime,
  }) {
    final moon = moonPosition(dateTime);
    final lstH = lst(dateTime.toUtc(), lonDeg);
    return equatorialToHorizontal(
      raHours: moon.raHours,
      decDegrees: moon.decDegrees,
      latDeg: latDeg,
      lstHours: lstH,
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Planets position  (approximate Keplerian elements for epoch J2000.0)
  // ──────────────────────────────────────────────────────────

  /// Compute Geocentric coordinates for a planet.
  static ({double raHours, double decDegrees}) planetPosition(
      String planetId, DateTime dt) {
    if (planetId == 'earth') {
      return sunPosition(dt);
    }

    final d = julianDate(dt.toUtc()) - 2451545.0; // days since J2000.0
    
    // Orbital elements: N = Long of ascending node, i = Inclination, w = Argument of perihelion,
    // a = Mean distance (AU), e = Eccentricity, M = Mean anomaly
    double N = 0, i = 0, w = 0, a = 1, e = 0, M = 0;
    
    switch (planetId) {
      case 'mercury':
        N = 48.3313 + 3.24587E-5 * d; i = 7.0047 + 5.00E-8 * d;
        w = 29.1241 + 1.01444E-5 * d; a = 0.387098;
        e = 0.205635 + 5.59E-10 * d; M = 168.6562 + 4.0923344368 * d;
        break;
      case 'venus':
        N = 76.6799 + 2.46590E-5 * d; i = 3.3946 + 2.75E-8 * d;
        w = 54.8910 + 1.38374E-5 * d; a = 0.723330;
        e = 0.006773 - 1.302E-9 * d; M = 48.0052 + 1.6021302244 * d;
        break;
      case 'mars':
        N = 49.5574 + 2.11081E-5 * d; i = 1.8497 - 1.78E-8 * d;
        w = 286.5016 + 2.92961E-5 * d; a = 1.523688;
        e = 0.093405 + 2.516E-9 * d; M = 18.6021 + 0.5240207766 * d;
        break;
      case 'jupiter':
        N = 100.4542 + 2.76854E-5 * d; i = 1.3030 - 1.557E-7 * d;
        w = 273.8777 + 1.64505E-5 * d; a = 5.20256;
        e = 0.048498 + 4.469E-9 * d; M = 19.8950 + 0.0830853001 * d;
        break;
      case 'saturn':
        N = 113.6634 + 2.38980E-5 * d; i = 2.4886 - 1.081E-7 * d;
        w = 339.3939 + 2.97661E-5 * d; a = 9.55475;
        e = 0.055546 - 9.499E-9 * d; M = 316.9670 + 0.0334442282 * d;
        break;
      case 'uranus':
        N = 74.0005 + 1.3978E-5 * d; i = 0.7733 + 1.9E-8 * d;
        w = 96.6612 + 3.0565E-5 * d; a = 19.18171 - 1.55E-8 * d;
        e = 0.047318 + 7.45E-9 * d; M = 142.5905 + 0.011725806 * d;
        break;
      case 'neptune':
        N = 131.7806 + 3.0173E-5 * d; i = 1.7700 - 2.55E-7 * d;
        w = 272.8461 - 6.027E-6 * d; a = 30.05826 + 3.313E-8 * d;
        e = 0.008606 + 2.15E-9 * d; M = 260.2471 + 0.005995147 * d;
        break;
      default:
        return (raHours: 0, decDegrees: 0);
    }

    N = N % 360; w = w % 360; M = M % 360;

    double E = M + (180 / pi) * e * sin(M * _deg2rad) * (1.0 + e * cos(M * _deg2rad));
    for (int iter = 0; iter < 10; iter++) {
      double E0 = E;
      double E0rad = E0 * _deg2rad;
      double M0 = E0 - (180 / pi) * e * sin(E0rad);
      E = E0 + (M - M0) / (1 - e * cos(E0rad));
    }

    double Erad = E * _deg2rad;
    double xv = a * (cos(Erad) - e);
    double yv = a * (sqrt(1.0 - e * e) * sin(Erad));

    double v = atan2(yv, xv) * _rad2deg;
    double r = sqrt(xv * xv + yv * yv);

    double v_w = (v + w) * _deg2rad;
    double Nrad = N * _deg2rad;
    double irad = i * _deg2rad;

    double xh = r * (cos(Nrad) * cos(v_w) - sin(Nrad) * sin(v_w) * cos(irad));
    double yh = r * (sin(Nrad) * cos(v_w) + cos(Nrad) * sin(v_w) * cos(irad));
    double zh = r * (sin(v_w) * sin(irad));

    // Sun pos from Earth point of view 
    // (we actually need Earth pos from Sun point of view)
    // Earth orbit:
    double Me = 356.0470 + 0.9856002585 * d;
    Me = Me % 360;
    double we = 282.9404 + 4.70935E-5 * d;
    double ee = 0.016709 - 1.151E-9 * d;
    double ae = 1.0;

    double Ee = Me + (180 / pi) * ee * sin(Me * _deg2rad) * (1.0 + ee * cos(Me * _deg2rad));
    for (int iter = 0; iter < 5; iter++) {
      double E0 = Ee;
      double E0rad = E0 * _deg2rad;
      double M0 = E0 - (180 / pi) * ee * sin(E0rad);
      Ee = E0 + (Me - M0) / (1 - ee * cos(E0rad));
    }

    double Eerad = Ee * _deg2rad;
    double xve = ae * (cos(Eerad) - ee);
    double yve = ae * (sqrt(1.0 - ee * ee) * sin(Eerad));

    double ve = atan2(yve, xve) * _rad2deg;
    double re = sqrt(xve * xve + yve * yve);

    double sunLon = ve + we; // Sun from Earth
    double sunLonRad = sunLon * _deg2rad;

    // Earth from Sun
    double earthLonRad = sunLonRad + pi;
    double xe_sun = re * cos(earthLonRad);
    double ye_sun = re * sin(earthLonRad);
    double ze_sun = 0;

    // Geocentric Ecliptic for Planet
    double xg = xh - xe_sun;
    double yg = yh - ye_sun;
    double zg = zh - ze_sun;

    // Convert to equatorial
    double ecl = 23.439281 * _deg2rad;
    double xe = xg;
    double ye = yg * cos(ecl) - zg * sin(ecl);
    double ze = yg * sin(ecl) + zg * cos(ecl);

    double ra = atan2(ye, xe);
    double dec = atan2(ze, sqrt(xe * xe + ye * ye));

    double raH = (ra * _rad2deg / 15.0) % 24;
    if (raH < 0) raH += 24;

    return (raHours: raH, decDegrees: dec * _rad2deg);
  }

  /// Returns Planet horizontal position for given observer.
  static CelestialPosition planetHorizontal({
    required String planetId,
    required double latDeg,
    required double lonDeg,
    required DateTime dateTime,
  }) {
    final pos = planetPosition(planetId, dateTime);
    final lstH = lst(dateTime.toUtc(), lonDeg);
    return equatorialToHorizontal(
      raHours: pos.raHours,
      decDegrees: pos.decDegrees,
      latDeg: latDeg,
      lstHours: lstH,
    );
  }

  /// Returns Satellite (ISS) horizontal position for given observer.
  ///
  /// [satLatDeg], [satLonDeg] and [satAltKm] are satellite coordinates.
  /// [obsLatDeg], [obsLonDeg] are observer coordinates.
  static CelestialPosition satelliteHorizontal({
    required double satLatDeg,
    required double satLonDeg,
    required double satAltKm,
    required double obsLatDeg,
    required double obsLonDeg,
  }) {
    const double radiusEarth = 6371.0;
    final double obsLat = obsLatDeg * _deg2rad;
    final double obsLon = obsLonDeg * _deg2rad;
    final double satLat = satLatDeg * _deg2rad;
    final double satLon = satLonDeg * _deg2rad;
    final double dLon = satLon - obsLon;

    final double cosC = sin(obsLat) * sin(satLat) +
        cos(obsLat) * cos(satLat) * cos(dLon);
    final double sinC = sqrt(max(0.0, 1.0 - cosC * cosC));

    // Azimuth
    final double az = atan2(
      sin(dLon) * cos(satLat),
      cos(obsLat) * sin(satLat) - sin(obsLat) * cos(satLat) * cos(dLon)
    );

    // Elevation (Altitude)
    final double r_ratio = radiusEarth / (radiusEarth + satAltKm);
    final double alt = atan2(cosC - r_ratio, sinC);

    return CelestialPosition(
      altitude: alt,
      azimuth: (az % (2 * pi)),
    );
  }
}
