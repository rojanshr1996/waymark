import 'package:flutter/material.dart';
import 'package:waymark/app.dart';
import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/core/services/backup_service.dart';
import 'package:waymark/core/services/notification_service.dart';

Future<void> mainCommon(AppFlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification & cloud messaging services
  await NotificationService.instance.initialize();

  // Attempt auto-backup (runs every 2 days if enabled)
  BackupService.checkAndRunAutoBackup();

  if (config.enableLogging) {
    debugPrint('----------------------------------------');
    debugPrint('Starting Waymark [Flavor: ${config.flavor.name}]');
    // debugPrint('Base URL: ${config.apiBaseUrl}');
    debugPrint('----------------------------------------');
  }

  runApp(const WaymarkApp());
}
