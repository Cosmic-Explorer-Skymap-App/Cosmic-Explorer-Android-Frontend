// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cosmic Explorer';

  @override
  String get homeTabTitle => 'Startseite';

  @override
  String get planetsTabTitle => 'Planeten';

  @override
  String get constellationsTabTitle => 'Sterne';

  @override
  String get quizTabTitle => 'Quiz';

  @override
  String get favoritesTabTitle => 'Favoriten';

  @override
  String get homeHeaderTitle => '🌌 Cosmic Explorer';

  @override
  String get homeHeaderSubtitle => 'Bereit, das Universum zu erkunden?';

  @override
  String get skyMapFeatureTitle => 'Live-Sternkarte';

  @override
  String get skyMapFeatureSubtitle =>
      'Richte dein Handy in den Himmel und entdecke Sternbilder';

  @override
  String get startBtn => 'Starten →';

  @override
  String get quizQuickActionTitle => 'Teste dein Astronomie-Wissen';

  @override
  String get deepSpaceQuickActionTitle => 'Deep Space';

  @override
  String get dailyFactTitle => 'Tägliche Weltraumfakten';

  @override
  String get skyMapScreenTitle => 'Sternkarte';

  @override
  String get skyMapLoadingSensors => 'Sensoren werden vorbereitet...';

  @override
  String get skyMapLocationError =>
      'Standort konnte nicht ermittelt werden, Standardort wird verwendet.';

  @override
  String get skyMapCalibrationHint =>
      'Kalibrierung: Bewege dein Telefon ein paar Mal in Form einer 8 und halte es dann in den Himmel.';

  @override
  String get skyMapCompassN => '🧭 Norden (N)';

  @override
  String get skyMapCompassNE => '🧭 Nordosten (NE)';

  @override
  String get skyMapCompassE => '🧭 Osten (E)';

  @override
  String get skyMapCompassSE => '🧭 Südosten (SE)';

  @override
  String get skyMapCompassS => '🧭 Süden (S)';

  @override
  String get skyMapCompassSW => '🧭 Südwesten (SW)';

  @override
  String get skyMapCompassW => '🧭 Westen (W)';

  @override
  String get skyMapCompassNW => '🧭 Nordwesten (NW)';

  @override
  String get skyMapSunLabel => '☀ Sonne';

  @override
  String get skyMapMoonLabel => '🌙 Mond';

  @override
  String get skyMapHorizonLabel => '─── Horizont ───';
}
