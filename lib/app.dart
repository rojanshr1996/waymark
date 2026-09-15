import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/core/theme/waymark_theme.dart';

class WaymarkApp extends StatelessWidget {
  const WaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppFlavorConfig.instance;

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard modern mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: config.appTitle,
          debugShowCheckedModeBanner: !config.flavor.isProduction,
          theme: WaymarkTheme.lightTheme,
          home: FlavorHomeScreen(config: config),
        );
      },
    );
  }
}

class FlavorHomeScreen extends StatelessWidget {
  final AppFlavorConfig config;

  const FlavorHomeScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.appTitle),
        centerTitle: true,
        actions: [
          if (!config.flavor.isProduction)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Chip(
                label: Text(
                  config.flavor.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Environment: ${config.flavor.displayName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('App Name', config.appTitle),
                  _buildInfoRow('Flavor Identifier', config.flavor.name),
                  _buildInfoRow('API Endpoint', config.apiBaseUrl),
                  _buildInfoRow(
                    'Debug Logging',
                    config.enableLogging ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
