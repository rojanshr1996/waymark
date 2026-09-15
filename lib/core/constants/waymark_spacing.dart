import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Defines standardized spacing, margins, gutters, and border radii
/// based on the DESIGN.md "Tactile Editorial Modernism" specs.
///
/// Base Unit: 1rem = 16.0 logical pixels.
/// Responsive scaling uses flutter_screenutil (.w for width/spacing, .r for radius)
class WaymarkSpacing {
  // --- Responsive Spacing (Padding/Margins) ---
  static double get space2xs => 4.w; // 0.25rem
  static double get spaceXs => 8.w; // 0.5rem
  static double get spaceSm => 12.w; // 0.75rem
  static double get spaceMd => 16.w; // 1rem (Base)
  static double get spaceLg => 24.w; // 1.5rem
  static double get spaceXl => 32.w; // 2rem
  static double get space2xl => 48.w; // 3rem

  // --- Border Radii (Shapes) ---
  static double get radiusSm => 4.r; // 0.25rem
  static double get radiusDefault => 8.r; // 0.5rem (Primary Radius)
  static double get radiusMd => 12.r; // 0.75rem
  static double get radiusLg => 16.r; // 1rem (Expanded Radius)
  static double get radiusXl => 24.r; // 1.5rem
  static double get radiusFull => 9999.r; // Pill Shape

  // --- Responsive Breakpoints (Using ScreenUtil for screen size) ---
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;

  // --- Responsive Values ---

  /// Responsive screen margin based on screen width
  /// Mobile: 1rem (16.w)
  /// Tablet: 1.5rem (24.w)
  /// Desktop: 2.5rem (40.w)
  static double margin(BuildContext context) {
    final width = ScreenUtil().screenWidth;
    if (width >= breakpointDesktop) {
      return 40.w;
    } else if (width >= breakpointTablet) {
      return 24.w;
    }
    return 16.w;
  }

  /// Responsive inner content gutter
  /// Mobile: 1rem (16.w)
  /// Desktop/Tablet: 1.5rem (24.w)
  static double gutter(BuildContext context) {
    final width = ScreenUtil().screenWidth;
    if (width >= breakpointTablet) {
      return 24.w;
    }
    return 16.w;
  }
}
