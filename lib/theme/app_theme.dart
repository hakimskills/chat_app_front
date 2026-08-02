import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens. Nothing in the UI should hardcode a color or
/// font outside of this file — keeps the whole app visually consistent
/// and makes re-theming trivial later.
class AppColors {
  AppColors._();

  static const bgTop = Color(0xFFF6F6FF);
  static const bgBottom = Color(0xFFEDEFFC);
  static const surface = Color(0xFFFFFFFF);

  static const primaryStart = Color(0xFF6C5CE7);
  static const primaryEnd = Color(0xFF4834D4);
  static const accent = Color(0xFFFF6B81);

  static const textPrimary = Color(0xFF1B1D29);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE4E6F5);
  static const error = Color(0xFFE5484D);

  static const orbA = Color(0xFFB9AEFF);
  static const orbB = Color(0xFFFFC2CD);
}

class AppGradients {
  AppGradients._();

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryStart, AppColors.primaryEnd],
  );

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgTop, AppColors.bgBottom],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.primaryStart);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgBottom,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.sora(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.15,
        ),
        headlineSmall: GoogleFonts.sora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryStart, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
