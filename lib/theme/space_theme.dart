import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpaceTheme {
  SpaceTheme._();

  // Colors
  static const Color deepSpace = Color(0xFF0B0D21);
  static const Color nebulaPurple = Color(0xFF6C63FF);
  static const Color cosmicBlue = Color(0xFF3D5AFE);
  static const Color starWhite = Color(0xFFF0F0FF);
  static const Color stellarGold = Color(0xFFFFD54F);
  static const Color marsRed = Color(0xFFEF5350);
  static const Color nebulaOrange = Color(0xFFFF7043);
  static const Color surfaceCard = Color(0xFF1A1C36);
  static const Color surfaceCardLight = Color(0xFF252845);
  static const Color textSecondary = Color(0xFF9E9EBF);
  static const Color dividerColor = Color(0xFF2A2D50);

  static final List<Color> gradientBackground = [
    const Color(0xFF0B0D21),
    const Color(0xFF141638),
    const Color(0xFF1A1C42),
  ];

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      primaryColor: nebulaPurple,
      colorScheme: const ColorScheme.dark(
        primary: nebulaPurple,
        secondary: cosmicBlue,
        surface: surfaceCard,
        error: marsRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: starWhite,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: starWhite,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: starWhite,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: starWhite,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: starWhite,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: starWhite,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: starWhite,
        ),
        iconTheme: const IconThemeData(color: starWhite),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F1128),
        selectedItemColor: nebulaPurple,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// Glassmorphism card decoration.
  static BoxDecoration get glassCard => BoxDecoration(
        color: surfaceCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      );

  /// Gradient header decoration.
  static BoxDecoration gradientCard(List<int> hexColors) {
    final colors = hexColors.map((h) => Color(h)).toList();
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
}
