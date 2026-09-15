import 'package:flutter/material.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';

import 'waymark_colors.dart';
import 'waymark_typography.dart';

class WaymarkTheme {
  static ThemeData get lightTheme {
    final textTheme = WaymarkTypography.getTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: WaymarkColors.lightColorScheme,
      scaffoldBackgroundColor: WaymarkColors.background,
      textTheme: textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: WaymarkColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: WaymarkColors.textMain),
        surfaceTintColor: Colors.transparent,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: WaymarkColors.surfaceCard,
        elevation: 0, // Using custom shadows in widgets
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          side: const BorderSide(
            color: WaymarkColors.borderDivider,
            width: 1.0,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: WaymarkColors.primary,
        foregroundColor: Colors.white,
        elevation:
            6, // 0 12px 28px shadow is handled in custom component or via elevation here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            WaymarkSpacing.radiusFull,
          ), // Pill shape
        ),
      ),

      // Input Decoration (Forms)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WaymarkColors.surfaceCard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: WaymarkSpacing.spaceMd,
          vertical: WaymarkSpacing.spaceSm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: WaymarkColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          borderSide: const BorderSide(
            color: WaymarkColors.borderDivider,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          borderSide: const BorderSide(
            color: WaymarkColors.borderDivider,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          borderSide: const BorderSide(
            color: WaymarkColors.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          borderSide: BorderSide(
            color: WaymarkColors.lightColorScheme.error,
            width: 1.0,
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: WaymarkColors.borderDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
