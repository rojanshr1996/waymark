import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'waymark_colors.dart';

/// Single source of truth for Typography, font families, font sizes,
/// and font weights throughout WayMark.
///
/// Strictly aligns with `DESIGN.md`:
/// - Headings & Display: Outfit
/// - Body, Labels & Captions: Inter
/// - Brand Script / Signatures: Caveat
class WaymarkTypography {
  static TextTheme getTextTheme() {
    return TextTheme(
      // Display / Titles
      displayLarge: GoogleFonts.outfit(
        fontSize: 44.sp,
        fontWeight: FontWeight.w600,
        height: 52 / 44,
        letterSpacing: -0.02 * 44.sp, // -0.02em
        color: WaymarkColors.textMain,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 36.sp,
        fontWeight: FontWeight.w600,
        height: 44 / 36,
        letterSpacing: -0.015 * 36.sp,
        color: WaymarkColors.textMain,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        height: 38 / 32,
        letterSpacing: -0.015 * 32.sp,
        color: WaymarkColors.textMain,
      ),

      // Headlines
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 34 / 28,
        letterSpacing: -0.01 * 28.sp,
        color: WaymarkColors.textMain,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        letterSpacing: 0,
        color: WaymarkColors.textMain,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        letterSpacing: 0,
        color: WaymarkColors.textMain,
      ),

      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0,
        color: WaymarkColors.textMain,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: WaymarkColors.textMain,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0,
        color: WaymarkColors.textSecondary,
      ),

      // Labels & Buttons
      labelLarge: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.01 * 14.sp,
        color: WaymarkColors.textMain,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.02 * 12.sp,
        color: WaymarkColors.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.03 * 11.sp,
        color: WaymarkColors.textSecondary,
      ),
    );
  }
}

/// Convenience extensions for accessing the centralized typography
/// tokens directly from [BuildContext] and [TextTheme].
extension WaymarkTextThemeExtension on TextTheme {
  /// Micro metadata caption (Inter 10sp w500 from DESIGN.md)
  TextStyle get caption => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    height: 12 / 10,
    letterSpacing: 0.04 * 10.sp,
    color: WaymarkColors.textSecondary,
  );

  /// Brand brush/cursive display script (Caveat 52sp w700)
  TextStyle get brandScript => GoogleFonts.caveat(
    fontSize: 52.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  /// Brand signature cursive style for the app name "WayMark" across all screens.
  /// Uses Caveat with FontWeight.w700, matching the signature font from splash screen.
  TextStyle get brandTitle => GoogleFonts.caveat(
    fontSize: 21.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.1,
    color: WaymarkColors.textMain,
  );
}

extension WaymarkThemeContextExtension on BuildContext {
  /// Direct access to the centralized TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
}
