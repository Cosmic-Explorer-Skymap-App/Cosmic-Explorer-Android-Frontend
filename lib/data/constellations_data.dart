import '../models/constellation.dart';

// Re-export from all parts
import 'constellations_part1.dart';
import 'constellations_part2.dart';
import 'constellations_part3.dart';
import 'constellations_part4.dart';

/// All 88 IAU Constellations with J2000.0 star coordinates
final List<Constellation> constellationsData = [
  ...constellationsPart1,
  ...constellationsPart2,
  ...constellationsPart3,
  ...constellationsPart4,
];
