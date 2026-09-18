// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_waypoint_dao.dart';

// ignore_for_file: type=lint
mixin _$RouteWaypointDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripAlbumsTable get tripAlbums => attachedDatabase.tripAlbums;
  $RouteWaypointsTable get routeWaypoints => attachedDatabase.routeWaypoints;
  RouteWaypointDaoManager get managers => RouteWaypointDaoManager(this);
}

class RouteWaypointDaoManager {
  final _$RouteWaypointDaoMixin _db;
  RouteWaypointDaoManager(this._db);
  $$TripAlbumsTableTableManager get tripAlbums =>
      $$TripAlbumsTableTableManager(_db.attachedDatabase, _db.tripAlbums);
  $$RouteWaypointsTableTableManager get routeWaypoints =>
      $$RouteWaypointsTableTableManager(
        _db.attachedDatabase,
        _db.routeWaypoints,
      );
}
