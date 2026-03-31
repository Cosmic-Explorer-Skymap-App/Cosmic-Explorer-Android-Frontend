import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/data/constellations_data.dart';

void main() {
  group('Constellations Data', () {
    test('should have at least 5 constellations', () {
      expect(constellationsData.length, greaterThanOrEqualTo(5));
    });

    test('all constellations should have unique names', () {
      final names = constellationsData.map((c) => c.name).toSet();
      expect(names.length, constellationsData.length);
    });

    test('all constellations should have at least 2 stars', () {
      for (final c in constellationsData) {
        expect(c.stars.length, greaterThanOrEqualTo(2),
            reason: '${c.name} should have at least 2 stars');
      }
    });

    test('all constellations should have at least 1 line', () {
      for (final c in constellationsData) {
        expect(c.lines.isNotEmpty, true,
            reason: '${c.name} should have at least 1 connecting line');
      }
    });

    test('line indices should be valid star indices', () {
      for (final c in constellationsData) {
        for (final line in c.lines) {
          expect(line.length, 2,
              reason: '${c.name}: each line should have exactly 2 indices');
          expect(line[0], lessThan(c.stars.length),
              reason: '${c.name}: line index ${line[0]} out of range');
          expect(line[1], lessThan(c.stars.length),
              reason: '${c.name}: line index ${line[1]} out of range');
        }
      }
    });

    test('all stars should have valid RA (0-24 hours)', () {
      for (final c in constellationsData) {
        for (final s in c.stars) {
          expect(s.raHours, greaterThanOrEqualTo(0),
              reason: '${c.name}/${s.name}: RA should be >= 0');
          expect(s.raHours, lessThan(24),
              reason: '${c.name}/${s.name}: RA should be < 24');
        }
      }
    });

    test('all stars should have valid Dec (-90 to +90 degrees)', () {
      for (final c in constellationsData) {
        for (final s in c.stars) {
          expect(s.decDegrees, greaterThanOrEqualTo(-90),
              reason: '${c.name}/${s.name}: Dec should be >= -90');
          expect(s.decDegrees, lessThanOrEqualTo(90),
              reason: '${c.name}/${s.name}: Dec should be <= 90');
        }
      }
    });

    test('all constellations should have non-empty stories and mythology', () {
      for (final c in constellationsData) {
        expect(c.story.length, greaterThan(50),
            reason: '${c.name} should have a meaningful story');
        expect(c.mythology.length, greaterThan(50),
            reason: '${c.name} should have meaningful mythology');
      }
    });

    test('all constellations should have a best season', () {
      final validSeasons = ['İlkbahar', 'Yaz', 'Sonbahar', 'Kış'];
      for (final c in constellationsData) {
        expect(validSeasons.contains(c.bestSeason), true,
            reason: '${c.name}: "${c.bestSeason}" is not a valid season');
      }
    });
  });
}
