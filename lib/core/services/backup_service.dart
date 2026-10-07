import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import 'notification_service.dart';

/// Summary of current database contents used to prevent restoring older
/// backups over newer active journal data.
class ActiveDataSummary {
  final int albumCount;
  final int placeCount;
  final bool hasProfile;
  final DateTime? latestTimestamp;
  final bool isEmpty;

  const ActiveDataSummary({
    required this.albumCount,
    required this.placeCount,
    this.hasProfile = false,
    this.latestTimestamp,
    required this.isEmpty,
  });
}

/// Validation result when inspecting a backup file before restoration.
class RestoreValidationResult {
  final bool isSafeToRestore;
  final ActiveDataSummary activeSummary;
  final DateTime backupTimestamp;
  final String? blockReason;
  final int? backupSignature;
  final bool isSignatureMatch;

  const RestoreValidationResult({
    required this.isSafeToRestore,
    required this.activeSummary,
    required this.backupTimestamp,
    this.blockReason,
    this.backupSignature,
    this.isSignatureMatch = true,
  });
}

/// Comprehensive service for managing journey and memoir backups.
///
/// Exports data to human-readable, portable CSV format stored inside the
/// `waymark` folder in the user's Downloads directory (Android) or Documents
/// directory (iOS).
///
/// Filenames follow the convention:
///   `<app_name>_<app_signature>.csv` (e.g. `wanderline_1.csv`)
/// where the integer denotes the app signature.
class BackupService {
  static const String appName = 'wanderline';

  /// The integer value denoting the app signature and schema compatibility.
  /// Used in file naming (e.g., wanderline_1.csv) and internal CSV header metadata.
  static const int appSignature = 1;

  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _lastBackupTimeKey = 'last_backup_time';

