import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/screens/all_active_expeditions_screen.dart';

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

  testWidgets('AllActiveExpeditionsScreen shows empty state when no active expeditions', (WidgetTester tester) async {
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
            home: const AllActiveExpeditionsScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Active Expeditions'), findsOneWidget);
    expect(find.text('No Active Expedition'), findsOneWidget);
    expect(find.text('You do not have an ongoing journey in progress right now.'), findsOneWidget);
    expect(find.text('Start New Journey'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('AllActiveExpeditionsScreen renders all active expedition cards and live count badge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed 3 ongoing albums
    for (int i = 1; i <= 3; i++) {
      await db.tripAlbumDao.insertOrUpdateAlbum(
        TripAlbumsCompanion(
          id: drift.Value('album-$i'),
          title: drift.Value('Expedition #$i - Mountain Trek'),
          description: drift.Value('Exploring trail $i'),
          startDate: drift.Value(DateTime.now().subtract(Duration(days: i))),
          status: const drift.Value('ONGOING'),
          totalDistanceKm: drift.Value(15.0 * i),
          totalPlacesCount: drift.Value(i * 2),
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
            home: const AllActiveExpeditionsScreen(),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Active Expeditions'), findsOneWidget);
    expect(find.text('3 ACTIVE'), findsOneWidget);
    expect(find.text('Expedition #1 - Mountain Trek'), findsOneWidget);
    expect(find.text('Expedition #2 - Mountain Trek'), findsOneWidget);
    expect(find.text('Expedition #3 - Mountain Trek'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
