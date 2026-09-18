import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:waymark/core/theme/waymark_colors.dart';

/// A reusable glassmorphic container that renders a modern "liquid glass" effect.
///
/// Combines hardware-accelerated [BackdropFilter] blur with subtle translucent tinting,
/// specular glass gradient sheen, micro-borders, and ambient elevation shadows
/// as defined in the Stitch Design Suite.
class WaymarkLiquidGlass extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final double blurSigma;
  final Color? tintColor;
  final double tintAlpha;
  final List<BoxShadow>? shadows;
  final bool showSpecularHighlight;

  const WaymarkLiquidGlass({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.blurSigma = 20.0,
    this.tintColor,
    this.tintAlpha = 0.85,
    this.shadows,
    this.showSpecularHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;
    final effectiveTintColor = (tintColor ?? context.colorScheme.surface)
        .withValues(alpha: tintAlpha);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveTintColor,
        borderRadius: effectiveBorderRadius,
        border:
            border ??
            Border.all(color: Colors.white.withValues(alpha: 0.35), width: 0.8),
        gradient: showSpecularHighlight
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.04),
                  Colors.black.withValues(alpha: 0.02),
                ],
                stops: const [0.0, 0.4, 1.0],
              )
            : null,
      ),
      child: child,
    );

    // Apply BackdropFilter blur with clipping to respect border radius
    Widget frostedBox = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );

    // Apply outer drop shadows if specified
    if (shadows != null && shadows!.isNotEmpty) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: shadows,
        ),
        child: frostedBox,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: frostedBox);
    }

    return frostedBox;
  }
}
