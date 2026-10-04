import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/screens/onboarding_screen.dart';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:waymark/core/database/app_database.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;
  MockPathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;

  @override
  Future<String?> getDownloadsPath() async => tempDir.path;

  @override
  Future<String?> getExternalStoragePath() async => tempDir.path;
}

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    tempDir = await Directory.systemTemp.createTemp('waymark_onboarding_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
  });

  tearDown(() async {
    await db.close();
    AppDatabase.resetInstance();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildSubject() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(textTheme: WaymarkTypography.getTextTheme()),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingScreen(),
        );
      },
    );
  }

  testWidgets('OnboardingScreen renders Step 1 and navigates to Step 2 with liquid glass app bar and bottom bar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Verify Step 1: Welcome & Philosophy elements exist
    expect(find.byType(WaymarkLiquidGlassAppBar), findsOneWidget);
    expect(find.byType(WaymarkLiquidGlass), findsAtLeastNWidgets(2));
    expect(find.text('WAYMARK ARCHIVE'), findsOneWidget);
    expect(find.text('Interactive Route Maps'), findsOneWidget);
    expect(find.text('Artistic Postcards'), findsOneWidget);
    expect(find.text('Private Local Vault'), findsOneWidget);
    expect(find.text('Begin Expedition Setup'), findsOneWidget);

    // Tap sticky "Begin Expedition Setup" button (always visible at bottom) to proceed to Step 2
    final buttonFinder = find.text('Begin Expedition Setup');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify Step 2: Profile & Vault Creation elements exist
    expect(find.byType(WaymarkLiquidGlassAppBar), findsOneWidget);
    expect(find.byType(WaymarkLiquidGlass), findsAtLeastNWidgets(2));
    expect(find.text('Claim Your Compass'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Compass ID / Email'), findsOneWidget);
    expect(find.text('Traveler Type'), findsOneWidget);
    expect(find.text('Initialize Local Vault'), findsOneWidget);

    // Verify generic hint and email placeholders
    expect(find.text('e.g. John Doe'), findsOneWidget);
    expect(find.text('e.g. john.doe@waymark.app'), findsOneWidget);

    // Enter text and verify tick mark appears
    await tester.enterText(find.byType(TextField).first, 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.pump();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('OnboardingScreen displays restore backup link on Step 1 and shows available CSV backups in bottom sheet', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Create a mock waymark backup folder and CSV file
    final waymarkDir = Directory('${tempDir.path}/waymark');
    await waymarkDir.create(recursive: true);
    final backupFile = File('${waymarkDir.path}/waymark_1.csv');
    await backupFile.writeAsString(
      '# WAYMARK_BACKUP,app_name=waymark,app_signature=1,timestamp=2026-10-04T12:00:00.000Z\n'
      '# TABLE:trip_albums\n'
      'id,title,subtitle,coverImagePath,startDate,endDate,status,totalDistanceKm,totalPlacesCount,createdAt,updatedAt\n'
      'alb_1,Alpine Tour,,photo.jpg,2026-01-01T00:00:00.000Z,,ONGOING,12.5,2,2026-01-01T00:00:00.000Z,2026-01-01T00:00:00.000Z\n',
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Verify restore link exists on Step 1
    final restoreFinder = find.byIcon(Icons.unarchive_rounded);
    expect(restoreFinder, findsOneWidget);

    // Tap restore link
    await tester.tap(restoreFinder);
    await tester.pumpAndSettle();

    // Verify the bottom sheet displays the backup file
    expect(find.text('Select Backup to Restore'), findsOneWidget);
    expect(find.textContaining('waymark_1.csv'), findsOneWidget);
    expect(find.text('Sig 1'), findsOneWidget);

    // Tap the backup file to trigger validation and confirmation dialog
    await tester.tap(find.textContaining('waymark_1.csv'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify confirmation dialog is displayed
    expect(find.text('Confirm Journal Restore'), findsOneWidget);
    expect(find.text('Confirm Restore'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel to dismiss dialog safely
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Confirm Journal Restore'), findsNothing);
  });
}
