// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_place_dao.dart';

// ignore_for_file: type=lint
mixin _$TripPlaceDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripAlbumsTable get tripAlbums => attachedDatabase.tripAlbums;
  $TripPlacesTable get tripPlaces => attachedDatabase.tripPlaces;
  $PlaceMediaFilesTable get placeMediaFiles => attachedDatabase.placeMediaFiles;
  TripPlaceDaoManager get managers => TripPlaceDaoManager(this);
}

class TripPlaceDaoManager {
  final _$TripPlaceDaoMixin _db;
  TripPlaceDaoManager(this._db);
  $$TripAlbumsTableTableManager get tripAlbums =>
      $$TripAlbumsTableTableManager(_db.attachedDatabase, _db.tripAlbums);
  $$TripPlacesTableTableManager get tripPlaces =>
      $$TripPlacesTableTableManager(_db.attachedDatabase, _db.tripPlaces);
  $$PlaceMediaFilesTableTableManager get placeMediaFiles =>
      $$PlaceMediaFilesTableTableManager(
        _db.attachedDatabase,
        _db.placeMediaFiles,
      );
}
