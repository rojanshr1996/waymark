import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';

class WaymarkStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const WaymarkStatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(
        horizontal: WaymarkSpacing.spaceSm,
        vertical: WaymarkSpacing.space2xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // 10% opacity
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
      ),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
