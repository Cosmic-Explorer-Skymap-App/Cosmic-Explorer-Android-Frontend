// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cosmic Explorer';

  @override
  String get homeTabTitle => 'Inicio';

  @override
  String get planetsTabTitle => 'Planetas';

  @override
  String get constellationsTabTitle => 'Estrellas';

  @override
  String get quizTabTitle => 'Quiz';

  @override
  String get favoritesTabTitle => 'Favoritos';

  @override
  String get homeHeaderTitle => '🌌 Cosmic Explorer';

  @override
  String get homeHeaderSubtitle => '¿Listo para explorar el universo?';

  @override
  String get skyMapFeatureTitle => 'Mapa Estelar en Vivo';

  @override
  String get skyMapFeatureSubtitle =>
      'Apunta tu teléfono al cielo, descubre las constelaciones';

  @override
  String get startBtn => 'Empezar →';

  @override
  String get quizQuickActionTitle => 'Pon a prueba tus conocimientos';

  @override
  String get deepSpaceQuickActionTitle => 'Espacio Profundo';

  @override
  String get dailyFactTitle => 'Dato Espacial del Día';

  @override
  String get skyMapScreenTitle => 'Mapa Estelar';

  @override
  String get skyMapLoadingSensors => 'Preparando sensores...';

  @override
  String get skyMapLocationError =>
      'No se pudo obtener la ubicación, usando la ubicación predeterminada.';

  @override
  String get skyMapCalibrationHint =>
      'Calibración: Mueva su teléfono en forma de 8 varias veces, luego apunte hacia el cielo.';

  @override
  String get skyMapCompassN => '🧭 Norte (N)';

  @override
  String get skyMapCompassNE => '🧭 Noreste (NE)';

  @override
  String get skyMapCompassE => '🧭 Este (E)';

  @override
  String get skyMapCompassSE => '🧭 Sureste (SE)';

  @override
  String get skyMapCompassS => '🧭 Sur (S)';

  @override
  String get skyMapCompassSW => '🧭 Suroeste (SW)';

  @override
  String get skyMapCompassW => '🧭 Oeste (W)';

  @override
  String get skyMapCompassNW => '🧭 Noroeste (NW)';

  @override
  String get skyMapSunLabel => '☀ Sol';

  @override
  String get skyMapMoonLabel => '🌙 Luna';

  @override
  String get skyMapHorizonLabel => '─── Horizonte ───';
}
