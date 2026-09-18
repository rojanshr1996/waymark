import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/screens/waymark_navigation_shell.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'waymark_liquid_glass.dart';

/// A reusable custom App Bar with a liquid glass / frosted blur effect.
///
/// Adapts to both editorial brand mastheads (e.g., Dashboard, Studio, Profile)
/// and inner-detail navigation headers (e.g., Journey Detail, Memory Sheet).
class WaymarkLiquidGlassAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Primary title. If [titleWidget] is provided, this string is ignored.
  final String? title;

  /// Optional custom title widget.
  final Widget? titleWidget;

  /// Optional subtitle (e.g. "WayMark Journal" or "Drift Synced").
  final String? subtitle;

  /// Optional custom subtitle widget.
  final Widget? subtitleWidget;

  /// Optional section label to form "WayMark • [sectionName]" when using brand style.
  final String? sectionName;

  /// Whether to display the signature editorial Brand Masthead with the
  /// compass icon and green "Drift Synced" live indicator.
  final bool showBrandMasthead;

  /// Leading widget. If null and current route can pop, renders a frosted back button.
  final Widget? leading;

  /// Trailing action widgets.
  final List<Widget>? actions;

  /// Whether to center the title (defaults to false for editorial alignment).
  final bool centerTitle;

  /// Height of the app bar excluding top safe-area padding. Defaults to 64.h (h-16 in Stitch).
  final double toolbarHeight;

  /// Whether to display the bottom hairline border.
  final bool showBottomBorder;

  /// Backdrop blur sigma.
  final double blurSigma;

  /// Background tint color. Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Background opacity. Defaults to 0.88.
  final double backgroundAlpha;

  /// Optional bottom widget, e.g. for tabs, step indicators, or filters.
  final PreferredSizeWidget? bottom;

  const WaymarkLiquidGlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.sectionName,
    this.showBrandMasthead = false,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.toolbarHeight = 64.0,
    this.showBottomBorder = true,
    this.blurSigma = 20.0,
    this.backgroundColor,
    this.backgroundAlpha = 0.88,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight.h + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;

    return WaymarkLiquidGlass(
      width: double.infinity,
      height: topPadding + toolbarHeight.h + bottomHeight,
      blurSigma: blurSigma,
      tintColor: backgroundColor ?? colors.surface,
      tintAlpha: backgroundAlpha,
      showSpecularHighlight: true,
      border: showBottomBorder
          ? Border(
              bottom: BorderSide(
                color: colors.borderDivider.withValues(alpha: 0.6),
                width: 0.8,
              ),
            )
          : null,
      shadows: const [
        BoxShadow(
          color: Color(0x081F2421), // rgba(31, 36, 33, 0.03)
          blurRadius: 8,
          offset: Offset(0, 1),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: toolbarHeight.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: WaymarkSpacing.spaceSm,
                  ),
                  child: NavigationToolbar(
                    leading: _buildLeading(context, canPop),
                    middle: _buildMiddle(context),
                    trailing: _buildActions(context),
                    centerMiddle: centerTitle,
                    middleSpacing: WaymarkSpacing.spaceSm,
                  ),
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, bool canPop) {
    if (leading != null) return leading;

    final navScope = WaymarkNavigationScope.of(context);
    final isChildTab = navScope != null && navScope.currentIndex != 0;

    if (canPop || isChildTab) {
      // Tactile frosted back button
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              onTap: () {
                if (canPop) {
                  Navigator.of(context).maybePop();
                } else if (isChildTab) {
                  navScope.switchToTab(0);
                }
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.surfaceCard.withValues(alpha: 0.6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20.sp,
                  color: context.colorScheme.textMain,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return null;
  }

  Widget? _buildMiddle(BuildContext context) {
    if (titleWidget != null) return titleWidget;

    if (showBrandMasthead) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Assets.images.waymarkLogoTransparent.image(
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Text(context.l10n.appName, style: context.textTheme.brandTitle),
              if (sectionName != null && sectionName!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    '•',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    sectionName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: context.colorScheme.secondary,
              ),
            ),
          ],
        ],
      );
    }

    if (title != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitleWidget != null)
            subtitleWidget!
          else if (subtitle != null) ...[
            SizedBox(height: 1.h),
            Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.textSecondary,
                fontSize: 11.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return null;
  }

  Widget? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!.map((action) {
        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: action,
        );
      }).toList(),
    );
  }
}
