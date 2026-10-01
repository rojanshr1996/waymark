import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import 'notification_service.dart';

class ActiveDataSummary {
  final int albumCount;
  final int placeCount;
  final DateTime? latestTimestamp;
  final bool isEmpty;

  const ActiveDataSummary({
    required this.albumCount,
    required this.placeCount,
    this.latestTimestamp,
    required this.isEmpty,
  });
}

class RestoreValidationResult {
  final bool isSafeToRestore;
  final ActiveDataSummary activeSummary;
  final DateTime backupTimestamp;
  final String? blockReason;

  const RestoreValidationResult({
    required this.isSafeToRestore,
    required this.activeSummary,
    required this.backupTimestamp,
    this.blockReason,
  });
}

class BackupService {
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _lastBackupTimeKey = 'last_backup_time';

  // Toggle state
  static Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Auto backup is enabled by default
    return prefs.getBool(_autoBackupEnabledKey) ?? true;
  }

  static Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }

  /// Query active database records to find count of albums, places, and newest timestamp
  static Future<ActiveDataSummary> getActiveDataSummary() async {
    final db = AppDatabase.instance;
    final albums = await db.select(db.tripAlbums).get();
    final places = await db.tripPlaceDao.getAllPlaces();

    if (albums.isEmpty && places.isEmpty) {
      return const ActiveDataSummary(
        albumCount: 0,
        placeCount: 0,
        latestTimestamp: null,
        isEmpty: true,
      );
    }

    DateTime? latest;
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
      latestTimestamp: latest,
      isEmpty: false,
    );
  }

  /// Extract timestamp from backup filename (waymark_backup_yyyyMMdd_HHmmss.sqlite)
  /// falling back to file modification time
  static DateTime getBackupTimestamp(File backupFile) {
    final fileName = p.basename(backupFile.path);
    final match = RegExp(
      r'waymark_backup_(\d{8}_\d{6})\.sqlite',
    ).firstMatch(fileName);
    if (match != null) {
      try {
        return DateFormat('yyyyMMdd_HHmmss').parse(match.group(1)!);
      } catch (_) {}
    }
    return backupFile.lastModifiedSync();
  }

  /// Validate if it is safe to restore this backup.
  /// Prevents restoring if the current database contains information added or updated
  /// newer than the backup snapshot.
  static Future<RestoreValidationResult> validateRestoreSafety(
    File backupFile,
  ) async {
    final activeSummary = await getActiveDataSummary();
    final backupTimestamp = getBackupTimestamp(backupFile);

    if (!activeSummary.isEmpty && activeSummary.latestTimestamp != null) {
      if (activeSummary.latestTimestamp!.isAfter(backupTimestamp)) {
        return RestoreValidationResult(
          isSafeToRestore: false,
          activeSummary: activeSummary,
          backupTimestamp: backupTimestamp,
          blockReason:
              'Your current journal has records newer than this backup snapshot. Restoring would overwrite your recent entries.',
        );
      }
    }

    return RestoreValidationResult(
      isSafeToRestore: true,
      activeSummary: activeSummary,
      backupTimestamp: backupTimestamp,
      blockReason: null,
    );
  }

  // Backup Execution
  static Future<String?> createBackup({bool isManual = false}) async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!downloadDir.existsSync()) {
        try {
          downloadDir.createSync(recursive: true);
        } catch (e) {
          throw Exception(
            "Unable to access Downloads folder. Permission denied.",
          );
        }
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'waymark_db.sqlite'));

      if (!dbFile.existsSync()) {
        throw Exception("Database file not found. Nothing to backup.");
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'waymark_backup_$timestamp.sqlite';
      final backupFile = File(p.join(downloadDir.path, backupFileName));

      try {
        await dbFile.copy(backupFile.path);
      } catch (e) {
        throw Exception(
          "Failed to write to Downloads folder. Please check permissions.",
        );
      }

      if (!isManual) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          _lastBackupTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      // Show local push notification alert when backup completes
      try {
        final fileSizeBytes = await backupFile.length();
        await NotificationService.instance.showBackupCompletedNotification(
          backupPath: backupFile.path,
          fileSizeBytes: fileSizeBytes,
        );
      } catch (e) {
        debugPrint('Backup completed notification notice: $e');
      }

      return backupFile.path;
    } else {
      // For non-Android platforms, we could use standard path_provider locations,
      // but the requirement specifically asks for Android Downloads folder.
      throw Exception(
        "Automated local backup is only supported on Android devices.",
      );
    }
  }

  static Future<void> checkAndRunAutoBackup() async {
    if (!await isAutoBackupEnabled()) return;

    final prefs = await SharedPreferences.getInstance();
    final lastBackupMillis = prefs.getInt(_lastBackupTimeKey) ?? 0;
    final lastBackupTime = DateTime.fromMillisecondsSinceEpoch(
      lastBackupMillis,
    );

    final difference = DateTime.now().difference(lastBackupTime);
    // Backup every 2 days
    if (difference.inDays >= 2 || lastBackupMillis == 0) {
      try {
        await createBackup(isManual: false);
      } catch (e) {
        // Silently fail for background auto-backup
      }
    }
  }

  static Future<List<File>> getAvailableBackups() async {
    if (!Platform.isAndroid) return [];

    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!downloadDir.existsSync()) return [];

    try {
      final files = downloadDir.listSync().whereType<File>().where((file) {
        final basename = p.basename(file.path);
        return basename.startsWith('waymark_backup_') &&
            basename.endsWith('.sqlite');
      }).toList();

      // Sort newest first
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e) {
      return [];
    }
  }

  static Future<void> restoreBackup(File backupFile) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'waymark_db.sqlite'));

    // Close existing DB to release lock
    await AppDatabase.instance.close();

    // Delete old
    if (dbFile.existsSync()) {
      await dbFile.delete();
    }

    // Copy new
    await backupFile.copy(dbFile.path);

    // Re-open DB by resetting the instance
    AppDatabase.resetInstance();
  }
}
