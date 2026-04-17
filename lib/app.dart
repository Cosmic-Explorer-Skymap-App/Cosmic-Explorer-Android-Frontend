import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dio/dio.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';
import 'theme/space_theme.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/login_screen.dart';
import 'screens/setup_avatar_screen.dart';
import 'screens/setup_username_screen.dart';
import 'models/user_profile_model.dart';
import 'services/feed_service.dart';
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
      home: _BootstrapGate(
        locale: _locale,
        onLocaleRequested: () => LanguageSelectionScreen(onLocaleChange: setLocale),
      ),
    );
  }
}

class _BootstrapGate extends StatefulWidget {
  final Locale? locale;
  final Widget Function() onLocaleRequested;

  const _BootstrapGate({required this.locale, required this.onLocaleRequested});

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  bool _loading = true;
  bool _authenticated = false;
  bool _needsUsernameSetup = false;
  bool _needsAvatarSetup = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final isAuthenticated = await ApiService.isAuthenticated();
    if (!mounted) return;

    if (!isAuthenticated) {
      setState(() {
        _authenticated = false;
        _loading = false;
      });
      return;
    }

    try {
      final profile = await FeedService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _authenticated = true;
        _profile = profile;
        _needsAvatarSetup = profile.avatarUrl == null || profile.avatarUrl!.isEmpty;
        _needsUsernameSetup = false;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      if (error.response?.statusCode == 404) {
        setState(() {
          _authenticated = true;
          _needsUsernameSetup = true;
          _loading = false;
        });
      } else {
        setState(() {
          _authenticated = true;
          _loading = false;
        });
      }
    }
  }

  void _handleProfileCreated(UserProfile profile) {
    setState(() {
      _profile = profile;
      _needsUsernameSetup = false;
      _needsAvatarSetup = true;
    });
  }

  void _handleAvatarCreated(UserProfile profile) {
    setState(() {
      _profile = profile;
      _needsAvatarSetup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authenticated) {
      return const LoginScreen();
    }

    if (widget.locale == null) {
      return widget.onLocaleRequested();
    }

    if (_needsUsernameSetup) {
      return SetupUsernameScreen(onCompleted: _handleProfileCreated);
    }

    if (_needsAvatarSetup) {
      return SetupAvatarScreen(
        currentProfile: _profile!,
        onCompleted: _handleAvatarCreated,
      );
    }

    return HomeScreen(currentUser: _profile!);
  }
}
