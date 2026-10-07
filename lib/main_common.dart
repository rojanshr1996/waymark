import 'package:flutter/material.dart';
import 'package:waymark/app.dart';
import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/core/services/backup_service.dart';
import 'package:waymark/core/services/notification_service.dart';

Future<void> mainCommon(AppFlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification & cloud messaging services
  await NotificationService.instance.initialize();

  // Attempt auto-backup every time the app is opened (if database has data)
  BackupService.checkAndRunAutoBackup();

  if (config.enableLogging) {
    debugPrint('----------------------------------------');
    debugPrint('Starting Wanderline [Flavor: ${config.flavor.name}]');
    // debugPrint('Base URL: ${config.apiBaseUrl}');
    debugPrint('----------------------------------------');
  }

  runApp(const WaymarkApp());
}
