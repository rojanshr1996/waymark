import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';

class WaymarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const WaymarkCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WaymarkColors.surfaceCard,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
        border: Border.all(color: WaymarkColors.borderDivider, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A1F2421), // rgba(31, 36, 33, 0.04)
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          child: Padding(
            padding: padding ?? EdgeInsets.all(WaymarkSpacing.spaceMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

class WaymarkPolaroid extends StatelessWidget {
  final Widget image;
  final String? caption;
  final VoidCallback? onTap;

  const WaymarkPolaroid({
    super.key,
    required this.image,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WaymarkColors.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: const Color(0x261F2421), // rgba(31, 36, 33, 0.15)
            blurRadius: 25.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // 8px sides/top, 24px bottom as per DESIGN.md
            padding: EdgeInsets.fromLTRB(
              WaymarkSpacing.spaceXs,
              WaymarkSpacing.spaceXs,
              WaymarkSpacing.spaceXs,
              WaymarkSpacing.spaceLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
                if (caption != null) ...[
                  SizedBox(height: WaymarkSpacing.spaceSm),
                  Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
