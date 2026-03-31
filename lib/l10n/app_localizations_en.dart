// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cosmic Explorer';

  @override
  String get homeTabTitle => 'Home';

  @override
  String get planetsTabTitle => 'Planets';

  @override
  String get constellationsTabTitle => 'Stars';

  @override
  String get quizTabTitle => 'Quiz';

  @override
  String get favoritesTabTitle => 'Favorites';

  @override
  String get homeHeaderTitle => '🌌 Cosmic Explorer';

  @override
  String get homeHeaderSubtitle => 'Ready to explore the universe?';

  @override
  String get skyMapFeatureTitle => 'Live Sky Map';

  @override
  String get skyMapFeatureSubtitle =>
      'Point your phone to the sky, discover constellations';

  @override
  String get startBtn => 'Start →';

  @override
  String get quizQuickActionTitle => 'Test Your Astronomy Knowledge';

  @override
  String get deepSpaceQuickActionTitle => 'Deep Space';

  @override
  String get dailyFactTitle => 'Space Fact of the Day';

  @override
  String get skyMapScreenTitle => 'Sky Map';

  @override
  String get skyMapLoadingSensors => 'Preparing sensors...';

  @override
  String get skyMapLocationError =>
      'Could not get location, using default location.';

  @override
  String get skyMapCalibrationHint =>
      'Calibration: Wave your phone in a figure-8 motion a few times, then point it to the sky.';

  @override
  String get skyMapCompassN => '🧭 North (N)';

  @override
  String get skyMapCompassNE => '🧭 Northeast (NE)';

  @override
  String get skyMapCompassE => '🧭 East (E)';

  @override
  String get skyMapCompassSE => '🧭 Southeast (SE)';

  @override
  String get skyMapCompassS => '🧭 South (S)';

  @override
  String get skyMapCompassSW => '🧭 Southwest (SW)';

  @override
  String get skyMapCompassW => '🧭 West (W)';

  @override
  String get skyMapCompassNW => '🧭 Northwest (NW)';

  @override
  String get skyMapSunLabel => '☀ Sun';

  @override
  String get skyMapMoonLabel => '🌙 Moon';

  @override
  String get skyMapHorizonLabel => '─── Horizon ───';
}
