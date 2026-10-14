import 'package:flutter/foundation.dart';

/// Semantic version representation with comparison operators
@immutable
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final int buildNumber;
  final String raw;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.buildNumber = 0,
    required this.raw,
  });

  /// Parse strings like "1.2.3", "1.2.3+4", "2.0", or "1"
  factory AppVersion.parse(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) {
      return const AppVersion(major: 0, minor: 0, patch: 0, raw: '0.0.0');
    }

    int build = 0;
    String versionPart = cleaned;
    if (cleaned.contains('+')) {
      final parts = cleaned.split('+');
      versionPart = parts[0];
      if (parts.length > 1) {
        build = int.tryParse(parts[1]) ?? 0;
      }
    }

    final segments = versionPart
        .split('.')
        .map((s) => int.tryParse(RegExp(r'\d+').stringMatch(s) ?? '') ?? 0)
        .toList();

    final major = segments.isNotEmpty ? segments[0] : 0;
    final minor = segments.length > 1 ? segments[1] : 0;
    final patch = segments.length > 2 ? segments[2] : 0;

    return AppVersion(
      major: major,
      minor: minor,
      patch: patch,
      buildNumber: build,
      raw: cleaned,
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    if (buildNumber != other.buildNumber &&
        buildNumber > 0 &&
        other.buildNumber > 0) {
      return buildNumber.compareTo(other.buildNumber);
    }
    return 0;
  }

  bool isLessThan(AppVersion other) => compareTo(other) < 0;
  bool isGreaterThan(AppVersion other) => compareTo(other) > 0;
  bool isAtLeast(AppVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion &&
          runtimeType == other.runtimeType &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          buildNumber == other.buildNumber;

  @override
  int get hashCode => Object.hash(major, minor, patch, buildNumber);

  @override
  String toString() => buildNumber > 0
      ? '$major.$minor.$patch+$buildNumber'
      : '$major.$minor.$patch';
}

/// The gate status determining app access upon launch or runtime config change
enum AppGateStatus {
  /// Regular app usage allowed
  normal,

  /// App is in maintenance mode
  maintenance,

  /// App requires a mandatory force update
  forceUpdate,

  /// A recommended update is available (can be skipped by user)
  recommendedUpdate,
}

/// Immutable evaluation results containing all display text and remote values
@immutable
class AppGateEvaluation {
  final AppGateStatus status;
  final String currentVersion;
  final String minRequiredVersion;
  final String latestRecommendedVersion;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String storeUrl;
  final bool allowSkip;

  // Maintenance specifics
  final bool isMaintenanceMode;
  final String maintenanceStartTime;
  final String maintenanceEndTime;
  final String supportEmail;
  final String statusUrl;
  final bool canBypass;

  const AppGateEvaluation({
    required this.status,
    required this.currentVersion,
    required this.minRequiredVersion,
    required this.latestRecommendedVersion,
    required this.title,
    required this.message,
    required this.releaseNotes,
    required this.storeUrl,
    required this.allowSkip,
    this.isMaintenanceMode = false,
    this.maintenanceStartTime = '',
    this.maintenanceEndTime = '',
    this.supportEmail = 'support@wanderline.app',
    this.statusUrl = '',
    this.canBypass = false,
  });

  bool get isNormal => status == AppGateStatus.normal;
  bool get isMaintenance => status == AppGateStatus.maintenance;
  bool get isForceUpdate => status == AppGateStatus.forceUpdate;
  bool get isRecommendedUpdate => status == AppGateStatus.recommendedUpdate;
  bool get isUpdateRequiredOrRecommended =>
      isForceUpdate || isRecommendedUpdate;

  AppGateEvaluation copyWith({
    AppGateStatus? status,
    String? currentVersion,
    String? minRequiredVersion,
    String? latestRecommendedVersion,
    String? title,
    String? message,
    List<String>? releaseNotes,
    String? storeUrl,
    bool? allowSkip,
    bool? isMaintenanceMode,
    String? maintenanceStartTime,
    String? maintenanceEndTime,
    String? supportEmail,
    String? statusUrl,
    bool? canBypass,
  }) {
    return AppGateEvaluation(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      latestRecommendedVersion:
          latestRecommendedVersion ?? this.latestRecommendedVersion,
      title: title ?? this.title,
      message: message ?? this.message,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      storeUrl: storeUrl ?? this.storeUrl,
      allowSkip: allowSkip ?? this.allowSkip,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      maintenanceStartTime: maintenanceStartTime ?? this.maintenanceStartTime,
      maintenanceEndTime: maintenanceEndTime ?? this.maintenanceEndTime,
      supportEmail: supportEmail ?? this.supportEmail,
      statusUrl: statusUrl ?? this.statusUrl,
      canBypass: canBypass ?? this.canBypass,
    );
  }
}
