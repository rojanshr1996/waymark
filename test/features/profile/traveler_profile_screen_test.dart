import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_avatar_picker.dart';
import 'package:waymark/features/profile/presentation/screens/traveler_profile_screen.dart';

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

  Widget createSubject() {
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
          home: const TravelerProfileScreen(),
        );
      },
    );
  }

  testWidgets('TravelerProfileScreen populates from profile and shows empty albums state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed profile
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_drift'),
        archetype: drift.Value('Wayfarer'),
        bio: drift.Value('Slow traveler chasing morning mist.'),
        unitSystem: drift.Value('metric'),
        autoExifGpsEnabled: drift.Value(true),
        vaultPath: drift.Value('/sandbox/documents/vault_001.drift'),
      ),
    );

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Verify profile fields are populated
    expect(find.text('Elena Rostova'), findsOneWidget);
    expect(find.text('elena_drift'), findsOneWidget);
    expect(find.text('Slow traveler chasing morning mist.'), findsOneWidget);
    expect(find.text('Casual Explorer'), findsOneWidget);

    // Verify Travel Albums empty state
    expect(find.text('Travel Albums & Memoirs'), findsOneWidget);
    expect(find.text('0 Memoirs'), findsOneWidget);
    expect(find.text('No travel albums in your offline vault yet'), findsOneWidget);
    expect(find.text('Start Your First Journey'), findsOneWidget);

    // Unmount widget and flush Drift stream cancellation timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('TravelerProfileScreen displays travel albums list and metrics when albums exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed profile
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_drift'),
        archetype: drift.Value('Wayfarer'),
      ),
    );

    // Seed album
    await db.tripAlbumDao.insertAlbum(
      TripAlbumsCompanion.insert(
        id: 'test_album_001',
        title: 'Kyoto Ancient Trails',
        startDate: DateTime(2025, 10, 15),
        endDate: drift.Value(DateTime(2025, 10, 22)),
        status: const drift.Value('COMPLETED'),
        totalDistanceKm: const drift.Value(42.5),
        totalPlacesCount: const drift.Value(7),
      ),
    );

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Verify album section displays count & album details
    expect(find.text('1 Memoir'), findsOneWidget);
    expect(find.text('Kyoto Ancient Trails'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('42.5 km'), findsWidgets);
    expect(find.text('7 stops'), findsWidgets);

    // Unmount widget and flush Drift stream cancellation timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('TravelerProfileScreen saves updated profile to Drift database', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed profile
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_drift'),
        archetype: drift.Value('Wayfarer'),
      ),
    );

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Edit full name
    final nameFieldFinder = find.widgetWithText(TextField, 'Elena Rostova');
    await tester.enterText(nameFieldFinder, 'Elena Alpinist');
    await tester.pump();

    // Tap "Save Changes"
    final saveButtonFinder = find.text('Save Changes');
    await tester.ensureVisible(saveButtonFinder);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Verify database was updated
    final updatedProfile = await db.userProfileDao.getProfile();
    expect(updatedProfile, isNotNull);
    expect(updatedProfile!.fullName, 'Elena Alpinist');

    // Verify success toast
    expect(find.text('Profile settings updated successfully'), findsOneWidget);
    // Drain snackbar timer
    await tester.pump(const Duration(seconds: 5));

    // Unmount widget and flush Drift stream cancellation timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('TravelerProfileScreen opens avatar picker and selects preset cleanly without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_drift'),
        archetype: drift.Value('Wayfarer'),
        avatarPath: drift.Value('avatar:explorer'),
      ),
    );

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Tap on TravelerAvatarPicker
    final avatarPickerFinder = find.byType(TravelerAvatarPicker);
    expect(avatarPickerFinder, findsOneWidget);
    await tester.tap(avatarPickerFinder);
    await tester.pumpAndSettle();

    // Verify modal bottom sheet is displayed
    expect(find.text('Traveler Portrait'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('From Gallery'), findsOneWidget);
    expect(find.text('CHOOSE AVATAR PRESET'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);

    // Select 'Photographer' preset
    await tester.tap(find.text('Photographer'));
    await tester.pumpAndSettle();

    // Verify modal is dismissed
    expect(find.text('CHOOSE AVATAR PRESET'), findsNothing);

    // Tap Save Changes
    final saveButtonFinder = find.text('Save Changes');
    await tester.ensureVisible(saveButtonFinder);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Verify DB updated with new avatar preset
    final profile = await db.userProfileDao.getProfile();
    expect(profile, isNotNull);
    expect(profile!.avatarPath, 'avatar:shutterbug');

    // Drain snackbar timer
    await tester.pump(const Duration(seconds: 5));

    // Unmount widget and flush Drift stream cancellation timers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
