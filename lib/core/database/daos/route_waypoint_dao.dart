import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/trip_tables.dart';

part 'route_waypoint_dao.g.dart';

@DriftAccessor(tables: [RouteWaypoints])
class RouteWaypointDao extends DatabaseAccessor<AppDatabase>
    with _$RouteWaypointDaoMixin {
  RouteWaypointDao(super.db);

  /// Fetch all waypoints for an album
  Stream<List<RouteWaypoint>> watchWaypointsForAlbum(String albumId) {
    return (select(routeWaypoints)
          ..where((w) => w.albumId.equals(albumId))
          ..orderBy([
            (w) => OrderingTerm(
              expression: w.segmentOrder,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }

  /// Insert a waypoint
  Future<int> insertWaypoint(RouteWaypointsCompanion waypoint) {
    return into(routeWaypoints).insert(waypoint);
  }

  /// Delete waypoints for an album
  Future<int> deleteWaypointsForAlbum(String albumId) {
    return (delete(
      routeWaypoints,
    )..where((w) => w.albumId.equals(albumId))).go();
  }

  /// Clear all waypoints across all albums
  Future<int> clearAll() {
    return delete(routeWaypoints).go();
  }
}
