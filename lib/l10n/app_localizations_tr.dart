// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cosmic Explorer';

  @override
  String get homeTabTitle => 'Ana Sayfa';

  @override
  String get planetsTabTitle => 'Gezegenler';

  @override
  String get constellationsTabTitle => 'Yıldızlar';

  @override
  String get quizTabTitle => 'Quiz';

  @override
  String get favoritesTabTitle => 'Favoriler';

  @override
  String get homeHeaderTitle => '🌌 Cosmic Explorer';

  @override
  String get homeHeaderSubtitle => 'Evreni keşfetmeye hazır mısın?';

  @override
  String get skyMapFeatureTitle => 'Canlı Gök Haritası';

  @override
  String get skyMapFeatureSubtitle =>
      'Telefonunu gökyüzüne tut, takımyıldızları keşfet';

  @override
  String get startBtn => 'Başla →';

  @override
  String get quizQuickActionTitle => 'Astronomi Bilgini Test Et';

  @override
  String get deepSpaceQuickActionTitle => 'Derin Uzay';

  @override
  String get dailyFactTitle => 'Günün Uzay Gerçeği';

  @override
  String get skyMapScreenTitle => 'Gök Haritası';

  @override
  String get skyMapLoadingSensors => 'Sensörler hazırlanıyor...';

  @override
  String get skyMapLocationError =>
      'Konum alınamadı, varsayılan konum kullanılıyor.';

  @override
  String get skyMapCalibrationHint =>
      'Kalibrasyon: Telefonunuzu 8 şeklinde birkaç kez sallayın, ardından gökyüzüne tutun.';

  @override
  String get skyMapCompassN => '🧭 Kuzey (N)';

  @override
  String get skyMapCompassNE => '🧭 Kuzeydoğu (NE)';

  @override
  String get skyMapCompassE => '🧭 Doğu (E)';

  @override
  String get skyMapCompassSE => '🧭 Güneydoğu (SE)';

  @override
  String get skyMapCompassS => '🧭 Güney (S)';

  @override
  String get skyMapCompassSW => '🧭 Güneybatı (SW)';

  @override
  String get skyMapCompassW => '🧭 Batı (W)';

  @override
  String get skyMapCompassNW => '🧭 Kuzeybatı (NW)';

  @override
  String get skyMapSunLabel => '☀ Güneş';

  @override
  String get skyMapMoonLabel => '🌙 Ay';

  @override
  String get skyMapHorizonLabel => '─── Ufuk ───';
}
