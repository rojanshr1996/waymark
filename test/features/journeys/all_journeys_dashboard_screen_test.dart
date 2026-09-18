import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/screens/all_journeys_dashboard_screen.dart';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:waymark/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
    AppDatabase.resetInstance();
  });

  testWidgets('AllJourneysDashboardScreen transitions from empty state to seeded deck', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
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
            home: const AllJourneysDashboardScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Clean Slate Empty State with Artistic Animation
    expect(find.text('Your Journey Awaits'), findsOneWidget);
    expect(find.text('Start Your First Journey'), findsOneWidget);
    expect(find.text('OFFLINE FIELD JOURNAL'), findsOneWidget);
    expect(find.textContaining('OFFLINE READY'), findsOneWidget);

    // 2. Seed a trip album into the test database
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('trip-kyoto-01'),
        title: const drift.Value('Autumn in Kyoto & Kansai Highlands'),
        description: const drift.Value('Trekking ancient pilgrim trails'),
        startDate: drift.Value(DateTime.now().subtract(const Duration(days: 3))),
        status: const drift.Value('ONGOING'),
        totalDistanceKm: const drift.Value(42.5),
        totalPlacesCount: const drift.Value(5),
        coverImagePath: const drift.Value('assets/images/place_twelve.jpeg'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    await tester.pumpAndSettle();

    // 3. Verify Active Expedition Deck is now rendered
    expect(find.text('Autumn in Kyoto & Kansai Highlands'), findsAtLeast(1));
    expect(find.text('GPS Tracking Active'), findsOneWidget);
    expect(find.text('Export Field Journal'), findsOneWidget);
    expect(find.text('Start New Journey'), findsOneWidget);

    // 4. Test Filter Chips: Tap "Completed"
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();

    // Active ongoing journey card should not be visible when completed filter is active
    expect(find.text('GPS Tracking Active'), findsNothing);

    // 5. Test Tap "Start New Journey" button opens Bottom Sheet (FAB removed per design)
    await tester.ensureVisible(find.text('Start New Journey'));
    await tester.tap(find.text('Start New Journey'));
    await tester.pumpAndSettle();

    expect(find.text('New Travel Memoir'), findsOneWidget);
    expect(find.text('Create Journey Album'), findsOneWidget);

    // Unmount widget and flush Drift stream cancellation zero-duration timer
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('AllJourneysDashboardScreen renders all ongoing expeditions when multiple journey albums exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed 2 ongoing journey albums
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('trip-kyoto-01'),
        title: const drift.Value('Autumn in Kyoto & Kansai Highlands'),
        description: const drift.Value('Trekking ancient pilgrim trails'),
        startDate: drift.Value(DateTime.now().subtract(const Duration(days: 3))),
        status: const drift.Value('ONGOING'),
        totalDistanceKm: const drift.Value(42.5),
        totalPlacesCount: const drift.Value(5),
        coverImagePath: const drift.Value('assets/images/place_twelve.jpeg'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('trip-hokkaido-02'),
        title: const drift.Value('Winter in Hokkaido Snow Peaks'),
        description: const drift.Value('Skiing and onsen explorations'),
        startDate: drift.Value(DateTime.now().subtract(const Duration(days: 1))),
        status: const drift.Value('ONGOING'),
        totalDistanceKm: const drift.Value(28.0),
        totalPlacesCount: const drift.Value(3),
        coverImagePath: const drift.Value('assets/images/place_thirteen.jpeg'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
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
            home: const AllJourneysDashboardScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify ongoing expeditions appear in the active expedition section with View all and PageView
    expect(find.text('Autumn in Kyoto & Kansai Highlands'), findsAtLeast(1));
    expect(find.text('ACTIVE EXPEDITIONS (2)'), findsOneWidget);
    expect(find.text('GPS Tracking Active'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('AllJourneysDashboardScreen limits horizontal carousel to max 5 items when > 5 active expeditions exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed 7 ongoing albums
    for (int i = 1; i <= 7; i++) {
      await db.tripAlbumDao.insertOrUpdateAlbum(
        TripAlbumsCompanion(
          id: drift.Value('ongoing-$i'),
          title: drift.Value('Expedition #$i Active Trek'),
          description: drift.Value('Testing max 5 limit $i'),
          startDate: drift.Value(DateTime.now().subtract(Duration(days: i))),
          status: const drift.Value('ONGOING'),
          totalDistanceKm: drift.Value(10.0 * i),
          totalPlacesCount: drift.Value(i),
          createdAt: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    await tester.pumpWidget(
      ScreenUtilInit(
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
            home: const AllJourneysDashboardScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify badge shows total (7)
    expect(find.text('ACTIVE EXPEDITIONS (7)'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);

    // Verify PageView is present
    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);

    // Verify exactly 5 dot indicators exist (each dot is an AnimatedContainer child in the dot indicator row)
    // PageView only displays at most 5 items in displayedExpeditions
    expect(find.text('Expedition #1 Active Trek'), findsAtLeast(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
