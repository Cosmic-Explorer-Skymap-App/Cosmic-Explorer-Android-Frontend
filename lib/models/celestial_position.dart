/// Horizontal coordinate system result.
class CelestialPosition {
  /// Altitude in radians (-π/2 to π/2). Positive = above horizon.
  final double altitude;
  /// Azimuth in radians (0 to 2π). 0 = North, π/2 = East.
  final double azimuth;

  const CelestialPosition({
    required this.altitude,
    required this.azimuth,
  });

  double get altitudeDegrees => altitude * (180.0 / 3.141592653589793);
  double get azimuthDegrees => azimuth * (180.0 / 3.141592653589793);

  bool get isAboveHorizon => altitude > 0;
}
