/// A star with equatorial coordinates.
class Star {
  final String name;
  /// Right Ascension in hours (0-24)
  final double raHours;
  /// Declination in degrees (-90 to +90)
  final double decDegrees;
  /// Apparent magnitude (lower = brighter)
  final double magnitude;

  const Star({
    required this.name,
    required this.raHours,
    required this.decDegrees,
    required this.magnitude,
  });

  /// RA in radians
  double get raRadians => raHours * (3.141592653589793 / 12.0);

  /// Dec in radians
  double get decRadians => decDegrees * (3.141592653589793 / 180.0);
}