  // Toggle state
  static Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupEnabledKey) ?? true;
  }

  static Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }

  /// Locates or creates the dedicated `waymark` directory inside the platform's
  /// Download/Downloads (Android) or Documents/Downloads (iOS) storage.
  ///
  /// If the `waymark` folder is not present, it will automatically be created.
  static Future<Directory> getBackupDirectory() async {
    Directory baseDir;

    if (Platform.isAndroid) {
      try {
        final manageGranted = await Permission.manageExternalStorage.isGranted;
        if (!manageGranted) {
          await Permission.manageExternalStorage.request();
        }
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }
      } catch (e) {
        debugPrint('Android storage permission request note: $e');
      }

      final primaryDownload = Directory('/storage/emulated/0/Download');
      final secondaryDownload = Directory('/storage/emulated/0/Downloads');

      if (primaryDownload.existsSync()) {
        baseDir = primaryDownload;
      } else if (secondaryDownload.existsSync()) {
        baseDir = secondaryDownload;
      } else {
        final extDir = await getExternalStorageDirectory();
        baseDir = extDir ?? await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      final downloadsDir = await getDownloadsDirectory();
      baseDir = downloadsDir ?? await getApplicationDocumentsDirectory();
    } else {
      final downloadsDir = await getDownloadsDirectory();
      baseDir = downloadsDir ?? await getApplicationDocumentsDirectory();
    }

    final waymarkDir = Directory(p.join(baseDir.path, appName));
    if (!waymarkDir.existsSync()) {
      try {
        await waymarkDir.create(recursive: true);
      } catch (e) {
        debugPrint('Could not create waymark directory in ${baseDir.path}: $e');
        // Graceful fallback to app documents directory if public storage is restricted
        final docsDir = await getApplicationDocumentsDirectory();
        final fallbackDir = Directory(p.join(docsDir.path, appName));
        if (!fallbackDir.existsSync()) {
          await fallbackDir.create(recursive: true);
        }
        return fallbackDir;
      }
    }

    return waymarkDir;
  }

  /// Query active database records to find count of albums, places, profile, and newest timestamp
  static Future<ActiveDataSummary> getActiveDataSummary() async {
    final db = AppDatabase.instance;
    final albums = await db.select(db.tripAlbums).get();
    final places = await db.tripPlaceDao.getAllPlaces();
    final profile = await db.userProfileDao.getProfile();

    if (albums.isEmpty && places.isEmpty) {
      return ActiveDataSummary(
        albumCount: 0,
        placeCount: 0,
        hasProfile: profile != null,
        latestTimestamp: profile?.createdAt,
        isEmpty: true,
      );
    }

    DateTime? latest;
    if (profile != null) {
      latest = profile.updatedAt;
      if (profile.createdAt.isAfter(latest)) {
        latest = profile.createdAt;
      }
    }

    for (final album in albums) {
      if (latest == null || album.updatedAt.isAfter(latest)) {
        latest = album.updatedAt;
      }
      if (album.createdAt.isAfter(latest)) {
        latest = album.createdAt;
      }
    }

    for (final place in places) {
      if (latest == null || place.visitedAt.isAfter(latest)) {
        latest = place.visitedAt;
      }
      if (place.createdAt.isAfter(latest)) {
        latest = place.createdAt;
      }
    }

    return ActiveDataSummary(
      albumCount: albums.length,
      placeCount: places.length,
      hasProfile: profile != null,
      latestTimestamp: latest,
      isEmpty: false,
    );
  }

  /// Returns true if the app contains at least 1 record of data (profile, journey, or place).
  static Future<bool> hasAnyData() async {
    final summary = await getActiveDataSummary();
    return !summary.isEmpty;
  }

  /// Extracts the integer app signature from the backup filename or CSV header.
  /// E.g. `waymark_1.csv` -> 1, `waymark_1_20261004_120000.csv` -> 1.
  static int? getBackupSignature(File backupFile) {
    final fileName = p.basename(backupFile.path);
    final match = RegExp('^(?:${appName}|waymark)_(\\d+)').firstMatch(fileName);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    if (fileName.endsWith('.csv')) {
      try {
        final firstLine = backupFile.readAsLinesSync().firstOrNull;
        if (firstLine != null &&
            (firstLine.startsWith('# WANDERLINE_BACKUP') ||
                firstLine.startsWith('# WAYMARK_BACKUP'))) {
          final sigMatch = RegExp(r'app_signature=(\d+)').firstMatch(firstLine);
          if (sigMatch != null) {
            return int.tryParse(sigMatch.group(1)!);
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Checks if backup file has an app signature matching current app.
  static bool isSignatureMatch(File backupFile) {
    if (backupFile.path.endsWith('.sqlite')) {
      return true; // Legacy SQLite backup
    }
    final sig = getBackupSignature(backupFile);
    return sig != null && sig == appSignature;
  }

  /// Extract timestamp from backup filename or file header
  static DateTime getBackupTimestamp(File backupFile) {
    final fileName = p.basename(backupFile.path);

    // Pattern 1: <app_name>_1_yyyyMMdd_HHmmss.csv or waymark_1_yyyyMMdd_HHmmss.csv
    final csvTimestampMatch = RegExp(
      r'_(\d{8}_\d{6})\.csv$',
    ).firstMatch(fileName);
    if (csvTimestampMatch != null) {
      try {
        return DateFormat('yyyyMMdd_HHmmss').parse(csvTimestampMatch.group(1)!);
      } catch (_) {}
    }

    // Pattern 2: legacy sqlite backup
    final sqliteMatch = RegExp(
      r'(?:wanderline|waymark)_backup_(\d{8}_\d{6})\.sqlite',
    ).firstMatch(fileName);
    if (sqliteMatch != null) {
      try {
        return DateFormat('yyyyMMdd_HHmmss').parse(sqliteMatch.group(1)!);
      } catch (_) {}
    }

    // Pattern 3: read timestamp from CSV header
    if (fileName.endsWith('.csv')) {
      try {
        final firstLine = backupFile.readAsLinesSync().firstOrNull;
        if (firstLine != null &&
            (firstLine.startsWith('# WANDERLINE_BACKUP') ||
                firstLine.startsWith('# WAYMARK_BACKUP'))) {
          final tsMatch = RegExp(r'timestamp=([^\s,]+)').firstMatch(firstLine);
          if (tsMatch != null) {
            final parsed = DateTime.tryParse(tsMatch.group(1)!);
            if (parsed != null) return parsed;
          }
        }
      } catch (_) {}
    }

    return backupFile.lastModifiedSync();
  }

  /// Validate if it is safe to restore this backup.
  /// Verifies app signature match and prevents restoring if the current database
  /// contains information added or updated newer than the backup snapshot.
  static Future<RestoreValidationResult> validateRestoreSafety(
    File backupFile,
  ) async {
    final activeSummary = await getActiveDataSummary();
    final backupTimestamp = getBackupTimestamp(backupFile);
    final backupSignature = getBackupSignature(backupFile);
    final matchesSig = isSignatureMatch(backupFile);

    // 1. Signature mismatch guard
    if (!matchesSig && backupSignature != null) {
      return RestoreValidationResult(
        isSafeToRestore: false,
        activeSummary: activeSummary,
        backupTimestamp: backupTimestamp,
        backupSignature: backupSignature,
        isSignatureMatch: false,
        blockReason:
            'This backup was created with App Signature $backupSignature, which does not match your current App Signature $appSignature. Restoring across mismatched app signatures is blocked to prevent data corruption.',
      );
    }

    // 2. Prevent overwriting newer records with an older snapshot
    if (!activeSummary.isEmpty && activeSummary.latestTimestamp != null) {
      if (activeSummary.latestTimestamp!.isAfter(backupTimestamp)) {
        return RestoreValidationResult(
          isSafeToRestore: false,
          activeSummary: activeSummary,
          backupTimestamp: backupTimestamp,
          backupSignature: backupSignature,
          isSignatureMatch: true,
          blockReason:
              'Your current journal has records newer than this backup snapshot. Restoring would overwrite your recent entries.',
        );
      }
    }

    return RestoreValidationResult(
      isSafeToRestore: true,
      activeSummary: activeSummary,
      backupTimestamp: backupTimestamp,
      backupSignature: backupSignature,
      isSignatureMatch: true,
      blockReason: null,
    );
  }

  /// Encodes all relational Drift tables into a portable, structured CSV format.
  static Future<String> generateCsvContent() async {
    final db = AppDatabase.instance;
    final buffer = StringBuffer();

    // 1. Header Metadata
    final nowIso = DateTime.now().toIso8601String();
    buffer.writeln(
      '# WANDERLINE_BACKUP,app_name=$appName,app_signature=$appSignature,timestamp=$nowIso',
    );

    // 2. User Profile
    final profiles = await db.select(db.userProfiles).get();
    buffer.writeln('# TABLE:user_profiles');
    buffer.writeln(
      _csvRow([
        'id',
        'fullName',
        'handle',
        'avatarPath',
        'archetype',
        'bio',
        'unitSystem',
        'autoExifGpsEnabled',
        'vaultPath',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final p in profiles) {
      buffer.writeln(
        _csvRow([
          p.id,
          p.fullName,
          p.handle,
          p.avatarPath,
          p.archetype,
          p.bio,
          p.unitSystem,
          p.autoExifGpsEnabled,
          p.vaultPath,
          p.createdAt,
          p.updatedAt,
        ]),
      );
    }

    // 3. Trip Albums
    final albums = await db.select(db.tripAlbums).get();
    buffer.writeln('# TABLE:trip_albums');
    buffer.writeln(
      _csvRow([
        'id',
        'title',
        'description',
        'startDate',
        'endDate',
        'coverImagePath',
        'status',
        'totalDistanceKm',
        'totalPlacesCount',
        'createdAt',
        'updatedAt',
      ]),
    );
    for (final a in albums) {
      buffer.writeln(
        _csvRow([
          a.id,
          a.title,
          a.description,
          a.startDate,
          a.endDate,
          a.coverImagePath,
          a.status,
          a.totalDistanceKm,
          a.totalPlacesCount,
          a.createdAt,
          a.updatedAt,
        ]),
      );
    }

    // 4. Trip Places
    final places = await db.select(db.tripPlaces).get();
    buffer.writeln('# TABLE:trip_places');
    buffer.writeln(
      _csvRow([
        'id',
        'albumId',
        'name',
        'notes',
        'latitude',
        'longitude',
        'altitude',
        'visitedAt',
        'visitOrder',
        'weatherCondition',
        'temperatureCelsius',
        'category',
        'locationAddress',
        'sensoryTags',
        'isGpsFromExif',
        'createdAt',
      ]),
    );
    for (final pl in places) {
      buffer.writeln(
        _csvRow([
          pl.id,
          pl.albumId,
          pl.name,
          pl.notes,
          pl.latitude,
          pl.longitude,
          pl.altitude,
          pl.visitedAt,
          pl.visitOrder,
          pl.weatherCondition,
          pl.temperatureCelsius,
          pl.category,
          pl.locationAddress,
          pl.sensoryTags,
          pl.isGpsFromExif,
          pl.createdAt,
        ]),
      );
    }

    // 5. Place Media Files
    final media = await db.select(db.placeMediaFiles).get();
    buffer.writeln('# TABLE:place_media_files');
    buffer.writeln(
      _csvRow([
        'id',
        'placeId',
        'localFilePath',
        'thumbnailPath',
        'fileSizeBytes',
        'width',
        'height',
        'isCoverPhoto',
        'capturedAt',
      ]),
    );
    for (final m in media) {
      buffer.writeln(
        _csvRow([
          m.id,
          m.placeId,
          m.localFilePath,
          m.thumbnailPath,
          m.fileSizeBytes,
          m.width,
          m.height,
          m.isCoverPhoto,
          m.capturedAt,
        ]),
      );
    }

    // 6. Route Waypoints
    final waypoints = await db.select(db.routeWaypoints).get();
    buffer.writeln('# TABLE:route_waypoints');
    buffer.writeln(
      _csvRow([
        'id',
        'albumId',
        'segmentOrder',
        'encodedPolyline',
        'segmentDistanceMeters',
        'estimatedDurationSeconds',
      ]),
    );
    for (final w in waypoints) {
      buffer.writeln(
        _csvRow([
          w.id,
          w.albumId,
          w.segmentOrder,
          w.encodedPolyline,
          w.segmentDistanceMeters,
          w.estimatedDurationSeconds,
        ]),
      );
    }

    return buffer.toString();
  }

  /// RFC 4180 compliant CSV field escaping
  static String _csvEscape(dynamic val) {
    if (val == null) return '';
    if (val is DateTime) return val.toIso8601String();
    if (val is bool) return val ? 'true' : 'false';
    final s = val.toString();
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _csvRow(List<dynamic> values) {
    return values.map(_csvEscape).join(',');
  }

  /// Parses CSV content considering multi-line quoted fields and escaped quotes
  static List<List<String>> parseCsv(String text) {
    final List<List<String>> rows = [];
    final StringBuffer currentField = StringBuffer();
    List<String> currentRow = [];
    bool inQuotes = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            currentField.write('"');
            i++; // skip escaped quote
          } else {
            inQuotes = false;
          }
        } else {
          currentField.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentField.toString());
          currentField.clear();
        } else if (char == '\n' || char == '\r') {
          if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') {
            i++; // skip \n in \r\n
          }
          currentRow.add(currentField.toString());
          currentField.clear();
          rows.add(currentRow);
          currentRow = [];
        } else {
          currentField.write(char);
        }
      }
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString());
      rows.add(currentRow);
    }

    return rows;
  }

  /// Creates a backup and saves it inside the `waymark` folder in Downloads/Documents.
  ///
  /// The backup is saved as `<app_name>_<app_signature>.csv` (e.g. `waymark_1.csv`)
  /// matching the exact app signature.
  ///
  /// Only creates a backup if the app contains at least 1 journey or place.
  /// If the journal is empty, no backup file is created.
  static Future<String?> createBackup({bool isManual = false}) async {
    final summary = await getActiveDataSummary();
    if (summary.isEmpty) {
      if (isManual) {
        throw Exception(
          'Your journal is currently empty. Add at least one journey or place before creating a backup.',
        );
      }
      debugPrint('Backup skipped: Journal has no journeys or places.');
      return null;
    }

    final targetDir = await getBackupDirectory();
    final csvContent = await generateCsvContent();

    // Canonical matching file: waymark_<appSignature>.csv
    final canonicalFileName = '${appName}_$appSignature.csv';
    final canonicalFile = File(p.join(targetDir.path, canonicalFileName));

    try {
      await canonicalFile.writeAsString(csvContent, flush: true);
    } catch (e) {
      throw Exception(
        'Failed to write backup to ${canonicalFile.path}: $e. Please verify storage permissions.',
      );
    }

    // When manual, also save a timestamped archive snapshot
    if (isManual) {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final timestampedFileName = '${appName}_${appSignature}_$timestamp.csv';
      final timestampedFile = File(p.join(targetDir.path, timestampedFileName));
      try {
        await timestampedFile.writeAsString(csvContent, flush: true);
      } catch (_) {}
    }

    if (!isManual) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastBackupTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // Trigger local push alert ONLY on manual backup
    if (isManual) {
      try {
        final fileSizeBytes = await canonicalFile.length();
        await NotificationService.instance.showBackupCompletedNotification(
          backupPath: canonicalFile.path,
          fileSizeBytes: fileSizeBytes,
        );
      } catch (e) {
        debugPrint('Backup completed notification notice: $e');
      }
    }

    return canonicalFile.path;
  }

  static DateTime? _lastAutoBackupRun;
  static bool _isBackupInProgress = false;

  /// Automatically creates a backup every time the app is opened, as long
  /// as auto-backup is enabled and the app contains at least 1 journey or place.
  static Future<String?> checkAndRunAutoBackup() async {
    if (_isBackupInProgress) return null;
    if (!await isAutoBackupEnabled()) {
      debugPrint('Auto backup skipped: Disabled in settings.');
      return null;
    }

    // Debounce: Avoid re-running within 2 minutes of the last auto-backup
    if (_lastAutoBackupRun != null &&
        DateTime.now().difference(_lastAutoBackupRun!).inMinutes < 2) {
      return null;
    }

    final hasData = await hasAnyData();
    if (!hasData) {
      debugPrint('Auto backup skipped: No journey or place data to backup.');
      return null;
    }

    _isBackupInProgress = true;
    try {
      final path = await createBackup(isManual: false);
      _lastAutoBackupRun = DateTime.now();
      return path;
    } catch (e) {
      debugPrint('Silent auto backup note: $e');
      return null;
    } finally {
      _isBackupInProgress = false;
    }
  }

  /// Lists all available backup files from the `waymark` folder (and parent downloads as fallback).
  static Future<List<File>> getAvailableBackups() async {
    final List<File> files = [];
    final targetDir = await getBackupDirectory();

    void scanDir(Directory dir) {
      if (!dir.existsSync()) return;
      try {
        for (final entity in dir.listSync()) {
          if (entity is File) {
            final name = p.basename(entity.path);
            if (((name.startsWith('${appName}_') ||
                        name.startsWith('waymark_')) &&
                    name.endsWith('.csv')) ||
                ((name.startsWith('wanderline_backup_') ||
                        name.startsWith('waymark_backup_')) &&
                    name.endsWith('.sqlite'))) {
              files.add(entity);
            }
          }
        }
      } catch (e) {
        debugPrint('Error listing directory ${dir.path}: $e');
      }
    }

    // 1. Scan primary wanderline directory
    scanDir(targetDir);

    // 2. Scan legacy waymark directory if present
    final legacyDir = Directory(p.join(targetDir.parent.path, 'waymark'));
    if (legacyDir.existsSync() && legacyDir.path != targetDir.path) {
      scanDir(legacyDir);
    }

    // 3. Scan parent download directory for backward compatibility
    if (targetDir.parent.existsSync() &&
        targetDir.parent.path != targetDir.path) {
      scanDir(targetDir.parent);
    }

    // Deduplicate by canonical path
    final Map<String, File> uniqueFiles = {};
    for (final f in files) {
      uniqueFiles[p.canonicalize(f.path)] = f;
    }

    final result = uniqueFiles.values.toList();
    // Sort newest first
    result.sort((a, b) {
      final timeA = getBackupTimestamp(a);
      final timeB = getBackupTimestamp(b);
      return timeB.compareTo(timeA);
    });

    return result;
  }

  /// Restores journal data from the specified backup file.
  static Future<void> restoreBackup(File backupFile) async {
    if (backupFile.path.endsWith('.csv')) {
      await _restoreFromCsv(backupFile);
    } else {
      await _restoreFromSqlite(backupFile);
    }
  }

  /// Restores database records from structured CSV
  static Future<void> _restoreFromCsv(File backupFile) async {
    final text = await backupFile.readAsString();
    final rows = parseCsv(text);

    String? currentTable;
    List<String>? currentHeaders;
    final Map<String, List<Map<String, String>>> tableData = {
      'user_profiles': [],
      'trip_albums': [],
      'trip_places': [],
      'place_media_files': [],
      'route_waypoints': [],
    };

    for (final row in rows) {
      if (row.isEmpty) continue;
      final firstCell = row.first.trim();
      if (firstCell.startsWith('# WANDERLINE_BACKUP') ||
          firstCell.startsWith('# WAYMARK_BACKUP')) {
        continue;
      }
      if (firstCell.startsWith('# TABLE:')) {
        currentTable = firstCell.substring('# TABLE:'.length).trim();
        currentHeaders = null;
        continue;
      }
      if (firstCell.startsWith('#')) {
        continue;
      }

      if (currentTable != null && tableData.containsKey(currentTable)) {
        if (currentHeaders == null) {
          currentHeaders = row.map((e) => e.trim()).toList();
        } else {
          final map = <String, String>{};
          for (int i = 0; i < currentHeaders.length && i < row.length; i++) {
            map[currentHeaders[i]] = row[i];
          }
          tableData[currentTable]!.add(map);
        }
      }
    }

    final db = AppDatabase.instance;
    await db.transaction(() async {
      // Clear database tables in foreign key cascade order
      await db.clearEntireDatabase();

      // 1. User Profiles
      for (final r in tableData['user_profiles']!) {
        await db
            .into(db.userProfiles)
            .insert(
              UserProfilesCompanion(
                id: drift.Value(r['id']!),
                fullName: drift.Value(r['fullName'] ?? ''),
                handle: drift.Value(r['handle'] ?? ''),
                avatarPath: drift.Value(
                  r['avatarPath']?.isNotEmpty == true ? r['avatarPath'] : null,
                ),
                archetype: drift.Value(
                  r['archetype']?.isNotEmpty == true
                      ? r['archetype']!
                      : 'Wayfarer',
                ),
                bio: drift.Value(
                  r['bio']?.isNotEmpty == true ? r['bio'] : null,
                ),
                unitSystem: drift.Value(
                  r['unitSystem']?.isNotEmpty == true
                      ? r['unitSystem']!
                      : 'metric',
                ),
                autoExifGpsEnabled: drift.Value(
                  r['autoExifGpsEnabled'] == 'true',
                ),
                vaultPath: drift.Value(
                  r['vaultPath']?.isNotEmpty == true
                      ? r['vaultPath']!
                      : '/sandbox/documents/vault_001.drift',
                ),
                createdAt: drift.Value(
                  DateTime.tryParse(r['createdAt'] ?? '') ?? DateTime.now(),
                ),
                updatedAt: drift.Value(
                  DateTime.tryParse(r['updatedAt'] ?? '') ?? DateTime.now(),
                ),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      }

      // 2. Trip Albums
      for (final r in tableData['trip_albums']!) {
        await db
            .into(db.tripAlbums)
            .insert(
              TripAlbumsCompanion(
                id: drift.Value(r['id']!),
                title: drift.Value(r['title'] ?? ''),
                description: drift.Value(
                  r['description']?.isNotEmpty == true
                      ? r['description']
                      : null,
                ),
                startDate: drift.Value(
                  DateTime.tryParse(r['startDate'] ?? '') ?? DateTime.now(),
                ),
                endDate: drift.Value(
                  r['endDate']?.isNotEmpty == true
                      ? DateTime.tryParse(r['endDate']!)
                      : null,
                ),
                coverImagePath: drift.Value(
                  r['coverImagePath']?.isNotEmpty == true
                      ? r['coverImagePath']
                      : null,
                ),
                status: drift.Value(
                  r['status']?.isNotEmpty == true ? r['status']! : 'ONGOING',
                ),
                totalDistanceKm: drift.Value(
                  double.tryParse(r['totalDistanceKm'] ?? '0.0') ?? 0.0,
                ),
                totalPlacesCount: drift.Value(
                  int.tryParse(r['totalPlacesCount'] ?? '0') ?? 0,
                ),
                createdAt: drift.Value(
                  DateTime.tryParse(r['createdAt'] ?? '') ?? DateTime.now(),
                ),
                updatedAt: drift.Value(
                  DateTime.tryParse(r['updatedAt'] ?? '') ?? DateTime.now(),
                ),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      }

      // 3. Trip Places
      for (final r in tableData['trip_places']!) {
        await db
            .into(db.tripPlaces)
            .insert(
              TripPlacesCompanion(
                id: drift.Value(r['id']!),
                albumId: drift.Value(r['albumId']!),
                name: drift.Value(r['name'] ?? ''),
                notes: drift.Value(
                  r['notes']?.isNotEmpty == true ? r['notes'] : null,
                ),
                latitude: drift.Value(
                  double.tryParse(r['latitude'] ?? '0.0') ?? 0.0,
                ),
                longitude: drift.Value(
                  double.tryParse(r['longitude'] ?? '0.0') ?? 0.0,
                ),
                altitude: drift.Value(
                  r['altitude']?.isNotEmpty == true
                      ? double.tryParse(r['altitude']!)
                      : null,
                ),
                visitedAt: drift.Value(
                  DateTime.tryParse(r['visitedAt'] ?? '') ?? DateTime.now(),
                ),
                visitOrder: drift.Value(
                  int.tryParse(r['visitOrder'] ?? '0') ?? 0,
                ),
                weatherCondition: drift.Value(
                  r['weatherCondition']?.isNotEmpty == true
                      ? r['weatherCondition']
                      : null,
                ),
                temperatureCelsius: drift.Value(
                  r['temperatureCelsius']?.isNotEmpty == true
                      ? double.tryParse(r['temperatureCelsius']!)
                      : null,
                ),
                category: drift.Value(
                  r['category']?.isNotEmpty == true
                      ? r['category']!
                      : 'GENERAL',
                ),
                locationAddress: drift.Value(
                  r['locationAddress']?.isNotEmpty == true
                      ? r['locationAddress']
                      : null,
                ),
                sensoryTags: drift.Value(
                  r['sensoryTags']?.isNotEmpty == true
                      ? r['sensoryTags']
                      : null,
                ),
                isGpsFromExif: drift.Value(r['isGpsFromExif'] == 'true'),
                createdAt: drift.Value(
                  DateTime.tryParse(r['createdAt'] ?? '') ?? DateTime.now(),
                ),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      }

      // 4. Place Media Files
      for (final r in tableData['place_media_files']!) {
        await db
            .into(db.placeMediaFiles)
            .insert(
              PlaceMediaFilesCompanion(
                id: drift.Value(r['id']!),
                placeId: drift.Value(r['placeId']!),
                localFilePath: drift.Value(r['localFilePath'] ?? ''),
                thumbnailPath: drift.Value(r['thumbnailPath'] ?? ''),
                fileSizeBytes: drift.Value(
                  int.tryParse(r['fileSizeBytes'] ?? '0') ?? 0,
                ),
                width: drift.Value(int.tryParse(r['width'] ?? '0') ?? 0),
                height: drift.Value(int.tryParse(r['height'] ?? '0') ?? 0),
                isCoverPhoto: drift.Value(r['isCoverPhoto'] == 'true'),
                capturedAt: drift.Value(
                  r['capturedAt']?.isNotEmpty == true
                      ? DateTime.tryParse(r['capturedAt']!)
                      : null,
                ),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      }

      // 5. Route Waypoints
      for (final r in tableData['route_waypoints']!) {
        await db
            .into(db.routeWaypoints)
            .insert(
              RouteWaypointsCompanion(
                id:
                    r['id']?.isNotEmpty == true &&
                        int.tryParse(r['id']!) != null
                    ? drift.Value(int.parse(r['id']!))
                    : const drift.Value.absent(),
                albumId: drift.Value(r['albumId']!),
                segmentOrder: drift.Value(
                  int.tryParse(r['segmentOrder'] ?? '0') ?? 0,
                ),
                encodedPolyline: drift.Value(r['encodedPolyline'] ?? ''),
                segmentDistanceMeters: drift.Value(
                  double.tryParse(r['segmentDistanceMeters'] ?? '0.0') ?? 0.0,
                ),
                estimatedDurationSeconds: drift.Value(
                  r['estimatedDurationSeconds']?.isNotEmpty == true
                      ? int.tryParse(r['estimatedDurationSeconds']!)
                      : null,
                ),
              ),
              mode: drift.InsertMode.insertOrReplace,
            );
      }

      // Checkpoint WAL pages into database
      try {
        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      } catch (_) {}
    });
  }

  /// Legacy SQLite restoration with proper WAL and SHM lock cleanup
  static Future<void> _restoreFromSqlite(File backupFile) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'waymark_db.sqlite'));
    final walFile = File(p.join(dbFolder.path, 'waymark_db.sqlite-wal'));
    final shmFile = File(p.join(dbFolder.path, 'waymark_db.sqlite-shm'));

    // Checkpoint existing database if active
    try {
      await AppDatabase.instance.customStatement(
        'PRAGMA wal_checkpoint(TRUNCATE);',
      );
    } catch (_) {}

    // Close database connection
    await AppDatabase.instance.close();

    // Delete existing sqlite database and stale WAL/SHM artifacts
    if (dbFile.existsSync()) await dbFile.delete();
    if (walFile.existsSync()) await walFile.delete();
    if (shmFile.existsSync()) await shmFile.delete();

    // Copy backup sqlite file
    await backupFile.copy(dbFile.path);

    // Re-open DB by resetting the instance
    AppDatabase.resetInstance();
  }
}
