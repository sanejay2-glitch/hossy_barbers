import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/app/theme/app_text_styles.dart';

abstract final class AppTheme {
  static final light = _theme(
    const ColorScheme.light(
      primary: AppColors.accentDark,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.mutedSurface,
      outline: AppColors.line,
    ),
    AppColors.canvas,
  );

  static final dark = _theme(
    const ColorScheme.dark(
      primary: AppColors.accentSoft,
      onPrimary: AppColors.ink,
      surface: AppColors.darkSurface,
      onSurface: AppColors.canvas,
      surfaceContainerHighest: AppColors.darkMutedSurface,
      outline: AppColors.darkLine,
    ),
    AppColors.darkCanvas,
  );

  static ThemeData _theme(ColorScheme colorScheme, Color scaffoldColor) =>
      ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldColor,
        colorScheme: colorScheme,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.display.copyWith(
            color: colorScheme.onSurface,
          ),
          headlineMedium: AppTextStyles.headline.copyWith(
            color: colorScheme.onSurface,
          ),
          titleLarge: AppTextStyles.title.copyWith(
            color: colorScheme.onSurface,
          ),
          bodyLarge: AppTextStyles.body.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.74),
          ),
          bodyMedium: AppTextStyles.body.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.74),
          ),
          labelLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 50),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 50),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: colorScheme.surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: .65)),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colorScheme.outline.withValues(alpha: .75),
          space: 1,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: scaffoldColor,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      );
}
