import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waymark/firebase_options.dart';

enum NotificationType { backupCompleted, fcmPush, localAlert, test }

class ReceivedNotification {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  final NotificationType type;
  final Map<String, dynamic>? data;

  const ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
    this.type = NotificationType.localAlert,
    this.data,
  });

  factory ReceivedNotification.fromJson(Map<String, dynamic> json) {
    return ReceivedNotification(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Waymark Notification',
      body: json['body'] as String? ?? '',
      payload: json['payload'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.localAlert,
      ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'data': data,
    };
  }
}

class NotificationStatus {
  final bool isInitialized;
  final bool hasPermission;
  final bool isFcmAvailable;
  final String? fcmToken;
  final String statusMessage;
  final ReceivedNotification? lastReceivedNotification;

  const NotificationStatus({
    this.isInitialized = false,
    this.hasPermission = false,
    this.isFcmAvailable = false,
    this.fcmToken,
    this.statusMessage = 'Initializing...',
    this.lastReceivedNotification,
  });

  NotificationStatus copyWith({
    bool? isInitialized,
    bool? hasPermission,
    bool? isFcmAvailable,
    String? fcmToken,
    String? statusMessage,
    ReceivedNotification? lastReceivedNotification,
  }) {
    return NotificationStatus(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      isFcmAvailable: isFcmAvailable ?? this.isFcmAvailable,
      fcmToken: fcmToken ?? this.fcmToken,
      statusMessage: statusMessage ?? this.statusMessage,
      lastReceivedNotification:
          lastReceivedNotification ?? this.lastReceivedNotification,
    );
  }
}

