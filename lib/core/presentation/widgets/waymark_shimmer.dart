import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/theme/waymark_colors.dart';

/// A high-performance, warm-toned shimmer loader that abides by
/// WayMark's "Tactile Editorial Modernism" palette.
///
/// Replaces sterile cold-grey loading spinners with organic, paper-linen
/// animated skeleton placeholders.
class WaymarkShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const WaymarkShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<WaymarkShimmer> createState() => _WaymarkShimmerState();
}

class _WaymarkShimmerState extends State<WaymarkShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warm linen tones instead of sterile grey
    final base = widget.baseColor ?? const Color(0xFFEBE7DF);
    final highlight = widget.highlightColor ?? const Color(0xFFFBF9F5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double percent = _controller.value;

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: percent),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      (slidePercent * 2 - 1) * bounds.width,
      0.0,
      0.0,
    );
  }
}

/// A rectangular or rounded skeleton block.
class WaymarkShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const WaymarkShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return WaymarkShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBE7DF),
          borderRadius:
              borderRadius ??
              BorderRadius.circular(WaymarkSpacing.radiusDefault),
        ),
      ),
    );
  }
}

/// A skeleton loader mimicking an editorial Place/Album Card.
class WaymarkShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;

  const WaymarkShimmerCard({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(WaymarkSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
        border: Border.all(color: colors.borderDivider, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081F2421),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simulated cover image
          WaymarkShimmerBox(
            width: double.infinity,
            height: 140.h,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusDefault),
          ),
          SizedBox(height: WaymarkSpacing.spaceMd),
          // Simulated title
          WaymarkShimmerBox(
            width: 180.w,
            height: 18.h,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
          ),
          SizedBox(height: WaymarkSpacing.spaceXs),
          // Simulated subtitle / stats line
          Row(
            children: [
              WaymarkShimmerBox(
                width: 90.w,
                height: 12.h,
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
              ),
              SizedBox(width: WaymarkSpacing.spaceSm),
              WaymarkShimmerBox(
                width: 60.w,
                height: 12.h,
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
