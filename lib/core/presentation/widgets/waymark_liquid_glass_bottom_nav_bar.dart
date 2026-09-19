import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'waymark_liquid_glass.dart';

/// Item configuration for [WaymarkLiquidGlassBottomNavBar].
class WaymarkLiquidGlassNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? badgeText;

  const WaymarkLiquidGlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeText,
  });
}

/// A reusable Bottom Navigation Bar component featuring the signature
/// liquid glass / frosted blur aesthetic from the Stitch Design Suite.
///
/// Features:
/// - Hardware-accelerated frosted glass blur
/// - Upward ambient elevation shadow
/// - Tactile haptic feedback on tab change
/// - Smooth active capsule pill indicator
/// - Automatic safe-area inset padding
class WaymarkLiquidGlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<WaymarkLiquidGlassNavItem>? items;

  /// Height of the navigation bar content area (excluding bottom safe area).
  /// Defaults to 64.h (h-16 in Stitch).
  final double contentHeight;

  /// Whether to trigger haptic feedback on tab tap.
  final bool enableHaptics;

  /// Whether to render in floating dock style with curved corners or edge-to-edge.
  final bool isFloatingDock;

  /// Background color tint. Defaults to [ColorScheme.surfaceCard].
  final Color? backgroundColor;

  /// Opacity of the background tint. Defaults to 0.65.
  final double backgroundAlpha;

  const WaymarkLiquidGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
    this.contentHeight = 64.0,
    this.enableHaptics = true,
    this.isFloatingDock = false,
    this.backgroundColor,
    this.backgroundAlpha = 0.65,
  });

  /// Default localized Stitch Suite 4-tab configuration
  static List<WaymarkLiquidGlassNavItem> defaultItems(BuildContext context) => [
    WaymarkLiquidGlassNavItem(
      icon: Icons.photo_album_outlined,
      activeIcon: Icons.photo_album_rounded,
      label: context.l10n.navJourneys,
    ),
    WaymarkLiquidGlassNavItem(
      icon: Icons.timeline_rounded,
      activeIcon: Icons.timeline_rounded,
      label: context.l10n.navExplore,
    ),
    WaymarkLiquidGlassNavItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: context.l10n.navStudio,
    ),
    WaymarkLiquidGlassNavItem(
      icon: Icons.person_pin_circle_outlined,
      activeIcon: Icons.person_pin_circle_rounded,
      label: context.l10n.navProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final effectiveItems = items ?? defaultItems(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final totalHeight = contentHeight.h + (isFloatingDock ? 0 : bottomPadding);
    final floatingDockBottom = bottomPadding > 0
        ? bottomPadding
        : WaymarkSpacing.spaceMd;
    final navBarHeight = isFloatingDock
        ? (contentHeight.h + floatingDockBottom)
        : totalHeight;

    return SizedBox(
      height: navBarHeight,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: WaymarkLiquidGlass(
          width: isFloatingDock ? 360.w : double.infinity,
          height: totalHeight,
          blurSigma: 8.0,
          margin: isFloatingDock
              ? EdgeInsets.only(
                  left: WaymarkSpacing.spaceMd,
                  right: WaymarkSpacing.spaceMd,
                  bottom: bottomPadding > 0
                      ? bottomPadding
                      : WaymarkSpacing.spaceMd,
                )
              : EdgeInsets.zero,
          borderRadius: isFloatingDock
              ? BorderRadius.circular(WaymarkSpacing.radiusFull)
              : null,
          border: isFloatingDock
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.0,
                )
              : Border(
                  top: BorderSide(
                    color: context.colorScheme.borderDivider.withValues(
                      alpha: 0.8,
                    ),
                    width: 0.8,
                  ),
                ),
          shadows: const [
            BoxShadow(
              color: Color(0x0D1F2421), // rgba(31, 36, 33, 0.05)
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
          tintColor: backgroundColor ?? context.colorScheme.surfaceCard,
          tintAlpha: backgroundAlpha,
          showSpecularHighlight: true,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isFloatingDock ? 0 : bottomPadding,
            ),
            child: SizedBox(
              height: contentHeight.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(effectiveItems.length, (index) {
                  return _buildNavItem(context, index, effectiveItems[index]);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    WaymarkLiquidGlassNavItem item,
  ) {
    final isSelected = index == currentIndex;
    final activeColor = context.colorScheme.primary;
    final inactiveColor = context.colorScheme.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
          onTap: () {
            if (enableHaptics && !isSelected) {
              HapticFeedback.selectionClick();
            }
            onTap(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with subtle animated scale
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    size: 22.sp,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                SizedBox(height: 3.h),
                // Text Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (context.textTheme.labelSmall ?? const TextStyle())
                      .copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? activeColor : inactiveColor,
                        letterSpacing: 0.1,
                      ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h),
                // Micro Active Pill Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutQuad,
                  height: 3.h,
                  width: isSelected ? 16.w : 0,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
