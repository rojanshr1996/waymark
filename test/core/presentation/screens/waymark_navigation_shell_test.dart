import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/presentation/screens/waymark_navigation_shell.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/explore/presentation/screens/explore_map_view_screen.dart';
import 'package:waymark/features/journeys/presentation/screens/all_journeys_dashboard_screen.dart';
import 'package:waymark/features/profile/presentation/screens/traveler_profile_screen.dart';
import 'package:waymark/features/studio/presentation/screens/postcard_studio_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
    AppDatabase.resetInstance();
  });

  Widget buildSubject({int initialIndex = 0}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            textTheme: WaymarkTypography.getTextTheme(),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WaymarkNavigationShell(initialIndex: initialIndex),
        );
      },
    );
  }

  testWidgets('WaymarkNavigationShell hosts 4 child screens and switches tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildSubject(initialIndex: 0));
    await tester.pumpAndSettle();

    // Verify IndexedStack is present and has 4 child screens
    final indexedStackFinder = find.byType(IndexedStack);
    expect(indexedStackFinder, findsOneWidget);
    final IndexedStack indexedStack = tester.widget(indexedStackFinder);
    expect(indexedStack.index, equals(0));
    expect(indexedStack.children.length, equals(4));

    // Initially Journeys is onstage, others exist in IndexedStack
    expect(find.byType(AllJourneysDashboardScreen), findsOneWidget);
    expect(find.byType(ExploreMapViewScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(PostcardStudioScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(TravelerProfileScreen, skipOffstage: false), findsOneWidget);

    // Switch to Explore tab (index 1)
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    final IndexedStack exploreStack = tester.widget(indexedStackFinder);
    expect(exploreStack.index, equals(1));
    expect(find.byType(ExploreMapViewScreen), findsOneWidget);

    // Switch to Studio tab (index 2)
    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();

    final IndexedStack studioStack = tester.widget(indexedStackFinder);
    expect(studioStack.index, equals(2));
    expect(find.byType(PostcardStudioScreen), findsOneWidget);

    // Switch to Profile tab (index 3)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    final IndexedStack profileStack = tester.widget(indexedStackFinder);
    expect(profileStack.index, equals(3));
    expect(find.byType(TravelerProfileScreen), findsOneWidget);

    // Switch back to Journeys (index 0)
    await tester.tap(find.text('Journeys'));
    await tester.pumpAndSettle();

    final IndexedStack journeysStack = tester.widget(indexedStackFinder);
    expect(journeysStack.index, equals(0));
    expect(find.byType(AllJourneysDashboardScreen), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
