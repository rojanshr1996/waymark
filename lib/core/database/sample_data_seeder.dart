import 'package:drift/drift.dart';
import 'package:waymark/core/database/app_database.dart';

/// Utility to seed and clear realistic sample data in Drift SQLite
/// for the Kansai Route demo as defined in the Stitch Design Suite.
class SampleDataSeeder {
  final AppDatabase db;

  SampleDataSeeder({AppDatabase? database})
    : db = database ?? AppDatabase.instance;

  /// Populates the complete Kansai expedition with active journey,
  /// 3 detailed waypoint places, and 2 completed archived journeys.
  Future<void> seedKansaiDemo() async {
    // 1. Featured Ongoing Journey: Autumn in Kyoto & Kansai Highlands
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const Value('kansai-expedition-1'),
        title: const Value('Autumn in Kyoto & Kansai Highlands'),
        description: const Value(
          'Vermilion shrine trails, ancient cedar forests, and quiet tea paths across Kyoto, Nara, and Kansai.',
        ),
        startDate: Value(DateTime(2026, 10, 12)),
        endDate: Value(DateTime(2026, 10, 20)),
        status: const Value('ONGOING'),
        totalDistanceKm: const Value(142.8),
        totalPlacesCount: const Value(8),
        coverImagePath: const Value('assets/images/place_twelve.jpeg'),
        createdAt: Value(DateTime(2026, 10, 12)),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // 2. Sample places for Kansai Expedition
    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const Value('place-fushimi-inari'),
        albumId: const Value('kansai-expedition-1'),
        name: const Value('Fushimi Inari Taisha'),
        notes: const Value(
          'Gentle warm sunlight filtering between thousand red torii gates. Recorded audio memo and captured film-grain shots.',
        ),
        latitude: const Value(34.9671),
        longitude: const Value(135.7727),
        visitedAt: Value(DateTime(2026, 10, 18, 14, 20)),
        visitOrder: const Value(1),
        weatherCondition: const Value('Sunny'),
        temperatureCelsius: const Value(21.0),
        category: const Value('SIGHTSEEING'),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const Value('place-nara-park'),
        albumId: const Value('kansai-expedition-1'),
        name: const Value('Nara Deer Park & Todaiji'),
        notes: const Value(
          'Gentle deer bowing under giant ancient mossy wooden gates in misty drizzle. Wet stone pathway ambiance.',
        ),
        latitude: const Value(34.6851),
        longitude: const Value(135.8430),
        visitedAt: Value(DateTime(2026, 10, 17, 11, 45)),
        visitOrder: const Value(2),
        weatherCondition: const Value('Light Rain'),
        temperatureCelsius: const Value(18.0),
        category: const Value('SIGHTSEEING'),
      ),
    );

    await db.tripPlaceDao.insertPlace(
      TripPlacesCompanion(
        id: const Value('place-arashiyama'),
        albumId: const Value('kansai-expedition-1'),
        name: const Value('Arashiyama Bamboo Grove'),
        notes: const Value(
          'Towering green bamboo grove at dawn. Crisp morning light piercing through towering stalks in quiet empty path.',
        ),
        latitude: const Value(35.0170),
        longitude: const Value(135.6713),
        visitedAt: Value(DateTime(2026, 10, 16, 7, 30)),
        visitOrder: const Value(3),
        weatherCondition: const Value('Crisp'),
        temperatureCelsius: const Value(15.0),
        category: const Value('HIKE'),
      ),
    );

    // 2b. Sample media files for places
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-fushimi-1'),
        placeId: const Value('place-fushimi-inari'),
        localFilePath: const Value('assets/images/place_one.jpeg'),
        thumbnailPath: const Value('assets/images/place_one.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(true),
        capturedAt: Value(DateTime(2026, 10, 18, 14, 20)),
      ),
    );
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-fushimi-2'),
        placeId: const Value('place-fushimi-inari'),
        localFilePath: const Value('assets/images/place_two.jpeg'),
        thumbnailPath: const Value('assets/images/place_two.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(false),
        capturedAt: Value(DateTime(2026, 10, 18, 14, 25)),
      ),
    );
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-nara-1'),
        placeId: const Value('place-nara-park'),
        localFilePath: const Value('assets/images/place_three.jpeg'),
        thumbnailPath: const Value('assets/images/place_three.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(true),
        capturedAt: Value(DateTime(2026, 10, 17, 11, 45)),
      ),
    );
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-nara-2'),
        placeId: const Value('place-nara-park'),
        localFilePath: const Value('assets/images/place_four.jpeg'),
        thumbnailPath: const Value('assets/images/place_four.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(false),
        capturedAt: Value(DateTime(2026, 10, 17, 11, 50)),
      ),
    );
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-arashiyama-1'),
        placeId: const Value('place-arashiyama'),
        localFilePath: const Value('assets/images/place_seven.jpeg'),
        thumbnailPath: const Value('assets/images/place_seven.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(true),
        capturedAt: Value(DateTime(2026, 10, 16, 7, 30)),
      ),
    );
    await db.placeMediaDao.insertMedia(
      PlaceMediaFilesCompanion(
        id: const Value('media-arashiyama-2'),
        placeId: const Value('place-arashiyama'),
        localFilePath: const Value('assets/images/place_eight.jpeg'),
        thumbnailPath: const Value('assets/images/place_eight.jpeg'),
        fileSizeBytes: const Value(2048),
        width: const Value(800),
        height: const Value(600),
        isCoverPhoto: const Value(false),
        capturedAt: Value(DateTime(2026, 10, 16, 7, 35)),
      ),
    );

    // 3. Completed Archived Memoirs
    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const Value('amalfi-coast-2'),
        title: const Value('Amalfi Coast Coastal Ridge Hike'),
        description: const Value(
          'Vibrant coastal cliffs of Amalfi Coast with pastel cliffside villages perched over deep turquoise waters.',
        ),
        startDate: Value(DateTime(2026, 5, 8)),
        endDate: Value(DateTime(2026, 5, 16)),
        status: const Value('COMPLETED'),
        totalDistanceKm: const Value(64.2),
        totalPlacesCount: const Value(12),
        createdAt: Value(DateTime(2026, 5, 8)),
        updatedAt: Value(DateTime(2026, 5, 16)),
      ),
    );

    await db.tripAlbumDao.insertOrUpdateAlbum(
      TripAlbumsCompanion(
        id: const Value('iceland-ring-road-3'),
        title: const Value('Iceland Ring Road Odyssey'),
        description: const Value(
          'Dramatic black sand beaches, volcanic moss, and glacial river deltas under moody northern skies.',
        ),
        startDate: Value(DateTime(2025, 9, 2)),
        endDate: Value(DateTime(2025, 9, 18)),
        status: const Value('COMPLETED'),
        totalDistanceKm: const Value(820.5),
        totalPlacesCount: const Value(24),
        createdAt: Value(DateTime(2025, 9, 2)),
        updatedAt: Value(DateTime(2025, 9, 18)),
      ),
    );
  }

  /// Clears all trip data (albums, places, media, waypoints) from the database.
  Future<void> clearAllTrips() async {
    await db.placeMediaDao.clearAll();
    await db.tripPlaceDao.clearAll();
    await db.tripAlbumDao.clearAll();
  }
}
