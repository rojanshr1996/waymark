import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

/// Semantic categories for WayMark standard feedback toasts
enum WaymarkSnackbarType { success, info, warning, error }

/// Standardized floating feedback toast conforming to Rule 7
/// in `implementation_plan.md`.
class WaymarkSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    WaymarkSnackbarType type = WaymarkSnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final colors = context.colorScheme;

    final (IconData icon, Color iconColor, Color iconBg) = switch (type) {
      WaymarkSnackbarType.success => (
        Icons.check_circle_rounded,
        const Color(0xFF2E7D32),
        const Color(0xFFADF2C3).withValues(alpha: 0.6),
      ),
      WaymarkSnackbarType.info => (
        Icons.info_outline_rounded,
        colors.secondary,
        colors.secondary.withValues(alpha: 0.12),
      ),
      WaymarkSnackbarType.warning => (
        Icons.warning_amber_rounded,
        colors.tertiary,
        colors.tertiary.withValues(alpha: 0.15),
      ),
      WaymarkSnackbarType.error => (
        Icons.error_outline_rounded,
        colors.primary,
        colors.primary.withValues(alpha: 0.12),
      ),
    };

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceCard,
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
          side: BorderSide(color: colors.borderDivider, width: 0.8),
        ),
        content: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 16.sp, color: iconColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display a success confirmation toast with checkmark icon
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: WaymarkSnackbarType.success,
      duration: duration,
    );
  }

  /// Display an informative toast with info icon
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: WaymarkSnackbarType.info,
      duration: duration,
    );
  }

  /// Display a warning toast with warning icon
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: WaymarkSnackbarType.warning,
      duration: duration,
    );
  }

  /// Display an error toast with error icon
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: WaymarkSnackbarType.error,
      duration: duration,
    );
  }
}
