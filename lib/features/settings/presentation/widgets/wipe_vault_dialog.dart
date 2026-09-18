import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

enum _WipeStage { firstWarning, secondConfirmation, countdown, wiping }

/// An artistic, tactile dialog that provides double confirmation and a
/// 10-second linear loading indicator countdown before wiping all local SQLite data.
/// The user can abort the process at any time during the countdown.
class WipeVaultDialog extends StatefulWidget {
  final VoidCallback onWipeSuccess;

  const WipeVaultDialog({super.key, required this.onWipeSuccess});

  /// Displays the [WipeVaultDialog] as a modal.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onWipeSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WipeVaultDialog(onWipeSuccess: onWipeSuccess),
    );
  }

  @override
  State<WipeVaultDialog> createState() => _WipeVaultDialogState();
}

class _WipeVaultDialogState extends State<WipeVaultDialog>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<_WipeStage> _stageNotifier = ValueNotifier<_WipeStage>(
    _WipeStage.firstWarning,
  );
  final ValueNotifier<bool> _acknowledgementCheckedNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<int> _secondsLeftNotifier = ValueNotifier<int>(10);

  late final AnimationController _progressController;
  Timer? _countdownTicker;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_isDisposed) {
        _executeWipe();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTicker?.cancel();
    _progressController.dispose();
    _stageNotifier.dispose();
    _acknowledgementCheckedNotifier.dispose();
    _secondsLeftNotifier.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _stageNotifier.value = _WipeStage.countdown;
    _secondsLeftNotifier.value = 10;

    _progressController.forward(from: 0.0);

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isDisposed) {
        timer.cancel();
        return;
      }
      if (_secondsLeftNotifier.value <= 1) {
        timer.cancel();
      } else {
        _secondsLeftNotifier.value--;
      }
    });
  }

  void _cancelWipe() {
    _countdownTicker?.cancel();
    _progressController.stop();
    Navigator.of(context).pop();
    WaymarkSnackbar.showInfo(
      context,
      'Vault wipe cancelled. All your expedition records remain safe.',
    );
  }

  Future<void> _executeWipe() async {
    _countdownTicker?.cancel();
    if (!mounted || _isDisposed) return;

    _stageNotifier.value = _WipeStage.wiping;

    try {
      await AppDatabase.instance.clearEntireDatabase();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onWipeSuccess();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      WaymarkSnackbar.showError(context, 'Failed to wipe database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return ValueListenableBuilder<_WipeStage>(
      valueListenable: _stageNotifier,
      builder: (context, stage, _) {
        return PopScope(
          canPop: stage != _WipeStage.wiping,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop && stage == _WipeStage.countdown) {
              _countdownTicker?.cancel();
              _progressController.stop();
              WaymarkSnackbar.showInfo(
                context,
                'Vault wipe cancelled. All records preserved.',
              );
            }
          },
          child: Dialog(
            backgroundColor: colors.surfaceCard,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
              side: BorderSide(
                color: stage == _WipeStage.countdown
                    ? colors.error.withValues(alpha: 0.4)
                    : colors.borderDivider,
                width: 1.2,
              ),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: WaymarkSpacing.margin(context),
              vertical: 24.h,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.all(20.w),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _buildStageContent(context, stage),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageContent(BuildContext context, _WipeStage stage) {
    switch (stage) {
      case _WipeStage.firstWarning:
        return _buildFirstWarningView(context);
      case _WipeStage.secondConfirmation:
        return _buildSecondConfirmationView(context);
      case _WipeStage.countdown:
        return _buildCountdownView(context);
      case _WipeStage.wiping:
        return _buildWipingView(context);
    }
  }

  // ==========================================
  // STAGE 1: FIRST WARNING VIEW
  // ==========================================
  Widget _buildFirstWarningView(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      key: const ValueKey('stage-first-warning'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Badge & Step Indicator Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: colors.error,
                size: 24.sp,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Text(
                'STEP 1 OF 2',
                style: context.textTheme.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Title
        Text(
          'Wipe Expedition Vault?',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: colors.error,
          ),
        ),
        SizedBox(height: 6.h),

        // Subtitle / Description
        Text(
          'This action will permanently erase all local records, memoirs, and telemetry from your device.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 14.h),

        // Inventory Breakdown Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
            border: Border.all(color: colors.borderDivider, width: 0.8),
          ),
          child: Column(
            children: [
              _buildInventoryRow(
                context: context,
                icon: Icons.map_outlined,
                label: 'All Journey Memoirs & Expeditions',
              ),
              SizedBox(height: 6.h),
              _buildInventoryRow(
                context: context,
                icon: Icons.location_on_outlined,
                label: 'Logged Stops, GPS Routes & Notes',
              ),
              SizedBox(height: 6.h),
              _buildInventoryRow(
                context: context,
                icon: Icons.photo_library_outlined,
                label: 'Captured Photos & Media Links',
              ),
              SizedBox(height: 6.h),
              _buildInventoryRow(
                context: context,
                icon: Icons.badge_outlined,
                label: 'Traveler Profile Dossier',
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Privacy Warning Callout
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
            border: Border.all(
              color: colors.error.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.sp,
                color: colors.error,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Waymark is 100% offline. Erased records cannot be recovered from any cloud.',
                  style: context.textTheme.caption.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  'Keep Data',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusSm,
                    ),
                  ),
                ),
                onPressed: () {
                  _stageNotifier.value = _WipeStage.secondConfirmation;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right_rounded, size: 16.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STAGE 2: SECOND CONFIRMATION VIEW
  // ==========================================
  Widget _buildSecondConfirmationView(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      key: const ValueKey('stage-second-confirmation'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Badge & Step Indicator Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                color: colors.warning,
                size: 22.sp,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Text(
                'FINAL VERIFICATION',
                style: context.textTheme.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 0.8,
                  color: colors.error,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Title
        Text(
          'Confirmation Required',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),

        // Explanation
        Text(
          'Are you completely certain? Initiating will start a 10-second countdown during which you may abort at any second.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 16.h),

        // Explicit Acknowledgment Checkbox Box
        ValueListenableBuilder<bool>(
          valueListenable: _acknowledgementCheckedNotifier,
          builder: (context, acknowledgementChecked, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
                  child: InkWell(
                    onTap: () {
                      _acknowledgementCheckedNotifier.value =
                          !_acknowledgementCheckedNotifier.value;
                    },
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Checkbox(
                            value: acknowledgementChecked,
                            activeColor: colors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            onChanged: (val) {
                              _acknowledgementCheckedNotifier.value =
                                  val ?? false;
                            },
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'I understand this will irreversibly wipe my entire local database.',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                        onPressed: () {
                          _stageNotifier.value = _WipeStage.firstWarning;
                        },
                        child: Text(
                          'Back',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.error,
                          disabledBackgroundColor: colors.error.withValues(
                            alpha: 0.3,
                          ),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusSm,
                            ),
                          ),
                        ),
                        onPressed: acknowledgementChecked
                            ? _startCountdown
                            : null,
                        child: Text(
                          'Start 10s Timer',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // STAGE 3: 10-SECOND COUNTDOWN & LINEAR PROGRESS
  // ==========================================
  Widget _buildCountdownView(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      key: const ValueKey('stage-countdown'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pulsing countdown badge icon
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.error.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.error.withValues(alpha: 0.2),
                blurRadius: 16.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Icon(
            Icons.hourglass_bottom_rounded,
            color: colors.error,
            size: 26.sp,
          ),
        ),
        SizedBox(height: 14.h),

        // Main Countdown Headline & progress row
        ValueListenableBuilder<int>(
          valueListenable: _secondsLeftNotifier,
          builder: (context, secondsLeft, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Purging Vault in $secondsLeft Seconds',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 19.sp,
                    letterSpacing: -0.3,
                    color: colors.error,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Grace period active. You can abort the wipe at any time before the timer expires.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 20.h),

                // Linear Loading Indicator Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    border: Border.all(color: colors.borderDivider, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metric row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: colors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'COUNTDOWN PROGRESS',
                                style: context.textTheme.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                  letterSpacing: 0.6,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '${secondsLeft}s left',
                              key: ValueKey(secondsLeft),
                              style: context.textTheme.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.sp,
                                color: colors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Animated Linear Progress Bar
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusFull,
                            ),
                            child: SizedBox(
                              height: 10.h,
                              width: double.infinity,
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor: colors.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.error,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 24.h),

        // Prominent Abort / Cancel Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: colors.secondary.withValues(alpha: 0.35),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
            ),
            icon: Icon(Icons.close_rounded, size: 20.sp),
            label: Text(
              'Abort Wipe & Keep Data',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            onPressed: _cancelWipe,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STAGE 4: WIPING IN PROGRESS
  // ==========================================
  Widget _buildWipingView(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      key: const ValueKey('stage-wiping'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 44.w,
          height: 44.w,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(colors.error),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Erasing Expedition Vault...',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Cleaning SQLite database and clearing local tables.',
          textAlign: TextAlign.center,
          style: context.textTheme.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildInventoryRow({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: colors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11.5.sp,
            ),
          ),
        ),
      ],
    );
  }
}
