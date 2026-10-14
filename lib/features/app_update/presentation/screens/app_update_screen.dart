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

/// Screen displayed when Firebase Remote Config mandates a Force Update
/// or suggests a Recommended Update.
///
/// Follows strict project guidelines:
/// - ZERO instances of setState()
/// - Liquid Glass design system with tactile field journal aesthetic
/// - Force updates cannot be skipped or popped
/// - Recommended updates can be skipped
/// - Pinned bottom buttons ensuring both actions are always visible
class AppUpdateScreen extends StatefulWidget {
  final AppGateEvaluation? initialEvaluation;

  const AppUpdateScreen({super.key, this.initialEvaluation});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  final ValueNotifier<bool> _isUpdatingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isCheckingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isUpdatingNotifier.dispose();
    _isCheckingNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateAction() async {
    _isUpdatingNotifier.value = true;
    try {
      final opened = await RemoteConfigService.instance.launchAppStore();
      if (!opened && mounted) {
        WaymarkSnackbar.showInfo(
          context,
          'Opening the official app store link in external browser...',
        );
      }
    } finally {
      if (mounted) _isUpdatingNotifier.value = false;
    }
  }

  Future<void> _handleRecheckAction(BuildContext context) async {
    _isCheckingNotifier.value = true;
    try {
      await RemoteConfigService.instance.fetchAndActivate();
      final eval = await RemoteConfigService.instance.evaluateGate();

      if (!context.mounted) return;

      if (eval.isNormal) {
        WaymarkSnackbar.showSuccess(
          context,
          'Version verified! Welcome back to Wanderline.',
        );
        await _continueToApp(context);
      } else if (eval.isMaintenance) {
        context.go(AppRoutes.maintenance);
      } else {
        WaymarkSnackbar.showInfo(
          context,
          'Installed version ${eval.currentVersion} still requires update to ${eval.minRequiredVersion}.',
        );
      }
    } finally {
      if (mounted) _isCheckingNotifier.value = false;
    }
  }

