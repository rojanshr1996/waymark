import 'package:drift/drift.dart';

class UserProfiles extends Table {
  TextColumn get id => text()(); // UUID v4 or singleton key
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get handle => text().withLength(min: 1, max: 50)();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get archetype => text().withDefault(
    const Constant('Wayfarer'),
  )(); // Wayfarer, Alpinist, Urban Flâneur, Cyclotourist, Backpacker
  TextColumn get bio => text().nullable()();
  TextColumn get unitSystem =>
      text().withDefault(const Constant('metric'))(); // metric, imperial
  BoolColumn get autoExifGpsEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get vaultPath => text().withDefault(
    const Constant('/sandbox/documents/vault_001.drift'),
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
