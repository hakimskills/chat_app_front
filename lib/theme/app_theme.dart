import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All brand/semantic colors live here, as a single ThemeExtension.
/// To add a new theme later (e.g. "high contrast"), just add another
/// static const instance below — nothing else in the app needs to change.
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color bgTop;
  final Color bgBottom;
  final Color surface;
  final Color primaryStart;
  final Color primaryEnd;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color orbA;
  final Color orbB;

  const AppColorsExt({
    required this.bgTop,
    required this.bgBottom,
    required this.surface,
    required this.primaryStart,
    required this.primaryEnd,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.orbA,
    required this.orbB,
  });

  /// Convenience: the brand gradient, derived from the two primary colors.
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryStart, primaryEnd],
      );

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgBottom],
      );

  static const light = AppColorsExt(
    bgTop: Color(0xFFF6F6FF),
    bgBottom: Color(0xFFEDEFFC),
    surface: Color(0xFFFFFFFF),
    primaryStart: Color(0xFF6C5CE7),
    primaryEnd: Color(0xFF4834D4),
    accent: Color(0xFFFF6B81),
    textPrimary: Color(0xFF1B1D29),
    textSecondary: Color(0xFF6B7280),
    border: Color(0xFFE4E6F5),
    error: Color(0xFFE5484D),
    orbA: Color(0xFFB9AEFF),
    orbB: Color(0xFFFFC2CD),
  );

  static const dark = AppColorsExt(
    bgTop: Color(0xFF15131F),
    bgBottom: Color(0xFF0D0C15),
    surface: Color(0xFF1C1A2B),
    primaryStart: Color(0xFF8B7CF6),
    primaryEnd: Color(0xFF5B45E0),
    accent: Color(0xFFFF7E93),
    textPrimary: Color(0xFFF3F2FA),
    textSecondary: Color(0xFFA6A3BF),
    border: Color(0xFF2C2A40),
    error: Color(0xFFFF6B6B),
    orbA: Color(0xFF4B3F91),
    orbB: Color(0xFF6E3550),
  );

  @override
  AppColorsExt copyWith({
    Color? bgTop,
    Color? bgBottom,
    Color? surface,
    Color? primaryStart,
    Color? primaryEnd,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? error,
    Color? orbA,
    Color? orbB,
  }) {
    return AppColorsExt(
      bgTop: bgTop ?? this.bgTop,
      bgBottom: bgBottom ?? this.bgBottom,
      surface: surface ?? this.surface,
      primaryStart: primaryStart ?? this.primaryStart,
      primaryEnd: primaryEnd ?? this.primaryEnd,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      error: error ?? this.error,
      orbA: orbA ?? this.orbA,
      orbB: orbB ?? this.orbB,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primaryStart: Color.lerp(primaryStart, other.primaryStart, t)!,
      primaryEnd: Color.lerp(primaryEnd, other.primaryEnd, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      orbA: Color.lerp(orbA, other.orbA, t)!,
      orbB: Color.lerp(orbB, other.orbB, t)!,
    );
  }
}

/// Shortcut so widgets can write `context.colors.textPrimary` instead of
/// `Theme.of(context).extension<AppColorsExt>()!.textPrimary`.
extension AppColorsContext on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColorsExt.light, Brightness.light);
  static ThemeData get dark => _build(AppColorsExt.dark, Brightness.dark);

  static ThemeData _build(AppColorsExt colors, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: colors.primaryStart,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.bgBottom,
      extensions: [colors],
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall: GoogleFonts.sora(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          height: 1.15,
        ),
        headlineSmall: GoogleFonts.sora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 15, color: colors.textSecondary, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryStart, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error),
        ),
        labelStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surface,
        contentTextStyle: GoogleFonts.inter(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
