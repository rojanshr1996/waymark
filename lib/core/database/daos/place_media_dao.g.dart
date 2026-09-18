// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_media_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaceMediaDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripAlbumsTable get tripAlbums => attachedDatabase.tripAlbums;
  $TripPlacesTable get tripPlaces => attachedDatabase.tripPlaces;
  $PlaceMediaFilesTable get placeMediaFiles => attachedDatabase.placeMediaFiles;
  PlaceMediaDaoManager get managers => PlaceMediaDaoManager(this);
}

class PlaceMediaDaoManager {
  final _$PlaceMediaDaoMixin _db;
  PlaceMediaDaoManager(this._db);
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
