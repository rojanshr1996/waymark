import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/trip_tables.dart';

part 'place_media_dao.g.dart';

@DriftAccessor(tables: [PlaceMediaFiles])
class PlaceMediaDao extends DatabaseAccessor<AppDatabase>
    with _$PlaceMediaDaoMixin {
  PlaceMediaDao(super.db);

  /// Fetch all media for a specific place
  Stream<List<PlaceMediaFile>> watchMediaForPlace(String placeId) {
    return (select(
      placeMediaFiles,
    )..where((m) => m.placeId.equals(placeId))).watch();
  }

  /// Fetch all media for a list of places
  Stream<List<PlaceMediaFile>> watchMediaForPlaces(List<String> placeIds) {
    if (placeIds.isEmpty) return Stream.value([]);
    return (select(
      placeMediaFiles,
    )..where((m) => m.placeId.isIn(placeIds))).watch();
  }

  /// Get all media for a specific place as a Future
  Future<List<PlaceMediaFile>> getMediaForPlace(String placeId) {
    return (select(
      placeMediaFiles,
    )..where((m) => m.placeId.equals(placeId))).get();
  }

  /// Get all media for a list of places as a Future
  Future<List<PlaceMediaFile>> getMediaForPlaces(List<String> placeIds) {
    if (placeIds.isEmpty) return Future.value([]);
    return (select(
      placeMediaFiles,
    )..where((m) => m.placeId.isIn(placeIds))).get();
  }

  /// Insert a new media file
  Future<int> insertMedia(PlaceMediaFilesCompanion media) {
    return into(placeMediaFiles).insert(media);
  }

  /// Update an existing media file
  Future<bool> updateMedia(PlaceMediaFile media) {
    return update(placeMediaFiles).replace(media);
  }

  /// Delete a media file by ID
  Future<int> deleteMedia(String id) {
    return (delete(placeMediaFiles)..where((m) => m.id.equals(id))).go();
  }

  /// Delete all media files for a place
  Future<int> deleteMediaForPlace(String placeId) {
    return (delete(
      placeMediaFiles,
    )..where((m) => m.placeId.equals(placeId))).go();
  }

  /// Clear all media files
  Future<int> clearAll() {
    return delete(placeMediaFiles).go();
  }
}
