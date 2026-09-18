import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable component entrance animation that executes a coordinated
/// fade-in, slide-up, and optional scale-in transition.
///
/// Abides by WayMark's fluid editorial motion guidelines (Curves.easeOutCubic).
class WaymarkAnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double initialScale;
  final Curve curve;

  const WaymarkAnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.slideOffset = const Offset(0, 18),
    this.initialScale = 0.97,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<WaymarkAnimatedEntrance> createState() =>
      _WaymarkAnimatedEntranceState();
}

class _WaymarkAnimatedEntranceState extends State<WaymarkAnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(curved);
    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx.w,
              _slideAnimation.value.dy.h,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Helper that applies cascading staggered entrance animations to a list of widgets.
class WaymarkStaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration interval;
  final Duration itemDuration;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const WaymarkStaggeredColumn({
    super.key,
    required this.children,
    this.initialDelay = const Duration(milliseconds: 60),
    this.interval = const Duration(milliseconds: 70),
    this.itemDuration = const Duration(milliseconds: 400),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: List.generate(children.length, (index) {
        final delay = initialDelay + (interval * index);
        return WaymarkAnimatedEntrance(
          delay: delay,
          duration: itemDuration,
          child: children[index],
        );
      }),
    );
  }
}
