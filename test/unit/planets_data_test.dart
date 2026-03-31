import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/data/planets_data.dart';

void main() {
  group('Planets Data', () {
    final planetsData = getPlanetsData('tr');

    test('should have exactly 8 planets', () {
      expect(planetsData.length, 8);
    });

    test('all planets should have non-empty names', () {
      for (final p in planetsData) {
        expect(p.name.isNotEmpty, true, reason: 'Planet name should not be empty');
      }
    });

    test('all planets should have unique names', () {
      final names = planetsData.map((p) => p.name).toSet();
      expect(names.length, planetsData.length);
    });

    test('all planets should have non-empty stories', () {
      for (final p in planetsData) {
        expect(p.story.length, greaterThan(50),
            reason: '${p.name} should have a meaningful story');
      }
    });

    test('all planets should have positive physical values', () {
      for (final p in planetsData) {
        expect(p.distanceFromSunAU, greaterThan(0),
            reason: '${p.name} distance should be positive');
        expect(p.radiusKm, greaterThan(0),
            reason: '${p.name} radius should be positive');
        expect(p.orbitalPeriodDays, greaterThan(0),
            reason: '${p.name} orbital period should be positive');
        expect(p.gravity, greaterThan(0),
            reason: '${p.name} gravity should be positive');
      }
    });

    test('planets should be ordered by distance from Sun', () {
      for (int i = 1; i < planetsData.length; i++) {
        expect(
          planetsData[i].distanceFromSunAU,
          greaterThan(planetsData[i - 1].distanceFromSunAU),
          reason:
              '${planetsData[i].name} should be farther than ${planetsData[i - 1].name}',
        );
      }
    });

    test('distanceDisplay should return valid string', () {
      for (final p in planetsData) {
        final display = p.getDistanceDisplay('AU', 'milyon km');
        expect(display.isNotEmpty, true);
        expect(
          display.contains('km') || display.contains('AU'),
          true,
          reason: '${p.name}: "$display" should contain km or AU',
        );
      }
    });

    test('all planets should have exactly 2 colors', () {
      for (final p in planetsData) {
        expect(p.colors.length, 2,
            reason: '${p.name} should have 2 gradient colors');
      }
    });
  });
}
