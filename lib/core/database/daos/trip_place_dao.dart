import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/trip_tables.dart';

part 'trip_place_dao.g.dart';

@DriftAccessor(tables: [TripPlaces, PlaceMediaFiles])
class TripPlaceDao extends DatabaseAccessor<AppDatabase>
    with _$TripPlaceDaoMixin {
  TripPlaceDao(super.db);

  /// Fetch all places for a specific album, ordered by visitOrder
  Stream<List<TripPlace>> watchPlacesForAlbum(String albumId) {
    return (select(tripPlaces)
          ..where((p) => p.albumId.equals(albumId))
          ..orderBy([
            (p) =>
                OrderingTerm(expression: p.visitOrder, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// Get all places for a specific album, ordered by visitOrder
  Future<List<TripPlace>> getPlacesForAlbum(String albumId) {
    return (select(tripPlaces)
          ..where((p) => p.albumId.equals(albumId))
          ..orderBy([
            (p) =>
                OrderingTerm(expression: p.visitOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Insert a new place
  Future<int> insertPlace(TripPlacesCompanion place) {
    return into(tripPlaces).insert(place);
  }

  /// Update an existing place
  Future<bool> updatePlace(TripPlace place) {
    return update(tripPlaces).replace(place);
  }

  /// Fetch recent places across all albums, ordered by visitedAt desc
  Stream<List<TripPlace>> watchRecentPlaces({int limit = 10}) {
    return (select(tripPlaces)
          ..orderBy([
            (p) =>
                OrderingTerm(expression: p.visitedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  /// Batch update the visit order of a list of places
  Future<void> updateVisitOrders(List<String> placeIds) async {
    await transaction(() async {
      for (int i = 0; i < placeIds.length; i++) {
        await (update(tripPlaces)..where((p) => p.id.equals(placeIds[i])))
            .write(TripPlacesCompanion(visitOrder: Value(i)));
      }
    });
  }

  /// Delete all trip places
  Future<int> clearAll() {
    return delete(tripPlaces).go();
  }
}