  Future<void> _handleSkipAction(
    BuildContext context,
    AppGateEvaluation eval,
  ) async {
    await RemoteConfigService.instance.skipRecommendedVersion(
      eval.latestRecommendedVersion,
    );
    if (!context.mounted) return;
    await _continueToApp(context);
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppGateEvaluation>(
      valueListenable: RemoteConfigService.instance.gateNotifier,
      builder: (context, activeEval, _) {
        final eval = activeEval.isUpdateRequiredOrRecommended
            ? activeEval
            : (widget.initialEvaluation ?? activeEval);

        final isForceUpdate = eval.isForceUpdate;
        final targetVersion = isForceUpdate
            ? eval.minRequiredVersion
            : eval.latestRecommendedVersion;

        return PopScope(
          canPop: !isForceUpdate && eval.allowSkip,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (isForceUpdate) {
              WaymarkSnackbar.showError(
                context,
                'This version of Wanderline is discontinued. Please update to proceed.',
              );
            }
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Ambient Background Image with Deep Blur
                Positioned.fill(
                  child: Assets.images.splashImage.image(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // 2. Translucent Peat/Vignette Overlay for Contrast
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          const Color(0xFF0F1A24).withValues(alpha: 0.88),
                          const Color(0xFF0F1A24).withValues(alpha: 0.96),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Foreground Content with Pinned Bottom Action Buttons
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scrollable Central Area
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: WaymarkSpacing.margin(context),
                            vertical: 12.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 8.h),

                              // Logo and App Brand Title
                              _buildBrandHeader(context),

                              SizedBox(height: 20.h),

                              // Central Radiant Nocturnal Liquid Glass Container
                              WaymarkLiquidGlass(
                                blurSigma: 16.0,
                                tintAlpha: 0.85,
                                tintColor: const Color(0xFF131D26),
                                borderRadius: BorderRadius.circular(
                                  WaymarkSpacing.radiusLg,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 32.r,
                                    offset: Offset(0, 12.h),
                                  ),
                                ],
                                padding: EdgeInsets.all(WaymarkSpacing.spaceLg),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Status Pill (Mandatory vs Recommended)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: WaymarkStatusPill(
                                        label: isForceUpdate
                                            ? 'MANDATORY UPDATE'
                                            : 'RECOMMENDED UPGRADE',
                                        color: isForceUpdate
                                            ? const Color(0xFFE05344)
                                            : const Color(0xFF2C6E49),
                                      ),
                                    ),

                                    SizedBox(height: 16.h),

                                    // Dynamic Bright White Title
                                    Text(
                                      eval.title.isNotEmpty
                                          ? eval.title
                                          : (isForceUpdate
                                                ? 'Critical Update Required'
                                                : 'New Expedition Features Available'),
                                      style: context.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22.sp,
                                            color: Colors.white,
                                            height: 1.25,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.4,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                    ),

                                    SizedBox(height: 12.h),

                                    // Dynamic Bright White Description Message
                                    Text(
                                      eval.message.isNotEmpty
                                          ? eval.message
                                          : (isForceUpdate
                                                ? 'Please update to the latest build to continue documenting journeys securely.'
                                                : 'A newer edition of Wanderline brings smoother mapping and field improvements.'),
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            fontSize: 14.5.sp,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                    ),

                                    SizedBox(height: 20.h),

                                    // High-Contrast Version Comparison Box
                                    _buildVersionComparisonBox(
                                      context,
                                      installed: eval.currentVersion,
                                      target: targetVersion,
                                      isForce: isForceUpdate,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),

                      // Fixed Bottom Action Buttons Area (Both buttons always visible)
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          WaymarkSpacing.margin(context),
                          12.h,
                          WaymarkSpacing.margin(context),
                          16.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0F1A24).withValues(alpha: 0.0),
                              const Color(0xFF0F1A24).withValues(alpha: 0.85),
                              const Color(0xFF0F1A24),
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                        child: _buildActionButtons(
                          context,
                          eval: eval,
                          isForceUpdate: isForceUpdate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Assets.images.waymarkLogoTransparent.image(
            fit: BoxFit.contain,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Wanderline',
          style: context.textTheme.brandScript.copyWith(
            fontSize: 38.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.55),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Expedition Journal & Field Memoir',
          style: context.textTheme.caption.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.55),
                offset: const Offset(0, 1),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionComparisonBox(
    BuildContext context, {
    required String installed,
    required String target,
    required bool isForce,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildVersionColumn(
              context,
              label: 'CURRENT BUILD',
              version: 'v$installed',
              isHighlighted: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
          Expanded(
            child: _buildVersionColumn(
              context,
              label: isForce ? 'REQUIRED BUILD' : 'LATEST RELEASE',
              version: 'v$target',
              isHighlighted: true,
              highlightColor: isForce
                  ? const Color(0xFFFF7B6B)
                  : const Color(0xFF52B788),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionColumn(
    BuildContext context, {
    required String label,
    required String version,
    required bool isHighlighted,
    Color? highlightColor,
  }) {
    return Column(
      crossAxisAlignment: isHighlighted
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.caption.copyWith(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          version,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: isHighlighted
                ? (highlightColor ?? const Color(0xFFFF7B6B))
                : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required AppGateEvaluation eval,
    required bool isForceUpdate,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Update Button
        ValueListenableBuilder<bool>(
          valueListenable: _isUpdatingNotifier,
          builder: (context, isUpdating, _) {
            return WaymarkPrimaryButton(
              label: isForceUpdate
                  ? 'Update Now to Continue'
                  : 'Update Wanderline',
              icon: Icons.system_update_rounded,
              isLoading: isUpdating,
              onPressed: _handleUpdateAction,
            );
          },
        ),

        SizedBox(height: 12.h),

        // Secondary Action: Recheck Status (Force Update) OR Skip (Recommended Update)
        if (isForceUpdate)
          ValueListenableBuilder<bool>(
            valueListenable: _isCheckingNotifier,
            builder: (context, isChecking, _) {
              return ElevatedButton(
                onPressed: isChecking
                    ? null
                    : () => _handleRecheckAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: WaymarkSpacing.spaceLg,
                    vertical: WaymarkSpacing.spaceMd,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isChecking) ...[
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Checking Cloud Config...',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.refresh_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Already Updated? Verify Status',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          )
        else
          OutlinedButton(
            onPressed: () => _handleSkipAction(context, eval),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              elevation: 0,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: WaymarkSpacing.spaceLg,
                vertical: WaymarkSpacing.spaceMd,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Maybe Later — Continue to Field Journal',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
