import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waymark/core/presentation/widgets/widgets.dart';
import 'package:waymark/features/explore/presentation/screens/explore_map_view_screen.dart';
import 'package:waymark/features/journeys/presentation/screens/all_journeys_dashboard_screen.dart';
import 'package:waymark/features/profile/presentation/screens/traveler_profile_screen.dart';
import 'package:waymark/features/studio/presentation/screens/postcard_studio_screen.dart';

/// InheritedWidget providing child screens direct capability to programmatic switch tabs.
class WaymarkNavigationScope extends InheritedWidget {
  final int currentIndex;
  final void Function(int) switchToTab;

  const WaymarkNavigationScope({
    super.key,
    required this.currentIndex,
    required this.switchToTab,
    required super.child,
  });

  static WaymarkNavigationScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WaymarkNavigationScope>();
  }

  @override
  bool updateShouldNotify(WaymarkNavigationScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

/// A persistent navigation page that hosts the 4 primary child screens
/// in an [IndexedStack] and displays the signature [WaymarkLiquidGlassBottomNavBar].
class WaymarkNavigationShell extends StatefulWidget {
  final int initialIndex;

  const WaymarkNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<WaymarkNavigationShell> createState() => _WaymarkNavigationShellState();
}

class _WaymarkNavigationShellState extends State<WaymarkNavigationShell> {
  late final ValueNotifier<int> _currentIndexNotifier;
  DateTime? _lastBackPressTime;

  static const List<Widget> _screens = [
    AllJourneysDashboardScreen(),
    ExploreMapViewScreen(),
    PostcardStudioScreen(),
    TravelerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndexNotifier = ValueNotifier<int>(widget.initialIndex);
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WaymarkNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndexNotifier.value = widget.initialIndex;
    }
  }

  void _onTap(int index) {
    if (_currentIndexNotifier.value != index) {
      _currentIndexNotifier.value = index;
    }
  }

  void _handleBackNavigation() {
    if (_currentIndexNotifier.value != 0) {
      // Return to home page (AllJourneysDashboardScreen)
      _onTap(0);
      return;
    }

    // On home page: double back press/swipe within 2 seconds exits application
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      WaymarkSnackbar.showInfo(
        context,
        'Press or swipe back again to close the application',
        duration: const Duration(seconds: 2),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _handleBackNavigation();
            }
          },
          child: WaymarkNavigationScope(
            currentIndex: currentIndex,
            switchToTab: _onTap,
            child: Scaffold(
              extendBody: false,
              body: IndexedStack(index: currentIndex, children: _screens),
              bottomNavigationBar: WaymarkLiquidGlassBottomNavBar(
                currentIndex: currentIndex,
                onTap: _onTap,
              ),
            ),
          ),
        );
      },
    );
  }
}
