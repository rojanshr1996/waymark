import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waymark/core/services/remote_config_models.dart';
import 'package:waymark/firebase_options.dart';

/// Centralized service handling Firebase Remote Config parameter management,
/// version evaluation (force vs recommended updates), and live maintenance gating.
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  // --- Remote Config Keys ---
  static const String keyMinRequiredVersion = 'min_required_version';
  static const String keyLatestRecommendedVersion =
      'latest_recommended_version';
  static const String keyForceUpdateTitle = 'force_update_title';
  static const String keyForceUpdateMessage = 'force_update_message';
  static const String keyRecommendedUpdateTitle = 'recommended_update_title';
  static const String keyRecommendedUpdateMessage =
      'recommended_update_message';
  static const String keyUpdateReleaseNotes = 'update_release_notes';
  static const String keyUpdateStoreUrlAndroid = 'update_store_url_android';
  static const String keyUpdateStoreUrlIos = 'update_store_url_ios';
  static const String keyAllowRecommendedSkip = 'allow_recommended_skip';

  // Maintenance Keys
  static const String keyIsMaintenanceMode = 'is_maintenance_mode';
  static const String keyMaintenanceTitle = 'maintenance_title';
  static const String keyMaintenanceMessage = 'maintenance_message';
  static const String keyMaintenanceStartTime = 'maintenance_start_time';
  static const String keyMaintenanceEndTime = 'maintenance_end_time';
  static const String keyMaintenanceSupportEmail = 'maintenance_support_email';
  static const String keyMaintenanceStatusUrl = 'maintenance_status_url';
  static const String keyMaintenanceBypassKey = 'maintenance_bypass_key';

  // Preferences Keys
  static const String _prefSkippedRecommendedVersion =
      'skipped_recommended_version';
  static const String _prefMaintenanceBypassActive =
      'maintenance_bypass_active';

  // Default In-App Values
  static const Map<String, dynamic> defaultParameters = {
    keyMinRequiredVersion: '1.0.0',
    keyLatestRecommendedVersion: '1.0.0',
    keyForceUpdateTitle: 'Critical Update Required',
    keyForceUpdateMessage:
        'A vital new version of Wanderline is required to continue documenting your journeys with full offline stability and security. Please update to proceed.',
    keyRecommendedUpdateTitle: 'New Expedition Features Available',
    keyRecommendedUpdateMessage:
        'A new version of Wanderline is ready for you with enhanced field journal features, smoother mapping, and memory optimizations.',
    keyUpdateReleaseNotes:
        '• Offline vault speed & integrity improvements\n• Enhanced route waypoint trail drawing\n• High-resolution postcard photo exports\n• Refined battery and background sync consumption',
    keyUpdateStoreUrlAndroid:
        'https://play.google.com/store/apps/details?id=com.wanderline.app',
    keyUpdateStoreUrlIos:
        'https://apps.apple.com/app/wanderline-expedition-journal/id6449000000',
    keyAllowRecommendedSkip: true,
    keyIsMaintenanceMode: false,
    keyMaintenanceTitle: 'Under Scheduled Maintenance',
    keyMaintenanceMessage:
        'We are currently polishing the expedition trail to keep your field journals secure and dependable. Please check back shortly.',
    keyMaintenanceStartTime: '',
    keyMaintenanceEndTime: '',
    keyMaintenanceSupportEmail: 'support@wanderline.app',
    keyMaintenanceStatusUrl: 'https://status.wanderline.app',
    keyMaintenanceBypassKey: 'wanderline-crew-2026',
  };

  FirebaseRemoteConfig? _remoteConfig;
  StreamSubscription<RemoteConfigUpdate>? _realtimeSubscription;

  // Reactive State Notifiers (strictly conforming to zero setState architectural rule)
  final ValueNotifier<AppGateEvaluation> gateNotifier =
      ValueNotifier<AppGateEvaluation>(
        const AppGateEvaluation(
          status: AppGateStatus.normal,
          currentVersion: '1.0.0',
          minRequiredVersion: '1.0.0',
          latestRecommendedVersion: '1.0.0',
          title: '',
          message: '',
          releaseNotes: [],
          storeUrl: '',
          allowSkip: true,
        ),
      );

  final ValueNotifier<bool> isFetchingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<DateTime?> lastFetchTimeNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> isMaintenanceBypassedNotifier = ValueNotifier<bool>(
    false,
  );

  AppGateEvaluation get currentGate => gateNotifier.value;
  String _cachedCurrentVersion = '1.0.0';
  int _cachedCurrentBuildNumber = 1;
  String get installedVersionString =>
      '$_cachedCurrentVersion+$_cachedCurrentBuildNumber';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Firebase (if needed) and configures the Remote Config instance
  Future<void> initialize({
    FirebaseRemoteConfig? remoteConfigOverride,
    PackageInfo? packageInfoOverride,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Resolve Package Info for app version
      try {
        final packageInfo =
            packageInfoOverride ?? await PackageInfo.fromPlatform();
        _cachedCurrentVersion = packageInfo.version.isNotEmpty
            ? packageInfo.version
            : '1.0.0';
        _cachedCurrentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;
      } catch (e) {
        debugPrint('PackageInfo resolution fallback: $e');
        _cachedCurrentVersion = '1.0.0';
        _cachedCurrentBuildNumber = 1;
      }

      // 2. Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (e) {
          debugPrint('Firebase.initializeApp in RemoteConfig: $e');
        }
      }

      // 3. Configure Remote Config client
      _remoteConfig = remoteConfigOverride ?? FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      // 4. Set in-app fallback defaults
      await _remoteConfig!.setDefaults(defaultParameters);

      // 5. Restore bypass state if saved
      final prefs = await SharedPreferences.getInstance();
      isMaintenanceBypassedNotifier.value =
          prefs.getBool(_prefMaintenanceBypassActive) ?? false;

      // 6. Listen for real-time config updates (Firebase Remote Config Realtime)
      _realtimeSubscription?.cancel();
      _realtimeSubscription = _remoteConfig!.onConfigUpdated.listen(
        (RemoteConfigUpdate update) async {
          debugPrint(
            'Remote Config updated in real-time: ${update.updatedKeys}',
          );
          try {
            await _remoteConfig!.activate();
            await evaluateGate();
          } catch (e) {
            debugPrint('Error handling real-time remote config update: $e');
          }
        },
        onError: (error) {
          debugPrint('Real-time remote config listener error: $error');
        },
      );

      _isInitialized = true;

      // 7. Initial fetch and evaluate
      await fetchAndActivate();
      await evaluateGate();
    } catch (e) {
      debugPrint('RemoteConfigService initialization notice: $e');
      _isInitialized = true;
      // Evaluate with in-app defaults if initial fetch encounters network failure
      await evaluateGate();
    }
  }

  /// Fetches and activates latest parameters from Firebase Remote Config
  Future<bool> fetchAndActivate() async {
    if (_remoteConfig == null) return false;

    isFetchingNotifier.value = true;
    try {
      final updated = await _remoteConfig!.fetchAndActivate();
      lastFetchTimeNotifier.value = DateTime.now();
      await evaluateGate();
      return updated;
    } catch (e) {
      debugPrint('RemoteConfig fetchAndActivate notice: $e');
      await evaluateGate();
      return false;
    } finally {
      isFetchingNotifier.value = false;
    }
  }

  /// Evaluates the gate condition: maintenance mode -> force update -> recommended update -> normal
  Future<AppGateEvaluation> evaluateGate() async {
    final rc = _remoteConfig;

    // Read values or fall back to defaults
    final isMaintenance =
        rc?.getBool(keyIsMaintenanceMode) ??
        (defaultParameters[keyIsMaintenanceMode] as bool);
    final maintenanceTitle = _getString(keyMaintenanceTitle);
    final maintenanceMessage = _getString(keyMaintenanceMessage);
    final maintenanceStartTime = _getString(keyMaintenanceStartTime);
    final maintenanceEndTime = _getString(keyMaintenanceEndTime);
    final maintenanceSupportEmail = _getString(keyMaintenanceSupportEmail);
    final maintenanceStatusUrl = _getString(keyMaintenanceStatusUrl);
    final maintenanceBypassKey = _getString(keyMaintenanceBypassKey);

    final minVersionStr = _getString(keyMinRequiredVersion);
    final recommendedVersionStr = _getString(keyLatestRecommendedVersion);
    final forceTitle = _getString(keyForceUpdateTitle);
    final forceMessage = _getString(keyForceUpdateMessage);
    final recommendedTitle = _getString(keyRecommendedUpdateTitle);
    final recommendedMessage = _getString(keyRecommendedUpdateMessage);
    final releaseNotesRaw = _getString(keyUpdateReleaseNotes);
    final storeUrlAndroid = _getString(keyUpdateStoreUrlAndroid);
    final storeUrlIos = _getString(keyUpdateStoreUrlIos);
    final allowSkip =
        rc?.getBool(keyAllowRecommendedSkip) ??
        (defaultParameters[keyAllowRecommendedSkip] as bool);

    final currentAppVersion = AppVersion.parse(installedVersionString);
    final minRequired = AppVersion.parse(minVersionStr);
    final latestRecommended = AppVersion.parse(recommendedVersionStr);

    final parsedReleaseNotes = _parseReleaseNotes(releaseNotesRaw);
    final targetStoreUrl = (Platform.isIOS || Platform.isMacOS)
        ? storeUrlIos
        : storeUrlAndroid;

    // Check Maintenance Mode First
    final isBypassed = isMaintenanceBypassedNotifier.value;
    if (isMaintenance && !isBypassed) {
      final evaluation = AppGateEvaluation(
        status: AppGateStatus.maintenance,
        currentVersion: installedVersionString,
        minRequiredVersion: minVersionStr,
        latestRecommendedVersion: recommendedVersionStr,
        title: maintenanceTitle,
        message: maintenanceMessage,
        releaseNotes: parsedReleaseNotes,
        storeUrl: targetStoreUrl,
        allowSkip: false,
        isMaintenanceMode: true,
        maintenanceStartTime: maintenanceStartTime,
        maintenanceEndTime: maintenanceEndTime,
        supportEmail: maintenanceSupportEmail,
        statusUrl: maintenanceStatusUrl,
        canBypass: maintenanceBypassKey.isNotEmpty,
      );
      gateNotifier.value = evaluation;
      return evaluation;
    }

    // Check Force Update (current version < min_required_version)
    if (currentAppVersion.isLessThan(minRequired)) {
      final evaluation = AppGateEvaluation(
        status: AppGateStatus.forceUpdate,
        currentVersion: installedVersionString,
        minRequiredVersion: minVersionStr,
        latestRecommendedVersion: recommendedVersionStr,
        title: forceTitle,
        message: forceMessage,
        releaseNotes: parsedReleaseNotes,
        storeUrl: targetStoreUrl,
        allowSkip: false,
        isMaintenanceMode: false,
        supportEmail: maintenanceSupportEmail,
      );
      gateNotifier.value = evaluation;
      return evaluation;
    }

    // Check Recommended Update (current version < latest_recommended_version)
    if (currentAppVersion.isLessThan(latestRecommended)) {
      final prefs = await SharedPreferences.getInstance();
      final skippedVersion = prefs.getString(_prefSkippedRecommendedVersion);

      // If user hasn't skipped this specific version yet, trigger recommended update
      final hasSkippedThisVersion = skippedVersion == recommendedVersionStr;
      if (!hasSkippedThisVersion || !allowSkip) {
        final evaluation = AppGateEvaluation(
          status: AppGateStatus.recommendedUpdate,
          currentVersion: installedVersionString,
          minRequiredVersion: minVersionStr,
          latestRecommendedVersion: recommendedVersionStr,
          title: recommendedTitle,
          message: recommendedMessage,
          releaseNotes: parsedReleaseNotes,
          storeUrl: targetStoreUrl,
          allowSkip: allowSkip,
          isMaintenanceMode: false,
          supportEmail: maintenanceSupportEmail,
        );
        gateNotifier.value = evaluation;
        return evaluation;
      }
    }

    // Standard Normal State
    final normalEvaluation = AppGateEvaluation(
      status: AppGateStatus.normal,
      currentVersion: installedVersionString,
      minRequiredVersion: minVersionStr,
      latestRecommendedVersion: recommendedVersionStr,
      title: '',
      message: '',
      releaseNotes: parsedReleaseNotes,
      storeUrl: targetStoreUrl,
      allowSkip: true,
      isMaintenanceMode: false,
      supportEmail: maintenanceSupportEmail,
    );
    gateNotifier.value = normalEvaluation;
    return normalEvaluation;
  }

  /// Marks a specific recommended version as skipped by the user
  Future<void> skipRecommendedVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSkippedRecommendedVersion, version);
    await evaluateGate();
  }

  /// Clears skipped version record (e.g., when manually checking for updates)
  Future<void> clearSkippedRecommendedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefSkippedRecommendedVersion);
  }

  /// Attempts to bypass maintenance mode with a secret bypass key
  Future<bool> attemptMaintenanceBypass(String enteredKey) async {
    final expectedKey = _getString(keyMaintenanceBypassKey);
    if (expectedKey.isNotEmpty && enteredKey.trim() == expectedKey.trim()) {
      isMaintenanceBypassedNotifier.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMaintenanceBypassActive, true);
      await evaluateGate();
      return true;
    }
    return false;
  }

  /// Revokes active maintenance bypass
  Future<void> revokeMaintenanceBypass() async {
    isMaintenanceBypassedNotifier.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefMaintenanceBypassActive);
    await evaluateGate();
  }

  /// Launches the platform app store URL
  Future<bool> launchAppStore() async {
    final url = currentGate.storeUrl;
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to launch app store URL: $e');
      return false;
    }
  }

  /// Launches support email client
  Future<bool> launchSupportEmail([String? overrideEmail]) async {
    final email = overrideEmail ?? currentGate.supportEmail;
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Wanderline Support [Version $installedVersionString]',
      },
    );
    try {
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Failed to open email client: $e');
      return false;
    }
  }

  /// Launches external status/web URL
  Future<bool> launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open external url $url: $e');
      return false;
    }
  }

  String _getString(String key) {
    if (_remoteConfig == null) {
      return (defaultParameters[key] ?? '').toString();
    }
    final val = _remoteConfig!.getString(key);
    if (val.isNotEmpty) return val;
    return (defaultParameters[key] ?? '').toString();
  }

  List<String> _parseReleaseNotes(String raw) {
    if (raw.isEmpty) return [];

    // Attempt JSON array parse
    if (raw.trim().startsWith('[') && raw.trim().endsWith(']')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString().trim()).toList();
        }
      } catch (_) {}
    }

    // Split by newlines or bullets
    return raw
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void dispose() {
    _realtimeSubscription?.cancel();
    gateNotifier.dispose();
    isFetchingNotifier.dispose();
    lastFetchTimeNotifier.dispose();
    isMaintenanceBypassedNotifier.dispose();
  }
}
