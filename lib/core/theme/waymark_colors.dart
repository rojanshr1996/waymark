import 'package:flutter/material.dart';

class WaymarkColors {
  // Brand Colors
  static const Color primary = Color(0xFF9F3B2E); // Earth Terracotta
  static const Color secondary = Color(0xFF2C6E49); // Forest Teal
  static const Color tertiary = Color(0xFFFFB703); // Sunset Gold
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFE38E00);

  // Background & Surfaces
  static const Color background = Color(0xFFFBF9F5); // Warm Canvas
  static const Color surfaceCard = Color(0xFFFFFFFF); // White Surface
  static const Color surfaceVariant = Color(0xFFEBEFEA);

  // Typography Colors
  static const Color textMain = Color(0xFF1F2421); // Deep Peat
  static const Color textPrimary = textMain;
  static const Color textSecondary = Color(0xFF6C757D);

  // Dividers & Outlines
  static const Color borderDivider = Color(0xFFE9ECEF);
  static const Color outline = Color(0xFF8A716E);
  static const Color outlineVariant = Color(0xFFDDC0BB);

  // Additional Semantic Palette
  static const Color forestVivid = Color(0xFF38B000);
  static const Color surfaceContainer = Color(0xFFEBEFEA);
  static const Color surfaceContainerLow = Color(0xFFF0F5F0);
  static const Color surfaceContainerHigh = Color(0xFFE5E9E4);
  static const Color surfaceContainerHighest = Color(0xFFDFE4DF);
  static const Color onSurface = textMain;
  static const Color onSurfaceVariant = textSecondary;

  // Map Polylines Sequence
  static const Color routeStart = Color(0xFF3B82F6);
  static const Color routeMid = Color(0xFF8B5CF6);
  static const Color routeEnd = Color(0xFFF43F5E);

  // Material 3 ColorScheme mapping (Light)
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFDAD4),
    onPrimaryContainer: Color(0xFF410000),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFADF2C3),
    onSecondaryContainer: Color(0xFF002110),
    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFDEA9),
    onTertiaryContainer: Color(0xFF271900),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: background,
    onSurface: textMain,
    surfaceContainerLowest: surfaceCard,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: textSecondary,
    outline: borderDivider,
    outlineVariant: Color(0xFFDDC0BB),
  );
}

/// STRICT ARCHITECTURAL RULE:
/// Do NOT access [WaymarkColors] statically inside widget build methods!
/// Colors must always be resolved dynamically from the theme context via:
/// `Theme.of(context).colorScheme` or `context.colorScheme`.
extension WaymarkColorSchemeExtension on ColorScheme {
  /// Pure white surface card color
  Color get surfaceCard => surfaceContainerLowest;

  /// Neutral border divider
  Color get borderDivider => outline;

  /// High-contrast primary peat text
  Color get textPrimary => onSurface;

  /// Secondary muted text
  Color get textSecondary => onSurfaceVariant;

  /// Main text color
  Color get textMain => onSurface;

  /// Forest vivid status green
  Color get forestVivid => const Color(0xFF38B000);

  /// Amber warning color
  Color get warning => const Color(0xFFE38E00);

  /// Background surface color
  Color get background => surface;

  /// Warm canvas surface background from Stitch Suite
  Color get surfaceCanvas => surface;

  /// Soft surface container variant
  Color get surfaceVariant => surfaceContainer;

  /// Route start polyline blue
  Color get routeStart => const Color(0xFF3B82F6);

  /// Route mid polyline purple
  Color get routeMid => const Color(0xFF8B5CF6);

  /// Route end polyline coral/rose
  Color get routeEnd => const Color(0xFFF43F5E);
}

extension WaymarkColorsThemeContextExtension on BuildContext {
  /// Direct access to the active ColorScheme from theme context
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
