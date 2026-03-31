class Planet {
  final String id;
  final String name;
  final String subtitle;
  final String story;
  final String iconEmoji;
  final double distanceFromSunAU;
  final double radiusKm;
  final double orbitalPeriodDays;
  final double gravity;
  final int moons;
  final String funFact;
  final List<int> colors;

  const Planet({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.story,
    required this.iconEmoji,
    required this.distanceFromSunAU,
    required this.radiusKm,
    required this.orbitalPeriodDays,
    required this.gravity,
    required this.moons,
    required this.funFact,
    required this.colors,
  });

  String getDistanceDisplay(String auLabel, String mKmLabel) {
    if (distanceFromSunAU < 1) {
      return '${(distanceFromSunAU * 149.6).toStringAsFixed(1)}$mKmLabel';
    }
    return '${distanceFromSunAU.toStringAsFixed(2)} $auLabel';
  }

  String getRadiusDisplay(String kmLabel) => '${radiusKm.toStringAsFixed(0)} $kmLabel';

  String getOrbitalPeriodDisplay(String dayLabel, String yearLabel) {
    if (orbitalPeriodDays < 365) {
      return '${orbitalPeriodDays.toStringAsFixed(0)} $dayLabel';
    }
    return '${(orbitalPeriodDays / 365.25).toStringAsFixed(1)} $yearLabel';
  }
}
