import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';

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

  Widget createSubject({
    required String albumId,
    String? albumTitle,
    TripPlace? placeToEdit,
    List<String>? initialPhotos,
  }) {
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
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => PlaceLoggerBottomSheet.show(
                    ctx,
                    albumId: albumId,
                    albumTitle: albumTitle,
                    placeToEdit: placeToEdit,
                    initialPhotos: initialPhotos,
                  ),
                  child: const Text('Open Story Sheet'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  testWidgets('PlaceLoggerBottomSheet renders Create Mode with all Stitch elements',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    // Seed test album
    await db.tripAlbumDao.insertAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('test-album-1'),
        title: const drift.Value('Kyoto Autumn Journey'),
        startDate: drift.Value(DateTime(2026, 10, 15)),
      ),
    );

    await tester.pumpWidget(
      createSubject(albumId: 'test-album-1', albumTitle: 'Kyoto Autumn Journey'),
    );
    await tester.pumpAndSettle();

    // Tap button to open sheet
    await tester.tap(find.text('Open Story Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Modal Header has title but no redundant top save button
    expect(find.text('Log New Place'), findsOneWidget);
    expect(find.text('Save Place'), findsNothing);

    // Verify Search Bar & Detected GPS Banner
    expect(find.text('Detected GPS from photo'), findsOneWidget);
    expect(find.text('Matched'), findsOneWidget);

    // Verify Place Identity
    expect(find.text('PLACE IDENTITY'), findsOneWidget);
    expect(find.text('Category Tag'), findsOneWidget);
    expect(find.text('Sightseeing'), findsOneWidget);
    expect(find.text('Dining'), findsOneWidget);

    // Verify Visited Time & Sky & Temp
    expect(find.text('Visited Time'), findsOneWidget);
    expect(find.text('Sky & Temp'), findsOneWidget);

    // Verify Visual Relics & Photos section
    expect(find.text('Visual Relics & Photos'), findsOneWidget);
    expect(find.text('Add Photo'), findsOneWidget);

    // Verify Sensory Impressions
    expect(find.text('Sensory Impressions'), findsOneWidget);
    expect(find.text('+ Incense scent'), findsOneWidget);
    expect(find.text('+ Distant chanting'), findsOneWidget);

    // Drag SingleChildScrollView to reveal sensory impressions and tap prompt pill
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -500));
    await tester.pump();
    await tester.tap(find.text('+ Incense scent'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Check notes textarea has updated text
    expect(find.textContaining('Incense scent'), findsOneWidget);

    // Verify Bottom CTA Button is always visible in bottomNavigationBar
    expect(find.text('Log Place to Kyoto Autumn Journey'), findsOneWidget);
  });

  testWidgets('PlaceLoggerBottomSheet renders Edit Mode with pre-filled place data',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    final testPlace = TripPlace(
      id: 'place-edit-1',
      albumId: 'test-album-1',
      name: 'Fushimi Inari Shrine',
      notes: 'Thousands of vermilion torii gates.',
      latitude: 34.9671,
      longitude: 135.7727,
      visitedAt: DateTime(2026, 10, 16, 9, 30),
      visitOrder: 1,
      category: 'SIGHTSEEING',
      weatherCondition: 'Sunny',
      temperatureCelsius: 18.0,
      locationAddress: 'Fushimi Inari-taisha, Fushimi Ward, Kyoto',
      sensoryTags: 'Cedar wood, Incense scent',
      isGpsFromExif: true,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      createSubject(
        albumId: 'test-album-1',
        albumTitle: 'Kyoto Autumn Journey',
        placeToEdit: testPlace,
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet in edit mode
    await tester.tap(find.text('Open Story Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Header shows Edit Place
    expect(find.text('Edit Place'), findsOneWidget);

    // Verify Pre-filled Place Identity Name
    expect(find.text('Fushimi Inari Shrine'), findsOneWidget);

    // Verify Pre-filled Notes
    expect(find.text('Thousands of vermilion torii gates.'), findsOneWidget);

    // Verify Bottom CTA button shows Update
    expect(find.text('Update Place in Kyoto Autumn Journey'), findsOneWidget);
  });

  testWidgets(
      'PlaceLoggerScreen saves place with photos and updates PlaceMediaFiles and TripAlbum.coverImagePath',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    // Seed test album
    await db.tripAlbumDao.insertAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('album-photos-test'),
        title: const drift.Value('Hokkaido Winter Trip'),
        startDate: drift.Value(DateTime(2026, 12, 1)),
      ),
    );

    await tester.pumpWidget(
      createSubject(
        albumId: 'album-photos-test',
        albumTitle: 'Hokkaido Winter Trip',
        initialPhotos: [
          'assets/images/place_one.jpeg',
          'assets/images/place_two.jpeg',
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Open logger
    await tester.tap(find.text('Open Story Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify photos attached counter
    expect(find.text('2 of 6 attached'), findsOneWidget);

    // Verify sticky save button is visible and tap it directly
    final saveButtonFinder = find.byKey(const Key('place_logger_save_button'));
    expect(saveButtonFinder, findsOneWidget);
    await tester.tap(saveButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify place was saved to TripPlaces
    final places = await db.tripPlaceDao.getPlacesForAlbum('album-photos-test');
    expect(places.length, 1);
    final savedPlace = places.first;
    expect(savedPlace.name, isNotEmpty);

    // Verify photos were saved to PlaceMediaFiles
    final media = await db.placeMediaDao.getMediaForPlace(savedPlace.id);
    expect(media.length, 2);
    expect(media.first.localFilePath, 'assets/images/place_one.jpeg');
    expect(media.first.isCoverPhoto, isTrue);
    expect(media[1].localFilePath, 'assets/images/place_two.jpeg');
    expect(media[1].isCoverPhoto, isFalse);

    // Verify TripAlbum.coverImagePath was updated
    final updatedAlbum = await db.tripAlbumDao.getAlbumById('album-photos-test');
    expect(updatedAlbum?.coverImagePath, 'assets/images/place_one.jpeg');
    expect(updatedAlbum?.totalPlacesCount, 1);
  });

  testWidgets(
      'PlaceLoggerScreen loads existing photos in edit mode and allows editing photos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    // Seed album, place, and media
    await db.tripAlbumDao.insertAlbum(
      TripAlbumsCompanion(
        id: const drift.Value('album-edit-photos'),
        title: const drift.Value('Nara Exploration'),
        startDate: drift.Value(DateTime(2026, 10, 16)),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const drift.Value('place-edit-photos'),
        albumId: const drift.Value('album-edit-photos'),
        name: const drift.Value('Nara Todaiji Temple'),
        notes: const drift.Value('Giant bronze Buddha hall.'),
        latitude: const drift.Value(34.6851),
        longitude: const drift.Value(135.8430),
        visitedAt: drift.Value(DateTime(2026, 10, 16, 10, 0)),
        visitOrder: const drift.Value(0),
        category: const drift.Value('SIGHTSEEING'),
      ),
    );

    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const drift.Value('media-nara-edit-1'),
        placeId: const drift.Value('place-edit-photos'),
        localFilePath: const drift.Value('assets/images/place_three.jpeg'),
        thumbnailPath: const drift.Value('assets/images/place_three.jpeg'),
        fileSizeBytes: const drift.Value(2048),
        width: const drift.Value(800),
        height: const drift.Value(600),
        isCoverPhoto: const drift.Value(true),
        capturedAt: drift.Value(DateTime(2026, 10, 16, 10, 0)),
      ),
    );

    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const drift.Value('media-nara-edit-2'),
        placeId: const drift.Value('place-edit-photos'),
        localFilePath: const drift.Value('assets/images/place_four.jpeg'),
        thumbnailPath: const drift.Value('assets/images/place_four.jpeg'),
        fileSizeBytes: const drift.Value(2048),
        width: const drift.Value(800),
        height: const drift.Value(600),
        isCoverPhoto: const drift.Value(false),
        capturedAt: drift.Value(DateTime(2026, 10, 16, 10, 5)),
      ),
    );

    final placeToEdit = (await db.tripPlaceDao.getPlacesForAlbum('album-edit-photos')).first;

    await tester.pumpWidget(
      createSubject(
        albumId: 'album-edit-photos',
        albumTitle: 'Nara Exploration',
        placeToEdit: placeToEdit,
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('Open Story Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify existing photos are loaded in tray
    expect(find.text('2 of 6 attached'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);

    // Verify delete button is present on photos
    final closeIcons = find.byIcon(Icons.close_rounded);
    expect(closeIcons, findsWidgets);

    // Scroll until visible then tap delete on second photo
    await tester.ensureVisible(closeIcons.last);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(closeIcons.last);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify photo counter decremented to 1
    expect(find.text('1 of 6 attached'), findsOneWidget);

    // Tap update button
    final saveButtonFinder = find.byKey(const Key('place_logger_save_button'));
    await tester.tap(saveButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify database has only 1 media item now
    final updatedMedia = await db.placeMediaDao.getMediaForPlace('place-edit-photos');
    expect(updatedMedia.length, 1);
    expect(updatedMedia.first.localFilePath, 'assets/images/place_three.jpeg');
  });
}
