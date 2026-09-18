import 'package:flutter/material.dart';

/// A unified scroll behavior configuring signature fluid bouncing physics
/// across all mobile form factors.
class WaymarkNoOverscrollScrollBehavior extends ScrollBehavior {
  const WaymarkNoOverscrollScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

typedef WaymarkScrollBehavior = WaymarkNoOverscrollScrollBehavior;
