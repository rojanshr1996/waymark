import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';

class WaymarkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const WaymarkPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          WaymarkSpacing.radiusFull,
        ), // Pill shape
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: WaymarkColors.primary.withOpacity(0.28),
                  blurRadius: 28.r,
                  offset: Offset(0, 12.h),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: WaymarkColors.primary,
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
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.sp),
              SizedBox(width: WaymarkSpacing.spaceXs),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: WaymarkColors.secondary,
        backgroundColor: WaymarkColors.background,
        side: const BorderSide(color: WaymarkColors.secondary, width: 1.5),
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
              color: WaymarkColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
