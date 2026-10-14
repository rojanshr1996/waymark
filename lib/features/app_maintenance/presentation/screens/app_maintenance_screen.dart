import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/presentation/widgets/waymark_status_pill.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/remote_config_models.dart';
import 'package:waymark/core/services/remote_config_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

/// Screen displayed when the application is placed into scheduled maintenance mode
/// via Firebase Remote Config.
///
/// Features & Controls:
/// - Dynamic Title and Message from Remote Config
/// - Scheduled maintenance timeline window (start / expected end times)
/// - Recheck / Retry connection button with real-time config refresh
/// - Direct Support Email and Status Webpage launchers
/// - Developer & Admin emergency bypass code dialog
/// - Automatic real-time transition as soon as maintenance is disabled remotely
/// - ZERO instances of setState()
class AppMaintenanceScreen extends StatefulWidget {
  const AppMaintenanceScreen({super.key});

  @override
  State<AppMaintenanceScreen> createState() => _AppMaintenanceScreenState();
}

class _AppMaintenanceScreenState extends State<AppMaintenanceScreen> {
  final ValueNotifier<bool> _isCheckingNotifier = ValueNotifier<bool>(false);
  final TextEditingController _bypassController = TextEditingController();

  @override
  void dispose() {
    _isCheckingNotifier.dispose();
    _bypassController.dispose();
    super.dispose();
  }

  Future<void> _handleRecheckStatus(BuildContext context) async {
    _isCheckingNotifier.value = true;
    try {
      await RemoteConfigService.instance.fetchAndActivate();
      final eval = await RemoteConfigService.instance.evaluateGate();

      if (!context.mounted) return;

      if (!eval.isMaintenance) {
        WaymarkSnackbar.showSuccess(
          context,
          'Maintenance completed! Returning to your expedition journal.',
        );
        await _continueToApp(context);
      } else {
        WaymarkSnackbar.showInfo(
          context,
          'Maintenance is still active. Please check back shortly.',
        );
      }
    } finally {
      if (mounted) _isCheckingNotifier.value = false;
    }
  }

