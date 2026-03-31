import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import '../theme/space_theme.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final ValueChanged<Locale> onLocaleChange;

  const LanguageSelectionScreen({super.key, required this.onLocaleChange});

  void _selectLanguage(BuildContext context, String code) async {
    await LocaleService.setLocale(code);
    onLocaleChange(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Color(0xFF00E5FF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome / Hoş Geldiniz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select your language\nLütfen dil seçiniz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: SpaceTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              _LanguageButton(
                title: 'Türkçe',
                code: 'tr',
                onTap: () => _selectLanguage(context, 'tr'),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: 'English',
                code: 'en',
                onTap: () => _selectLanguage(context, 'en'),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: 'Deutsch',
                code: 'de',
                onTap: () => _selectLanguage(context, 'de'),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: 'Español',
                code: 'es',
                onTap: () => _selectLanguage(context, 'es'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String code;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.title,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
