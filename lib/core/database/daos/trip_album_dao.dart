import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/trip_tables.dart';

part 'trip_album_dao.g.dart';

@DriftAccessor(tables: [TripAlbums])
class TripAlbumDao extends DatabaseAccessor<AppDatabase>
    with _$TripAlbumDaoMixin {
  TripAlbumDao(super.db);

  /// Fetch all trip albums (reactive stream)
  Stream<List<TripAlbum>> watchAllAlbums() {
    return select(tripAlbums).watch();
  }

  /// Insert a new trip album
  Future<int> insertAlbum(TripAlbumsCompanion album) {
    return into(tripAlbums).insert(album);
  }

  /// Update an existing trip album
  Future<bool> updateAlbum(TripAlbum album) {
    return update(tripAlbums).replace(album);
  }

  /// Fetch a trip album by ID
  Future<TripAlbum?> getAlbumById(String id) {
    return (select(
      tripAlbums,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch a trip album by ID for reactive UI updates
  Stream<TripAlbum?> watchAlbumById(String id) {
    return (select(
      tripAlbums,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Insert or replace a trip album
  Future<void> insertOrUpdateAlbum(TripAlbumsCompanion album) {
    return into(tripAlbums).insertOnConflictUpdate(album);
  }

  /// Delete a trip album by ID
  Future<int> deleteAlbum(String id) {
    return (delete(tripAlbums)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all trip albums (clears database)
  Future<int> clearAll() {
    return delete(tripAlbums).go();
  }
}
