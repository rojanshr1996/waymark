import 'package:flutter/material.dart';
import 'package:waymark/app.dart';
import 'package:waymark/core/config/flavor_config.dart';

Future<void> mainCommon(AppFlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (config.enableLogging) {
    debugPrint('----------------------------------------');
    debugPrint('Starting Waymark [Flavor: ${config.flavor.name}]');
    // debugPrint('Base URL: ${config.apiBaseUrl}');
    debugPrint('----------------------------------------');
  }

  runApp(const WaymarkApp());
}
