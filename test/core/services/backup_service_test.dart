import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);

    tempDir = await Directory.systemTemp.createTemp('waymark_backup_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('BackupService CSV Parser and Escaping', () {
    test('parseCsv handles commas, escaped quotes, and newlines', () {
      const csv = '''# WAYMARK_BACKUP,app_name=waymark,app_signature=1,timestamp=2026-10-04T12:00:00.000Z
# TABLE:sample
id,name,description
1,"Place with, comma","A multi-line
description with ""quotes"""
2,"Simple Place","No quotes"''';

      final rows = BackupService.parseCsv(csv);
      expect(rows.length, 5);
      expect(rows[0][0], '# WAYMARK_BACKUP');
      expect(rows[1][0], '# TABLE:sample');
      expect(rows[2], ['id', 'name', 'description']);
      expect(rows[3][0], '1');
      expect(rows[3][1], 'Place with, comma');
      expect(rows[3][2], 'A multi-line\ndescription with "quotes"');
      expect(rows[4], ['2', 'Simple Place', 'No quotes']);
    });

    test('getBackupSignature identifies integer from filename or header', () {
      final file1 = File('${tempDir.path}/waymark_1.csv');
      file1.writeAsStringSync('# WAYMARK_BACKUP,app_name=waymark,app_signature=1,timestamp=2026-10-04T00:00:00.000Z\n');
      expect(BackupService.getBackupSignature(file1), 1);
      expect(BackupService.isSignatureMatch(file1), isTrue);

      final file2 = File('${tempDir.path}/waymark_2.csv');
      file2.writeAsStringSync('# WAYMARK_BACKUP,app_name=waymark,app_signature=2,timestamp=2026-10-04T00:00:00.000Z\n');
      expect(BackupService.getBackupSignature(file2), 2);
      expect(BackupService.isSignatureMatch(file2), isFalse);

      final timestamped = File('${tempDir.path}/waymark_1_20261004_123000.csv');
      timestamped.writeAsStringSync('# WAYMARK_BACKUP,app_name=waymark,app_signature=1\n');
      expect(BackupService.getBackupSignature(timestamped), 1);
      expect(BackupService.isSignatureMatch(timestamped), isTrue);
    });

    test('getBackupTimestamp parses timestamp from filename or header', () {
      final file = File('${tempDir.path}/waymark_1_20261004_143000.csv');
      file.writeAsStringSync('dummy');
      final ts = BackupService.getBackupTimestamp(file);
      expect(ts.year, 2026);
      expect(ts.month, 10);
      expect(ts.day, 4);
      expect(ts.hour, 14);
      expect(ts.minute, 30);

      final headerFile = File('${tempDir.path}/waymark_1.csv');
      headerFile.writeAsStringSync(
        '# WAYMARK_BACKUP,app_name=waymark,app_signature=1,timestamp=2026-05-15T08:00:00.000Z\n',
      );
      final headerTs = BackupService.getBackupTimestamp(headerFile);
      expect(headerTs.year, 2026);
      expect(headerTs.month, 5);
      expect(headerTs.day, 15);
    });
  });

  group('BackupService Generation & Restoration End-to-End', () {
    test('generateCsvContent exports all tables and restoreBackup restores them', () async {
      // 1. Seed database with profile and journey data
      await db.userProfileDao.createOrUpdateProfile(
        const UserProfilesCompanion(
          fullName: drift.Value('Rojan Explorer'),
          handle: drift.Value('rojan_waymark'),
          archetype: drift.Value('Alpinist'),
          bio: drift.Value('Exploring mountain peaks and quiet trails.'),
          unitSystem: drift.Value('metric'),
          autoExifGpsEnabled: drift.Value(true),
          vaultPath: drift.Value('/sandbox/documents/vault_001.drift'),
        ),
      );

      final albumId = 'album-test-101';
      await db.into(db.tripAlbums).insert(
        TripAlbumsCompanion(
          id: drift.Value(albumId),
          title: drift.Value('Himalayan Odyssey'),
          description: drift.Value('A trek through high valleys, crisp air, and prayer flags.'),
          startDate: drift.Value(DateTime(2026, 4, 1)),
          endDate: drift.Value(DateTime(2026, 4, 15)),
          coverImagePath: const drift.Value('/images/cover.jpg'),
          status: const drift.Value('COMPLETED'),
          totalDistanceKm: const drift.Value(145.5),
          totalPlacesCount: const drift.Value(2),
        ),
      );

      final placeId = 'place-test-201';
      await db.into(db.tripPlaces).insert(
        TripPlacesCompanion(
          id: drift.Value(placeId),
          albumId: drift.Value(albumId),
          name: drift.Value('Namche Bazaar, Solukhumbu'),
          notes: drift.Value('Acclimatization day. Had warm tea overlooking the valley.\nWeather was clear.'),
          latitude: const drift.Value(27.8069),
          longitude: const drift.Value(86.7140),
          altitude: const drift.Value(3440.0),
          visitedAt: drift.Value(DateTime(2026, 4, 3, 10, 30)),
          visitOrder: const drift.Value(1),
          category: const drift.Value('HIKE'),
          sensoryTags: const drift.Value('pine, chilled wind, prayer bells'),
          isGpsFromExif: const drift.Value(true),
        ),
      );

      await db.into(db.placeMediaFiles).insert(
        PlaceMediaFilesCompanion(
          id: const drift.Value('media-test-301'),
          placeId: drift.Value(placeId),
          localFilePath: const drift.Value('/media/namche_view.jpg'),
          thumbnailPath: const drift.Value('/media/thumb_namche.jpg'),
          fileSizeBytes: const drift.Value(2048500),
          width: const drift.Value(1920),
          height: const drift.Value(1080),
          isCoverPhoto: const drift.Value(true),
          capturedAt: drift.Value(DateTime(2026, 4, 3, 10, 35)),
        ),
      );

      await db.into(db.routeWaypoints).insert(
        RouteWaypointsCompanion(
          albumId: drift.Value(albumId),
          segmentOrder: const drift.Value(1),
          encodedPolyline: const drift.Value('u{~vFvyys@fG'),
          segmentDistanceMeters: const drift.Value(5200.0),
          estimatedDurationSeconds: const drift.Value(3600),
        ),
      );

      // 2. Generate CSV
      final csvContent = await BackupService.generateCsvContent();
      expect(csvContent, contains('# WAYMARK_BACKUP'));
      expect(csvContent, contains('app_name=waymark'));
      expect(csvContent, contains('app_signature=1'));
      expect(csvContent, contains('Rojan Explorer'));
      expect(csvContent, contains('Himalayan Odyssey'));
      expect(csvContent, contains('Namche Bazaar, Solukhumbu'));
      expect(csvContent, contains('pine, chilled wind, prayer bells'));

      // 3. Save CSV to file
      final backupFile = File('${tempDir.path}/waymark_1.csv');
      await backupFile.writeAsString(csvContent);

      // 4. Wipe database to verify restoration
      await db.clearEntireDatabase();
      final emptyProfile = await db.userProfileDao.getProfile();
      expect(emptyProfile, isNull);
      final emptyAlbums = await db.select(db.tripAlbums).get();
      expect(emptyAlbums, isEmpty);

      // 5. Restore from CSV
      await BackupService.restoreBackup(backupFile);

      // 6. Verify restored data
      final restoredProfile = await db.userProfileDao.getProfile();
      expect(restoredProfile, isNotNull);
      expect(restoredProfile!.fullName, 'Rojan Explorer');
      expect(restoredProfile.handle, 'rojan_waymark');
      expect(restoredProfile.archetype, 'Alpinist');

      final restoredAlbums = await db.select(db.tripAlbums).get();
      expect(restoredAlbums.length, 1);
      expect(restoredAlbums.first.title, 'Himalayan Odyssey');
      expect(restoredAlbums.first.totalDistanceKm, 145.5);

      final restoredPlaces = await db.tripPlaceDao.getAllPlaces();
      expect(restoredPlaces.length, 1);
      expect(restoredPlaces.first.name, 'Namche Bazaar, Solukhumbu');
      expect(restoredPlaces.first.altitude, 3440.0);
      expect(restoredPlaces.first.sensoryTags, 'pine, chilled wind, prayer bells');

      final restoredMedia = await db.select(db.placeMediaFiles).get();
      expect(restoredMedia.length, 1);
      expect(restoredMedia.first.localFilePath, '/media/namche_view.jpg');
      expect(restoredMedia.first.fileSizeBytes, 2048500);

      final restoredWaypoints = await db.select(db.routeWaypoints).get();
      expect(restoredWaypoints.length, 1);
      expect(restoredWaypoints.first.encodedPolyline, 'u{~vFvyys@fG');
    });

    test('validateRestoreSafety blocks mismatched signature', () async {
      final mismatchFile = File('${tempDir.path}/waymark_99.csv');
      await mismatchFile.writeAsString(
        '# WAYMARK_BACKUP,app_name=waymark,app_signature=99,timestamp=2026-10-04T12:00:00.000Z\n',
      );

      final validation = await BackupService.validateRestoreSafety(mismatchFile);
      expect(validation.isSafeToRestore, isFalse);
      expect(validation.isSignatureMatch, isFalse);
      expect(validation.backupSignature, 99);
      expect(validation.blockReason, contains('does not match your current App Signature'));
    });

    test('empty database skips auto-backup and rejects manual backup', () async {
      // Ensure database is completely empty
      await db.clearEntireDatabase();

      final summary = await BackupService.getActiveDataSummary();
      expect(summary.isEmpty, isTrue);
      expect(await BackupService.hasAnyData(), isFalse);

      // Auto backup should return null and not create any backup
      final autoResult = await BackupService.checkAndRunAutoBackup();
      expect(autoResult, isNull);

      final silentResult = await BackupService.createBackup(isManual: false);
      expect(silentResult, isNull);

      // Manual backup should throw an informative exception
      expect(
        () async => await BackupService.createBackup(isManual: true),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'description',
          contains('empty'),
        )),
      );
    });

    test('profile only (fresh onboarding) counts as empty journal and skips backup', () async {
      await db.clearEntireDatabase();
      expect(await BackupService.hasAnyData(), isFalse);

      // Add only a traveler profile (simulates moving past onboarding)
      await db.userProfileDao.createOrUpdateProfile(
        const UserProfilesCompanion(
          fullName: drift.Value('Solo Traveler'),
          handle: drift.Value('solo_traveler'),
          archetype: drift.Value('Wayfarer'),
        ),
      );

      final summary = await BackupService.getActiveDataSummary();
      expect(summary.isEmpty, isTrue);
      expect(summary.hasProfile, isTrue);
      expect(await BackupService.hasAnyData(), isFalse);

      // Auto backup should still be skipped
      final autoResult = await BackupService.checkAndRunAutoBackup();
      expect(autoResult, isNull);

      // Add a journey/album -> now the app has actual journey data
      await db.into(db.tripAlbums).insert(
        TripAlbumsCompanion(
          id: const drift.Value('album-initial-1'),
          title: const drift.Value('My First Journey'),
          startDate: drift.Value(DateTime.now()),
        ),
      );

      final updatedSummary = await BackupService.getActiveDataSummary();
      expect(updatedSummary.isEmpty, isFalse);
      expect(await BackupService.hasAnyData(), isTrue);

      final path = await BackupService.createBackup(isManual: true);
      expect(path, isNotNull);
      expect(path, contains('waymark_1.csv'));
      expect(File(path!).existsSync(), isTrue);
    });
  });
}
