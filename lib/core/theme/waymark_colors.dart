import 'package:flutter/material.dart';

class WaymarkColors {
  // Brand Colors
  static const Color primary = Color(0xFFE26D5C); // Earth Terracotta
  static const Color secondary = Color(0xFF2C6E49); // Forest Teal
  static const Color tertiary = Color(0xFFFFB703); // Sunset Gold

  // Background & Surfaces
  static const Color background = Color(0xFFFBF9F5); // Warm Canvas
  static const Color surfaceCard = Color(0xFFFFFFFF); // White Surface

  // Typography Colors
  static const Color textMain = Color(0xFF1F2421); // Deep Peat
  static const Color textSecondary = Color(0xFF6C757D);

  // Dividers & Outlines
  static const Color borderDivider = Color(0xFFE9ECEF);

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
    surfaceContainerHighest: Color(0xFFDFE4DF),
    onSurfaceVariant: textSecondary,
    outline: borderDivider,
    outlineVariant: Color(0xFFDDC0BB),
  );
}
