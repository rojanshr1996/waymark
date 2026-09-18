// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_album_dao.dart';

// ignore_for_file: type=lint
mixin _$TripAlbumDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripAlbumsTable get tripAlbums => attachedDatabase.tripAlbums;
  TripAlbumDaoManager get managers => TripAlbumDaoManager(this);
}

class TripAlbumDaoManager {
  final _$TripAlbumDaoMixin _db;
  TripAlbumDaoManager(this._db);
  $$TripAlbumsTableTableManager get tripAlbums =>
      $$TripAlbumsTableTableManager(_db.attachedDatabase, _db.tripAlbums);
}
