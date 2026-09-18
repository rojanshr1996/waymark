import 'package:drift/drift.dart';

class TripAlbums extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('ONGOING'),
  )(); // ONGOING, COMPLETED, ARCHIVED
  RealColumn get totalDistanceKm => real().withDefault(const Constant(0.0))();
  IntColumn get totalPlacesCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TripPlaces extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get albumId =>
      text().references(TripAlbums, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  DateTimeColumn get visitedAt => dateTime()();
  IntColumn get visitOrder => integer()(); // Sequential index in trip
  TextColumn get weatherCondition => text().nullable()(); // Sunny, Rainy, etc.
  RealColumn get temperatureCelsius => real().nullable()();
  TextColumn get category => text().withDefault(
    const Constant('GENERAL'),
  )(); // SIGHTSEEING, FOOD, STAY, HIKE, TRANSIT
  TextColumn get locationAddress =>
      text().nullable()(); // Formatted address from map/search
  TextColumn get sensoryTags =>
      text().nullable()(); // Comma-separated sensory tags
  BoolColumn get isGpsFromExif => boolean().withDefault(
    const Constant(false),
  )(); // Flag if GPS matched from photo
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaceMediaFiles extends Table {
  TextColumn get id => text()();
  TextColumn get placeId =>
      text().references(TripPlaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get localFilePath => text()(); // Sandbox relative path
  TextColumn get thumbnailPath => text()(); // Low-res 200x200 path
  IntColumn get fileSizeBytes => integer()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  BoolColumn get isCoverPhoto => boolean().withDefault(const Constant(false))();
  DateTimeColumn get capturedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RouteWaypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get albumId =>
      text().references(TripAlbums, #id, onDelete: KeyAction.cascade)();
  IntColumn get segmentOrder =>
      integer()(); // Segment between Place N and Place N+1
  TextColumn get encodedPolyline =>
      text()(); // Google Polyline algorithm string
  RealColumn get segmentDistanceMeters => real()();
  IntColumn get estimatedDurationSeconds => integer().nullable()();
}
