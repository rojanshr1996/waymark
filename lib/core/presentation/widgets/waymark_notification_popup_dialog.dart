import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/notification_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

/// A sleek Liquid Glass popup dialog presented when the user taps on any
/// notification (local backup alert, FCM push notification, or in-app test trigger).
class WaymarkNotificationPopupDialog extends StatelessWidget {
  final ReceivedNotification notification;

  const WaymarkNotificationPopupDialog({super.key, required this.notification});

  /// Displays the popup dialog modally
  static Future<void> show(
    BuildContext context,
    ReceivedNotification notification,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          WaymarkNotificationPopupDialog(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final (badgeIcon, badgeColor, typeLabel) = _getTypeVisuals(
      notification.type,
    );
    final formattedTime = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(notification.timestamp);

    return Dialog(
      backgroundColor: colors.surfaceCard,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: colors.borderDivider, width: 1.0),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: WaymarkSpacing.margin(context),
        vertical: 24.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Type Badge + Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
                      ),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          typeLabel,
                          style: context.textTheme.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            letterSpacing: 0.7,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: colors.textSecondary,
                    ),
                    splashRadius: 18.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Title
              Text(
                notification.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),

              // Timestamp subtitle
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: colors.textSecondary.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    formattedTime,
                    style: context.textTheme.caption.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Body Message
              Text(
                notification.body,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),

              // Specific payload / data preview card
              if (_hasDetails(notification)) ...[
                SizedBox(height: 14.h),
                _buildDetailsCard(context),
              ],

              SizedBox(height: 20.h),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: colors.borderDivider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusSm,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Dismiss',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (notification.type ==
                      NotificationType.backupCompleted) ...[
                    SizedBox(width: 10.w),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusSm,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push(AppRoutes.settings);
                        },
                        child: Text(
                          'View Backups',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasDetails(ReceivedNotification n) {
    if (n.type == NotificationType.backupCompleted) return true;
    if (n.data != null && n.data!.isNotEmpty) return true;
    if (n.payload != null && n.payload!.isNotEmpty) return true;
    return false;
  }

  Widget _buildDetailsCard(BuildContext context) {
    final colors = context.colorScheme;
    final data = notification.data;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        border: Border.all(color: colors.borderDivider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14.sp,
                color: colors.secondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'NOTIFICATION DETAILS',
                style: context.textTheme.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 0.6,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (notification.type == NotificationType.backupCompleted &&
              data != null) ...[
            _buildDetailItem(
              context,
              'Snapshot File',
              data['fileName']?.toString() ?? 'backup.sqlite',
            ),
            if (data['fileSizeBytes'] != null)
              _buildDetailItem(
                context,
                'File Size',
                '${((data['fileSizeBytes'] as num) / 1024).toStringAsFixed(1)} KB',
              ),
            _buildDetailItem(
              context,
              'Storage Directory',
              Platform.isAndroid
                  ? 'Internal Storage > Downloads'
                  : 'Local Storage',
            ),
          ] else if (data != null && data.isNotEmpty) ...[
            ...data.entries.map(
              (entry) =>
                  _buildDetailItem(context, entry.key, entry.value.toString()),
            ),
          ] else if (notification.payload != null) ...[
            _buildDetailItem(context, 'Payload', notification.payload!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String key, String value) {
    final colors = context.colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95.w,
            child: Text(
              key,
              style: context.textTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _getTypeVisuals(NotificationType type) {
    switch (type) {
      case NotificationType.backupCompleted:
        return (
          Icons.cloud_done_rounded,
          const Color(0xFF10B981), // Emerald green
          'BACKUP COMPLETED',
        );
      case NotificationType.fcmPush:
        return (
          Icons.mark_email_read_rounded,
          const Color(0xFF3B82F6), // Blue
          'CLOUD MESSAGE',
        );
      case NotificationType.test:
        return (
          Icons.science_rounded,
          const Color(0xFFF59E0B), // Amber
          'TEST NOTIFICATION',
        );
      case NotificationType.localAlert:
        return (
          Icons.notifications_active_rounded,
          const Color(0xFF14B8A6), // Teal
          'SYSTEM ALERT',
        );
    }
  }
}
