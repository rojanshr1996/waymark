import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/explore/presentation/screens/explore_map_view_screen.dart';

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

  testWidgets('ExploreMapViewScreen carousel slides and switches place smoothly across multiple places', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Seed Album
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('album-1'),
        title: const drift.Value('Kansai Journey'),
        startDate: drift.Value(DateTime.now()),
        status: const drift.Value('ONGOING'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    // 2. Seed 3 Places
    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-1'),
        albumId: const drift.Value('album-1'),
        name: const drift.Value('Fushimi Inari'),
        latitude: const drift.Value(34.9671),
        longitude: const drift.Value(135.7727),
        category: const drift.Value('SIGHTSEEING'),
        visitedAt: drift.Value(DateTime.now().subtract(const Duration(hours: 3))),
        visitOrder: const drift.Value(0),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-2'),
        albumId: const drift.Value('album-1'),
        name: const drift.Value('Nara Deer Park'),
        latitude: const drift.Value(34.6851),
        longitude: const drift.Value(135.8430),
        category: const drift.Value('FOOD'),
        visitedAt: drift.Value(DateTime.now().subtract(const Duration(hours: 2))),
        visitOrder: const drift.Value(1),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-3'),
        albumId: const drift.Value('album-1'),
        name: const drift.Value('Arashiyama Bamboo Grove'),
        latitude: const drift.Value(35.0170),
        longitude: const drift.Value(135.6713),
        category: const drift.Value('SIGHTSEEING'),
        visitedAt: drift.Value(DateTime.now().subtract(const Duration(hours: 1))),
        visitOrder: const drift.Value(2),
        createdAt: drift.Value(DateTime.now()),
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
            home: const ExploreMapViewScreen(),
          );
        },
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Footprint 1 of 3 is shown
    expect(find.text('Footprint 1 of 3'), findsOneWidget);
    expect(find.text('Arashiyama Bamboo Grove'), findsAtLeast(1));

    // Slide / fling PageView to switch to next place
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify it switched to Footprint 2 of 3
    expect(find.text('Footprint 2 of 3'), findsOneWidget);
    expect(find.text('Nara Deer Park'), findsAtLeast(1));

    // Tap Next Footprint button
    await tester.tap(find.byTooltip('Next Footprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify it moved to Footprint 3 of 3
    expect(find.text('Footprint 3 of 3'), findsOneWidget);
    expect(find.text('Fushimi Inari'), findsAtLeast(1));

    // Tap Previous Footprint button
    await tester.tap(find.byTooltip('Previous Footprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify it returned to Footprint 2 of 3
    expect(find.text('Footprint 2 of 3'), findsOneWidget);
    expect(find.text('Nara Deer Park'), findsAtLeast(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