  Future<void> _continueToApp(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;
    final profile = await AppDatabase.instance.userProfileDao.getProfile();

    if (!context.mounted) return;

    if (hasCompletedOnboarding && profile != null) {
      context.go(AppRoutes.journeys);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  Future<void> _showBypassDialog(BuildContext context) async {
    _bypassController.clear();
    final colors = context.colorScheme;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.key_rounded, color: colors.warning, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Developer Bypass',
                style: dialogCtx.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the authorization passphrase configured in Firebase Remote Config to bypass maintenance mode for testing.',
                style: dialogCtx.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: 14.h),
              TextField(
                controller: _bypassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Bypass Passphrase',
                  hintText: 'Enter secret code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.warning,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final key = _bypassController.text;
                final success = await RemoteConfigService.instance
                    .attemptMaintenanceBypass(key);
                if (!dialogCtx.mounted) return;
                Navigator.of(dialogCtx).pop();

                if (success) {
                  WaymarkSnackbar.showSuccess(
                    context,
                    'Maintenance bypass granted. Welcome back!',
                  );
                  await _continueToApp(context);
                } else {
                  WaymarkSnackbar.showError(
                    context,
                    'Invalid bypass code. Access denied.',
                  );
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppGateEvaluation>(
      valueListenable: RemoteConfigService.instance.gateNotifier,
      builder: (context, eval, _) {
        // Auto-navigate if maintenance mode is toggled off remotely
        if (!eval.isMaintenance && eval.isNormal) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _continueToApp(context);
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            WaymarkSnackbar.showInfo(
              context,
              'Waymark is currently undergoing scheduled maintenance.',
            );
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Ambient Background Layer
                Positioned.fill(
                  child: Assets.images.splashImage.image(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // 2. Deep Gradient Vignette with Warm Amber Tone
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.70),
                          const Color(0xFF1E1710).withValues(alpha: 0.90),
                          const Color(0xFF110D0A).withValues(alpha: 0.97),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Foreground Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: WaymarkSpacing.margin(context),
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Navigation / Bypass Trigger
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            // Brand Center
                            _buildBrandPill(context),
                            // Secret bypass lock button
                            IconButton(
                              tooltip: 'Developer Bypass',
                              icon: Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white.withValues(alpha: 0.4),
                                size: 20.sp,
                              ),
                              onPressed: () => _showBypassDialog(context),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Maintenance Visual Halo
                        _buildMaintenanceHeroIcon(context),

                        SizedBox(height: 24.h),

                        // Liquid Glass Card with Dynamic Remote Config Data
                        WaymarkLiquidGlass(
                          blurSigma: 16.0,
                          tintAlpha: 0.90,
                          tintColor: context.colorScheme.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusLg,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 30.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                          padding: EdgeInsets.all(WaymarkSpacing.spaceLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Status Pill
                              Align(
                                alignment: Alignment.centerLeft,
                                child: WaymarkStatusPill(
                                  label: 'SCHEDULED MAINTENANCE',
                                  color: context.colorScheme.warning,
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // Dynamic Maintenance Title
                              Text(
                                eval.title.isNotEmpty
                                    ? eval.title
                                    : 'Under Scheduled Maintenance',
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colorScheme.textPrimary,
                                      height: 1.25,
                                    ),
                              ),

                              SizedBox(height: 10.h),

                              // Dynamic Maintenance Message
                              Text(
                                eval.message.isNotEmpty
                                    ? eval.message
                                    : 'We are currently enhancing the trail infrastructure and offline syncing systems. Your journal data remains safe and sound.',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.textSecondary,
                                  height: 1.45,
                                ),
                              ),

                              // Maintenance Timeline Schedule Box (if available from config)
                              if (eval.maintenanceEndTime.isNotEmpty ||
                                  eval.maintenanceStartTime.isNotEmpty) ...[
                                SizedBox(height: 18.h),
                                _buildScheduleBox(context, eval),
                              ],

                              SizedBox(height: 20.h),

                              // Live Status Ping Row
                              _buildLivePingRow(context),
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // Action Controls
                        _buildControls(context, eval),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandPill(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.waymarkLogoTransparent.image(
            width: 18.w,
            height: 18.w,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
          SizedBox(width: 6.w),
          Text(
            'WayMark',
            style: context.textTheme.brandScript.copyWith(
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHeroIcon(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow Circle
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.warning.withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.surfaceCard,
              border: Border.all(
                color: context.colorScheme.warning.withValues(alpha: 0.4),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.warning.withValues(alpha: 0.35),
                  blurRadius: 20.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.engineering_rounded,
              size: 40.sp,
              color: context.colorScheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleBox(BuildContext context, AppGateEvaluation eval) {
    final colors = context.colorScheme;
    return Container(
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
              Icon(Icons.schedule_rounded, size: 16.sp, color: colors.warning),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'ESTIMATED RESTORATION WINDOW',
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: colors.warning,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          if (eval.maintenanceStartTime.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Text(
                'Started: ${eval.maintenanceStartTime}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          if (eval.maintenanceEndTime.isNotEmpty)
            Text(
              'Expected Completion: ${eval.maintenanceEndTime}',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLivePingRow(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.warning,
            boxShadow: [
              BoxShadow(
                color: colors.warning.withValues(alpha: 0.6),
                blurRadius: 6.r,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Live updates active — the app will auto-resume as soon as maintenance completes.',
            style: context.textTheme.caption.copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, AppGateEvaluation eval) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Check Status Button
        ValueListenableBuilder<bool>(
          valueListenable: _isCheckingNotifier,
          builder: (context, isChecking, _) {
            return WaymarkPrimaryButton(
              label: 'Check Maintenance Status',
              icon: Icons.refresh_rounded,
              isLoading: isChecking,
              onPressed: () => _handleRecheckStatus(context),
            );
          },
        ),

        SizedBox(height: 12.h),

        // Secondary Links (Contact Support & Status Page)
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12.w,
          runSpacing: 4.h,
          children: [
            if (eval.supportEmail.isNotEmpty)
              TextButton.icon(
                onPressed: () => RemoteConfigService.instance
                    .launchSupportEmail(eval.supportEmail),
                icon: Icon(
                  Icons.mail_outline_rounded,
                  size: 16.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                label: Text(
                  'Contact Support',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            if (eval.statusUrl.isNotEmpty)
              TextButton.icon(
                onPressed: () => RemoteConfigService.instance.launchExternalUrl(
                  eval.statusUrl,
                ),
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 15.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                label: Text(
                  'Status Page',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
