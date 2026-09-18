import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/trip_tables.dart';
import 'tables/user_profile_table.dart';

import 'daos/trip_album_dao.dart';
import 'daos/trip_place_dao.dart';
import 'daos/place_media_dao.dart';
import 'daos/route_waypoint_dao.dart';
import 'daos/user_profile_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    TripAlbums,
    TripPlaces,
    PlaceMediaFiles,
    RouteWaypoints,
    UserProfiles,
  ],
  daos: [
    TripAlbumDao,
    TripPlaceDao,
    PlaceMediaDao,
    RouteWaypointDao,
    UserProfileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  static AppDatabase _instance = AppDatabase();

  /// Shared singleton instance for application-wide local data access
  static AppDatabase get instance => _instance;

  /// Override the singleton instance for unit/widget tests
  static void setTestInstance(AppDatabase testDb) {
    _instance = testDb;
  }

  /// Reset to default database instance
  static void resetInstance() {
    _instance = AppDatabase();
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(userProfiles);
        }
        if (from < 3) {
          await m.addColumn(tripPlaces, tripPlaces.locationAddress);
          await m.addColumn(tripPlaces, tripPlaces.sensoryTags);
          await m.addColumn(tripPlaces, tripPlaces.isGpsFromExif);
        }
      },
      beforeOpen: (details) async {
        // Ensure foreign keys are enabled for SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Completely clears all tables in the database (trips, places, waypoints, media, user profile)
  Future<void> clearEntireDatabase() async {
    await transaction(() async {
      await routeWaypointDao.clearAll();
      await placeMediaDao.clearAll();
      await tripPlaceDao.clearAll();
      await tripAlbumDao.clearAll();
      await userProfileDao.clearAll();
    });
  }

  /// Clears all trip albums, places, waypoints, and media while preserving user profile
  Future<void> clearAllJourneys() async {
    await transaction(() async {
      await routeWaypointDao.clearAll();
      await placeMediaDao.clearAll();
      await tripPlaceDao.clearAll();
      await tripAlbumDao.clearAll();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'waymark_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
