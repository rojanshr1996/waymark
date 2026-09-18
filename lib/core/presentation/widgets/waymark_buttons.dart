import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';

class WaymarkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;

  const WaymarkPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          WaymarkSpacing.radiusFull,
        ), // Pill shape
        boxShadow: (onPressed == null || isLoading)
            ? null
            : [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.28),
                  blurRadius: 28.r,
                  offset: Offset(0, 12.h),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0, // Handled by Container's boxShadow
          padding: EdgeInsets.symmetric(
            horizontal: WaymarkSpacing.spaceLg,
            vertical: WaymarkSpacing.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: WaymarkSpacing.spaceXs),
            ] else if (icon != null) ...[
              Icon(icon, size: 20.sp),
              SizedBox(width: WaymarkSpacing.spaceXs),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              SizedBox(width: WaymarkSpacing.spaceXs),
              Icon(trailingIcon, size: 20.sp),
            ],
          ],
        ),
      ),
    );
  }
}

class WaymarkSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const WaymarkSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.secondary,
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.secondary, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: WaymarkSpacing.spaceLg,
          vertical: WaymarkSpacing.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp),
            SizedBox(width: WaymarkSpacing.spaceXs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
