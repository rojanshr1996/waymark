import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

/// A reusable, artistic, animated empty state widget featuring
/// a subtle breathing concentric beacon halo, intuitive iconography,
/// typography, and action CTAs.
class WaymarkArtisticEmptyState extends StatefulWidget {
  final IconData icon;
  final String? badgeText;
  final String title;
  final String description;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onButtonPressed;
  final bool isCompact;
  final Color? accentColor;

  const WaymarkArtisticEmptyState({
    super.key,
    required this.icon,
    this.badgeText,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.buttonIcon,
    this.onButtonPressed,
    this.isCompact = false,
    this.accentColor,
  });

  @override
  State<WaymarkArtisticEmptyState> createState() =>
      _WaymarkArtisticEmptyStateState();
}

class _WaymarkArtisticEmptyStateState extends State<WaymarkArtisticEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _iconBobAnimation;
  late final Animation<double> _iconTiltAnimation;
  late final Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _iconBobAnimation = Tween<double>(begin: -3.5, end: 3.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _iconTiltAnimation = Tween<double>(begin: -0.10, end: 0.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final color = widget.accentColor ?? colors.primary;
    final outerRingSize = widget.isCompact ? 68.w : 96.w;
    final innerNodeSize = widget.isCompact ? 40.w : 54.w;
    final iconSize = widget.isCompact ? 20.sp : 26.sp;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 8.w : 16.w,
          vertical: widget.isCompact ? 12.h : 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Beacon Halo & Concentric Rings
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: outerRingSize,
                        height: outerRingSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(
                              alpha: _glowAnimation.value * 0.4,
                            ),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    // Middle soft glow ring
                    Container(
                      width: outerRingSize * 0.76,
                      height: outerRingSize * 0.76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.06),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                    // Glowing core icon node
                    Container(
                      width: innerNodeSize,
                      height: innerNodeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.82)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(
                              alpha: _glowAnimation.value * 0.5,
                            ),
                            blurRadius: 14.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Center(child: _buildAnimatedIcon(iconSize)),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: widget.isCompact ? 10.h : 16.h),

            // Optional Badge Pill
            if (widget.badgeText != null && widget.badgeText!.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  widget.badgeText!.toUpperCase(),
                  style: context.textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: color,
                    fontSize: 9.5.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // Headline Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style:
                  (widget.isCompact
                          ? context.textTheme.titleMedium
                          : context.textTheme.headlineSmall)
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colors.textPrimary,
                      ),
            ),

            SizedBox(height: 6.h),

            // Narrative Description
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 320.w),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                  fontSize: widget.isCompact ? 12.5.sp : 13.5.sp,
                ),
              ),
            ),

            // Optional CTA Button
            if (widget.buttonLabel != null &&
                widget.onButtonPressed != null) ...[
              SizedBox(height: widget.isCompact ? 12.h : 18.h),
              if (widget.isCompact)
                OutlinedButton.icon(
                  onPressed: widget.onButtonPressed,
                  icon: Icon(
                    widget.buttonIcon ?? Icons.add_circle_outline_rounded,
                    size: 16.sp,
                    color: color,
                  ),
                  label: Text(
                    widget.buttonLabel!,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    side: BorderSide(
                      color: color.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusMd,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: WaymarkPrimaryButton(
                    label: widget.buttonLabel!,
                    icon: widget.buttonIcon ?? Icons.add_circle_outline_rounded,
                    onPressed: widget.onButtonPressed,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(double iconSize) {
    if (widget.icon == Icons.explore_rounded) {
      // Compass needle seeking orientation and floating
      return Transform.translate(
        offset: Offset(0, _iconBobAnimation.value),
        child: Transform.rotate(
          angle: _iconTiltAnimation.value * 1.5,
          child: Transform.scale(
            scale: _iconScaleAnimation.value,
            child: Icon(widget.icon, color: Colors.white, size: iconSize),
          ),
        ),
      );
    } else if (widget.icon == Icons.map_rounded) {
      // Floating terrain map undulation & subtle sway
      return Transform.translate(
        offset: Offset(
          _iconTiltAnimation.value * 14.0,
          _iconBobAnimation.value * 1.2,
        ),
        child: Transform.rotate(
          angle: _iconTiltAnimation.value * 0.7,
          child: Transform.scale(
            scale: _iconScaleAnimation.value,
            child: Icon(widget.icon, color: Colors.white, size: iconSize),
          ),
        ),
      );
    } else if (widget.icon == Icons.photo_library_rounded) {
      // Postcard snapshot fluttering & gently angling
      return Transform.translate(
        offset: Offset(0, _iconBobAnimation.value * 1.3),
        child: Transform.rotate(
          angle: -_iconTiltAnimation.value * 1.3,
          child: Transform.scale(
            scale: _iconScaleAnimation.value,
            child: Icon(widget.icon, color: Colors.white, size: iconSize),
          ),
        ),
      );
    }

    // Default expressive bob and sway for any other icon
    return Transform.translate(
      offset: Offset(0, _iconBobAnimation.value),
      child: Transform.rotate(
        angle: _iconTiltAnimation.value,
        child: Transform.scale(
          scale: _iconScaleAnimation.value,
          child: Icon(widget.icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
