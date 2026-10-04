import 'package:flutter/material.dart';
import 'package:waymark/core/router/app_router.dart';
import 'package:waymark/core/services/backup_service.dart';
import 'package:waymark/core/services/notification_service.dart';
import 'waymark_notification_popup_dialog.dart';

/// App-level listener that monitors tapped notifications and presents
/// the [WaymarkNotificationPopupDialog] modally on top of the active route.
class WaymarkNotificationListener extends StatefulWidget {
  final Widget child;

  const WaymarkNotificationListener({super.key, required this.child});

  @override
  State<WaymarkNotificationListener> createState() =>
      _WaymarkNotificationListenerState();
}

class _WaymarkNotificationListenerState
    extends State<WaymarkNotificationListener> {
  bool _isDialogShowing = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.tappedNotificationNotifier.addListener(
      _onTappedNotificationChanged,
    );

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        BackupService.checkAndRunAutoBackup();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPopup();
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    NotificationService.instance.tappedNotificationNotifier.removeListener(
      _onTappedNotificationChanged,
    );
    super.dispose();
  }

  void _onTappedNotificationChanged() {
    _checkAndShowPopup();
  }

  Future<void> _checkAndShowPopup() async {
    final notification =
        NotificationService.instance.tappedNotificationNotifier.value;
    if (notification == null || !mounted || _isDialogShowing) return;

    final navContext = AppRouter.rootNavigatorKey.currentContext ?? context;
    _isDialogShowing = true;

    try {
      await WaymarkNotificationPopupDialog.show(navContext, notification);
    } finally {
      _isDialogShowing = false;
      NotificationService.instance.clearTappedNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
