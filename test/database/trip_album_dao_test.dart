import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/database/sample_data_seeder.dart';

void main() {
  late AppDatabase db;
  late SampleDataSeeder seeder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    seeder = SampleDataSeeder(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('SampleDataSeeder seeds Kansai demo data and clears properly', () async {
    // Initially empty
    final initialAlbums = await db.tripAlbumDao.watchAllAlbums().first;
    expect(initialAlbums, isEmpty);

    // Seed Kansai Demo
    await seeder.seedKansaiDemo();

    // Verify albums
    final albums = await db.tripAlbumDao.watchAllAlbums().first;
    expect(albums.length, 3);

    final ongoingAlbum = albums.firstWhere((a) => a.status == 'ONGOING');
    expect(ongoingAlbum.title, 'Autumn in Kyoto & Kansai Highlands');
    expect(ongoingAlbum.totalDistanceKm, 142.8);
    expect(ongoingAlbum.totalPlacesCount, 8);

    final completedAlbums = albums.where((a) => a.status == 'COMPLETED').toList();
    expect(completedAlbums.length, 2);

    // Verify places
    final places = await db.tripPlaceDao.watchPlacesForAlbum(ongoingAlbum.id).first;
    expect(places.length, 3);
    expect(places[0].name, 'Fushimi Inari Taisha');
    expect(places[1].name, 'Nara Deer Park & Todaiji');
    expect(places[2].name, 'Arashiyama Bamboo Grove');

    // Verify recent places query
    final recentPlaces = await db.tripPlaceDao.watchRecentPlaces(limit: 2).first;
    expect(recentPlaces.length, 2);
    expect(recentPlaces.first.name, 'Fushimi Inari Taisha'); // most recently visited (Oct 18)

    // Test clearAllTrips
    await seeder.clearAllTrips();
    final clearedAlbums = await db.tripAlbumDao.watchAllAlbums().first;
    expect(clearedAlbums, isEmpty);

    final clearedPlaces = await db.tripPlaceDao.watchRecentPlaces().first;
    expect(clearedPlaces, isEmpty);
  });
}
