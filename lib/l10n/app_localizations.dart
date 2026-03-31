import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cosmic Explorer'**
  String get appTitle;

  /// No description provided for @homeTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homeTabTitle;

  /// No description provided for @planetsTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gezegenler'**
  String get planetsTabTitle;

  /// No description provided for @constellationsTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar'**
  String get constellationsTabTitle;

  /// No description provided for @quizTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Quiz'**
  String get quizTabTitle;

  /// No description provided for @favoritesTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get favoritesTabTitle;

  /// No description provided for @homeHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'🌌 Cosmic Explorer'**
  String get homeHeaderTitle;

  /// No description provided for @homeHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Evreni keşfetmeye hazır mısın?'**
  String get homeHeaderSubtitle;

  /// No description provided for @skyMapFeatureTitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Gök Haritası'**
  String get skyMapFeatureTitle;

  /// No description provided for @skyMapFeatureSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefonunu gökyüzüne tut, takımyıldızları keşfet'**
  String get skyMapFeatureSubtitle;

  /// No description provided for @startBtn.
  ///
  /// In tr, this message translates to:
  /// **'Başla →'**
  String get startBtn;

  /// No description provided for @quizQuickActionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Astronomi Bilgini Test Et'**
  String get quizQuickActionTitle;

  /// No description provided for @deepSpaceQuickActionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Derin Uzay'**
  String get deepSpaceQuickActionTitle;

  /// No description provided for @dailyFactTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün Uzay Gerçeği'**
  String get dailyFactTitle;

  /// No description provided for @skyMapScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gök Haritası'**
  String get skyMapScreenTitle;

  /// No description provided for @skyMapLoadingSensors.
  ///
  /// In tr, this message translates to:
  /// **'Sensörler hazırlanıyor...'**
  String get skyMapLoadingSensors;

  /// No description provided for @skyMapLocationError.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı, varsayılan konum kullanılıyor.'**
  String get skyMapLocationError;

  /// No description provided for @skyMapCalibrationHint.
  ///
  /// In tr, this message translates to:
  /// **'Kalibrasyon: Telefonunuzu 8 şeklinde birkaç kez sallayın, ardından gökyüzüne tutun.'**
  String get skyMapCalibrationHint;

  /// No description provided for @skyMapCompassN.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Kuzey (N)'**
  String get skyMapCompassN;

  /// No description provided for @skyMapCompassNE.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Kuzeydoğu (NE)'**
  String get skyMapCompassNE;

  /// No description provided for @skyMapCompassE.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Doğu (E)'**
  String get skyMapCompassE;

  /// No description provided for @skyMapCompassSE.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Güneydoğu (SE)'**
  String get skyMapCompassSE;

  /// No description provided for @skyMapCompassS.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Güney (S)'**
  String get skyMapCompassS;

  /// No description provided for @skyMapCompassSW.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Güneybatı (SW)'**
  String get skyMapCompassSW;

  /// No description provided for @skyMapCompassW.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Batı (W)'**
  String get skyMapCompassW;

  /// No description provided for @skyMapCompassNW.
  ///
  /// In tr, this message translates to:
  /// **'🧭 Kuzeybatı (NW)'**
  String get skyMapCompassNW;

  /// No description provided for @skyMapSunLabel.
  ///
  /// In tr, this message translates to:
  /// **'☀ Güneş'**
  String get skyMapSunLabel;

  /// No description provided for @skyMapMoonLabel.
  ///
  /// In tr, this message translates to:
  /// **'🌙 Ay'**
  String get skyMapMoonLabel;

  /// No description provided for @skyMapHorizonLabel.
  ///
  /// In tr, this message translates to:
  /// **'─── Ufuk ───'**
  String get skyMapHorizonLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
