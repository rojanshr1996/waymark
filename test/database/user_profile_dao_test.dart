import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('UserProfileDao can create and retrieve traveler profile', () async {
    // Initial profile should be null
    final initial = await db.userProfileDao.getProfile();
    expect(initial, isNull);

    // Create profile
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

    // Retrieve profile
    final profile = await db.userProfileDao.getProfile();
    expect(profile, isNotNull);
    expect(profile!.fullName, 'Elena Rostova');
    expect(profile.handle, 'elena_drift');
    expect(profile.archetype, 'Wayfarer');
    expect(profile.unitSystem, 'metric');
    expect(profile.autoExifGpsEnabled, isTrue);
    expect(profile.vaultPath, '/sandbox/documents/vault_001.drift');

    // Update profile
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Alpinist'),
        archetype: drift.Value('Alpinist'),
        unitSystem: drift.Value('imperial'),
      ),
    );

    final updated = await db.userProfileDao.getProfile();
    expect(updated, isNotNull);
    expect(updated!.fullName, 'Elena Alpinist');
    expect(updated.archetype, 'Alpinist');
    expect(updated.unitSystem, 'imperial');
  });

  test('clearAllJourneys preserves profile while clearing trips', () async {
    // Setup profile
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_rostova'),
      ),
    );

    // Setup a trip album
    await db.into(db.tripAlbums).insert(
      TripAlbumsCompanion(
        id: const drift.Value('test-album-1'),
        title: const drift.Value('Kyoto Trails'),
        startDate: drift.Value(DateTime.now()),
        status: const drift.Value('ONGOING'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    expect(await db.select(db.tripAlbums).get(), hasLength(1));

    // Clear journeys
    await db.clearAllJourneys();

    // Albums cleared, profile preserved
    expect(await db.select(db.tripAlbums).get(), isEmpty);
    final profile = await db.userProfileDao.getProfile();
    expect(profile, isNotNull);
    expect(profile!.fullName, 'Elena Rostova');
  });

  test('clearEntireDatabase clears profile and all trips', () async {
    // Setup profile and album
    await db.userProfileDao.createOrUpdateProfile(
      const UserProfilesCompanion(
        fullName: drift.Value('Elena Rostova'),
        handle: drift.Value('elena_rostova'),
      ),
    );
    await db.into(db.tripAlbums).insert(
      TripAlbumsCompanion(
        id: const drift.Value('test-album-1'),
        title: const drift.Value('Kyoto Trails'),
        startDate: drift.Value(DateTime.now()),
        status: const drift.Value('ONGOING'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    // Wipe entire database
    await db.clearEntireDatabase();

    expect(await db.select(db.tripAlbums).get(), isEmpty);
    expect(await db.userProfileDao.getProfile(), isNull);
  });
}
