import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/screens/journey_album_detail_screen.dart';

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

  testWidgets('JourneyAlbumDetailScreen renders 4-column stats, 3 tabs, bottom bar, and no Continue Memoir', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Seed Album
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('test-album-1'),
        title: const drift.Value('Highland Odyssey'),
        description: const drift.Value('Trekking the misty mountain passes'),
        startDate: drift.Value(DateTime(2026, 4, 10, 8, 30)),
        endDate: drift.Value(DateTime(2026, 4, 15, 18, 0)),
        status: const drift.Value('ONGOING'),
        totalDistanceKm: const drift.Value(64.2),
        totalPlacesCount: const drift.Value(3),
        coverImagePath: const drift.Value('assets/images/place_twelve.jpeg'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    // 2. Seed Places
    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-1'),
        albumId: const drift.Value('test-album-1'),
        name: const drift.Value('Echo Valley Pass'),
        latitude: const drift.Value(35.123),
        longitude: const drift.Value(135.456),
        altitude: const drift.Value(1450.0),
        weatherCondition: const drift.Value('Misty Morning'),
        temperatureCelsius: const drift.Value(14.0),
        notes: const drift.Value('A serene pass with mountain bells echoing in the mist.'),
        sensoryTags: const drift.Value('Pine and damp moss,Echo of bells'),
        visitedAt: drift.Value(DateTime(2026, 4, 10, 9, 15)),
        visitOrder: const drift.Value(0),
        category: const drift.Value('LANDMARK'),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-2'),
        albumId: const drift.Value('test-album-1'),
        name: const drift.Value('Cedar Spring Shrine'),
        latitude: const drift.Value(35.145),
        longitude: const drift.Value(135.480),
        altitude: const drift.Value(1200.0),
        weatherCondition: const drift.Value('Partly Cloudy'),
        temperatureCelsius: const drift.Value(17.5),
        notes: const drift.Value('Ancient wooden torii beside crystal cold mountain runoff.'),
        visitedAt: drift.Value(DateTime(2026, 4, 10, 14, 0)),
        visitOrder: const drift.Value(1),
        category: const drift.Value('SIGHTSEEING'),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    // Seed media for place-1
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const drift.Value('media-1'),
        placeId: const drift.Value('place-1'),
        localFilePath: const drift.Value('assets/images/place_fushimi_inari.jpeg'),
        thumbnailPath: const drift.Value('assets/images/place_fushimi_inari.jpeg'),
        fileSizeBytes: const drift.Value(2048),
        width: const drift.Value(800),
        height: const drift.Value(600),
        isCoverPhoto: const drift.Value(true),
        capturedAt: drift.Value(DateTime(2026, 4, 10, 9, 30)),
      ),
    );

    // 3. Pump Widget
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(textTheme: WaymarkTypography.getTextTheme()),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const JourneyAlbumDetailScreen(journeyId: 'test-album-1'),
          );
        },
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title and Hero information
    expect(find.text('Highland Odyssey'), findsOneWidget);
    expect(find.textContaining('Trekking the misty mountain passes'), findsOneWidget);
    expect(find.text('ONGOING EXPEDITION'), findsOneWidget);

    // Verify Stats Bar
    expect(find.text('Total Path'), findsOneWidget);
    expect(find.text('Places'), findsOneWidget);
    expect(find.text('Recorded'), findsOneWidget);

    // Verify Segmented View Switcher Pill
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Route Map'), findsOneWidget);
    expect(find.textContaining('Wall'), findsOneWidget);

    // Verify STRICT ABSENCE of "Continue Memoir"
    expect(find.textContaining('Continue Memoir'), findsNothing);

    // Verify Bottom Sticky Action Bar
    expect(find.text('Art Postcard'), findsOneWidget);
    expect(find.text('+ Log Place'), findsOneWidget);

    // Verify Timeline elements
    expect(find.text('Echo Valley Pass'), findsOneWidget);
    expect(find.text('Cedar Spring Shrine'), findsOneWidget);
    expect(find.textContaining('mountain bells echoing in the mist'), findsOneWidget);
    expect(find.textContaining('Pine and damp moss'), findsOneWidget);
    expect(find.textContaining('Misty Morning'), findsWidgets);

    // 4. Test Switching to Route Map Tab
    await tester.tap(find.text('Route Map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('GPS Route Trace'), findsOneWidget);
    expect(find.textContaining('Milestones'), findsOneWidget);
    expect(find.text('Echo Valley Pass'), findsWidgets);
    expect(find.text('Cedar Spring Shrine'), findsWidgets);

    // 5. Test Switching to Wall Tab
    await tester.tap(find.textContaining('Wall'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Memory Artifacts'), findsOneWidget);
    expect(find.text('1 high-res film photos preserved'), findsOneWidget);

    // 6. Test Tapping "Art Postcard" button opens postcard preview
    await tester.tap(find.text('Art Postcard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Postcard Memoir'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);

    // Close postcard dialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Postcard Memoir'), findsNothing);

    // Unmount widget and flush Drift stream cancellation zero-duration timer
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