/// Top-level background handler for FCM messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String channelId = 'waymark_general';
  static const String channelName = 'Waymark Journal';
  static const String channelDescription =
      'Notifications for backup completion and journey updates';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<NotificationStatus> statusNotifier =
      ValueNotifier<NotificationStatus>(const NotificationStatus());

  final ValueNotifier<ReceivedNotification?> tappedNotificationNotifier =
      ValueNotifier<ReceivedNotification?>(null);

  bool _isInitializing = false;

  NotificationStatus get status => statusNotifier.value;

  /// Initialize local notifications and Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitializing || status.isInitialized) return;
    _isInitializing = true;

    try {
      // 1. Initialize Flutter Local Notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
      );

      // Create Android Notification Channel
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          const androidChannel = AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );
          await androidPlugin.createNotificationChannel(androidChannel);
        }
      }

      // 2. Check and Request Permissions
      final hasPermission = await _checkNotificationPermission();

      // 3. Initialize Firebase & Cloud Messaging safely
      bool fcmAvailable = false;
      String? fcmToken;
      String statusMsg = 'Local notifications active.';

      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }

        fcmAvailable = true;
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        final messaging = FirebaseMessaging.instance;

        // Request FCM permission
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        final isGranted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

        if (isGranted) {
          try {
            fcmToken = await messaging.getToken();
          } catch (e) {
            debugPrint('FCM getToken error (APNS or credentials pending): $e');
          }
        }

        // Listen for token refreshes
        messaging.onTokenRefresh.listen((token) {
          fcmToken = token;
          statusNotifier.value = statusNotifier.value.copyWith(fcmToken: token);
        });

        // Listen for foreground FCM messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _handleForegroundFcmMessage(message);
        });

        // Listen for notification taps when opened from background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleFcmMessageOpened(message);
        });

        // Check if app was opened from terminated state via notification
        final initialMessage = await messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleFcmMessageOpened(initialMessage);
        }

        statusMsg = isGranted
            ? 'Firebase Cloud Messaging Connected.'
            : 'FCM Ready (Permission needed).';
      } catch (e) {
        debugPrint('Firebase messaging initialization notice: $e');
        statusMsg = 'Local push active (FCM configuration optional).';
      }

      statusNotifier.value = NotificationStatus(
        isInitialized: true,
        hasPermission: hasPermission,
        isFcmAvailable: fcmAvailable,
        fcmToken: fcmToken,
        statusMessage: statusMsg,
      );
    } catch (e) {
      debugPrint('NotificationService init error: $e');
      statusNotifier.value = statusNotifier.value.copyWith(
        isInitialized: true,
        statusMessage: 'Initialization completed with notice: $e',
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<bool> _checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final iosPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Request notification permission explicitly
  Future<bool> requestPermission() async {
    bool granted = false;
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      granted = status.isGranted;
    } else {
      final iosPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final res = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = res ?? false;
    }

    if (status.isFcmAvailable) {
      try {
        await FirebaseMessaging.instance.requestPermission();
        final token = await FirebaseMessaging.instance.getToken();
        statusNotifier.value = statusNotifier.value.copyWith(fcmToken: token);
      } catch (_) {}
    }

    statusNotifier.value = statusNotifier.value.copyWith(
      hasPermission: granted,
      statusMessage: granted ? 'Notifications enabled.' : 'Permission denied.',
    );

    return granted;
  }

  /// Show a local push notification alert when backup completes
  Future<void> showBackupCompletedNotification({
    required String backupPath,
    required int fileSizeBytes,
  }) async {
    final fileName = backupPath.split(Platform.pathSeparator).last;
    final sizeKb = (fileSizeBytes / 1024).toStringAsFixed(1);
    final title = 'Waymark Backup Completed';
    final body = 'Journal snapshot saved to Downloads: $fileName ($sizeKb KB)';

    final payloadMap = {
      'id': 'backup_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'payload': backupPath,
      'timestamp': DateTime.now().toIso8601String(),
      'type': NotificationType.backupCompleted.name,
      'data': {
        'fileName': fileName,
        'filePath': backupPath,
        'fileSizeBytes': fileSizeBytes,
      },
    };

    final payloadJson = jsonEncode(payloadMap);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      ticker: 'Backup Completed',
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );
    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payloadJson,
    );

    final rec = ReceivedNotification.fromJson(payloadMap);
    statusNotifier.value = statusNotifier.value.copyWith(
      lastReceivedNotification: rec,
    );
  }

  /// Send a test notification to verify the push flow and tap popup
  Future<void> showTestNotification() async {
    final title = 'Waymark Notification Test';
    final body =
        'Push notification flow active. Tap to inspect notification details.';

    final payloadMap = {
      'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'payload': 'Test sample payload from Waymark settings',
      'timestamp': DateTime.now().toIso8601String(),
      'type': NotificationType.test.name,
      'data': {
        'source': 'Settings Test Trigger',
        'fcmStatus': status.isFcmAvailable ? 'Connected' : 'Local Fallback',
        'deviceToken': status.fcmToken ?? 'None',
      },
    };

    final payloadJson = jsonEncode(payloadMap);

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payloadJson,
    );

    final rec = ReceivedNotification.fromJson(payloadMap);
    statusNotifier.value = statusNotifier.value.copyWith(
      lastReceivedNotification: rec,
    );
  }

  /// Handle local notification tap response
  void _handleLocalNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        final notification = ReceivedNotification.fromJson(data);
        tappedNotificationNotifier.value = notification;
        return;
      } catch (_) {}
    }

    // Fallback if payload isn't json
    final fallback = ReceivedNotification(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Waymark Notification',
      body: payload ?? 'Notification tapped',
      payload: payload,
      timestamp: DateTime.now(),
      type: NotificationType.localAlert,
    );
    tappedNotificationNotifier.value = fallback;
  }

  /// Handle foreground FCM message
  void _handleForegroundFcmMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? 'Waymark Cloud Message';
    final body = notification?.body ?? 'New expedition update received.';

    final payloadMap = {
      'id': message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'payload': message.data.isNotEmpty ? jsonEncode(message.data) : null,
      'timestamp': DateTime.now().toIso8601String(),
      'type': NotificationType.fcmPush.name,
      'data': message.data,
    };

    // Show local heads-up notification in foreground
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(payloadMap),
    );

    final rec = ReceivedNotification.fromJson(payloadMap);
    statusNotifier.value = statusNotifier.value.copyWith(
      lastReceivedNotification: rec,
    );
  }

  /// Handle FCM message tap when app opened from background
  void _handleFcmMessageOpened(RemoteMessage message) {
    final notification = message.notification;
    final rec = ReceivedNotification(
      id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: notification?.title ?? 'Waymark Cloud Message',
      body: notification?.body ?? 'Notification opened.',
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      timestamp: DateTime.now(),
      type: NotificationType.fcmPush,
      data: message.data,
    );

    tappedNotificationNotifier.value = rec;
    statusNotifier.value = statusNotifier.value.copyWith(
      lastReceivedNotification: rec,
    );
  }

  /// Manually trigger tap popup for a specific notification
  void inspectNotification(ReceivedNotification notification) {
    tappedNotificationNotifier.value = notification;
  }

  /// Clear active tap notification
  void clearTappedNotification() {
    tappedNotificationNotifier.value = null;
  }
}
