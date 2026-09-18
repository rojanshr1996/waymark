import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_profile_table.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Fetch the current traveler profile
  Future<UserProfile?> getProfile() {
    return (select(userProfiles)..limit(1)).getSingleOrNull();
  }

  /// Watch the traveler profile reactively
  Stream<UserProfile?> watchProfile() {
    return (select(userProfiles)..limit(1)).watchSingleOrNull();
  }

  /// Insert or update the traveler profile
  Future<void> createOrUpdateProfile(UserProfilesCompanion profile) async {
    final existing = await getProfile();
    if (existing == null) {
      final toInsert = profile.id.present
          ? profile
          : profile.copyWith(id: const Value('default_user'));
      await into(userProfiles).insert(toInsert);
    } else {
      await (update(
        userProfiles,
      )..where((t) => t.id.equals(existing.id))).write(profile);
    }
  }

  /// Delete all traveler profiles
  Future<int> clearAll() {
    return delete(userProfiles).go();
  }
}
