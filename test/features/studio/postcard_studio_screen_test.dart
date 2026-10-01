import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/studio/presentation/screens/postcard_studio_screen.dart';

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

  Widget createSubject({String? initialAlbumId}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(textTheme: WaymarkTypography.getTextTheme()),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PostcardStudioScreen(initialAlbumId: initialAlbumId),
        );
      },
    );
  }

  testWidgets('PostcardStudioScreen renders empty state when no albums exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('STUDIO CLOSED'), findsOneWidget);
    expect(find.text('No memories to print'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('PostcardStudioScreen renders empty state when albums exist but have no places', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('empty-album-1'),
        title: const drift.Value('Empty Album'),
        startDate: drift.Value(DateTime(2026, 4, 10)),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    await tester.pumpWidget(createSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('STUDIO CLOSED'), findsOneWidget);
    expect(find.text('No memories to print'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('PostcardStudioScreen renders studio screen header and canvas when albums with places exist', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('album-1'),
        title: const drift.Value('Kyoto Spring Expedition'),
        startDate: drift.Value(DateTime(2026, 4, 10)),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-1'),
        albumId: const drift.Value('album-1'),
        name: const drift.Value('Fushimi Inari Taisha'),
        category: const drift.Value('Culture'),
        latitude: const drift.Value(34.9671),
        longitude: const drift.Value(135.7727),
        visitedAt: drift.Value(DateTime(2026, 4, 11, 10, 0)),
        visitOrder: const drift.Value(0),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await tester.pumpWidget(createSubject(initialAlbumId: 'album-1'));
    await tester.pumpAndSettle();

    expect(find.text('Artistic Postcard Studio'), findsWidgets);
    expect(find.textContaining('Kyoto Spring Expedition'), findsWidgets);
    expect(find.text('LIVE RENDER BOUNDARY'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
