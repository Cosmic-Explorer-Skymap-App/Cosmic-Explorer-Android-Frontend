import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';
import 'theme/space_theme.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/login_screen.dart';
import 'services/locale_service.dart';
import 'services/api_service.dart';

class CosmicExplorerApp extends StatefulWidget {
  const CosmicExplorerApp({super.key});

  @override
  State<CosmicExplorerApp> createState() => _CosmicExplorerAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_CosmicExplorerAppState>();
    state?.setLocale(newLocale);
  }
}

class _CosmicExplorerAppState extends State<CosmicExplorerApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = LocaleService.getLocale();
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmic Explorer',
      debugShowCheckedModeBanner: false,
      theme: SpaceTheme.theme,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder<bool>(
        future: ApiService.isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final bool isAuthenticated = snapshot.data ?? false;

          if (!isAuthenticated) {
            return const LoginScreen();
          }

          if (_locale == null) {
            return LanguageSelectionScreen(onLocaleChange: setLocale);
          }

          return const HomeScreen();
        },
      ),
    );
  }
}
