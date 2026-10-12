import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Reusable TrustLayer cybersecurity palette.
  static const Color black = Color(0xFF05070D);
  static const Color deepBlue = Color(0xFF071A3A);
  static const Color navy = Color(0xFF0B1020);
  static const Color surfaceCard = Color(0xFF101827);
  static const Color surfaceRaised = Color(0xFF162033);
  static const Color electricBlue = Color(0xFF2F80FF);
  static const Color cyberCyan = Color(0xFF22D3EE);
  static const Color successGreen = Color(0xFF2DD4BF);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color outlineBlue = Color(0xFF263B5E);
  static const Color errorRed = Color(0xFFFF4D6D);

  // Backward-compatible names used across existing screens.
  static const Color darkBg = black;
  static const Color primaryPurple = electricBlue;
  static const Color secondaryCyan = successGreen;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [black, deepBlue, navy],
  );

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          color: textMain,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: textMain,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textMain,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textMain, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14, height: 1.45),
        labelLarge: TextStyle(
          color: textMain,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: electricBlue,
      colorScheme: const ColorScheme.dark(
        primary: electricBlue,
        secondary: cyberCyan,
        surface: surfaceCard,
        onSurface: textMain,
        error: errorRed,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 8,
        shadowColor: electricBlue.withOpacity(0.18),
        margin: const EdgeInsets.all(8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: outlineBlue),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        floatingLabelStyle: const TextStyle(color: cyberCyan),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outlineBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyberCyan, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: textMain,
          disabledBackgroundColor: surfaceRaised,
          disabledForegroundColor: textMuted,
          elevation: 6,
          shadowColor: electricBlue.withOpacity(0.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: textMain,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cyberCyan,
          side: const BorderSide(color: outlineBlue),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cyberCyan,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: textMain),
        actionsIconTheme: const IconThemeData(color: textMain),
      ),
      dividerTheme: const DividerThemeData(color: outlineBlue, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textMain),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
