import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class DriftVaultSettingsCard extends StatelessWidget {
  final String unitSystem; // 'metric' or 'imperial'
  final ValueChanged<String> onUnitChanged;
  final bool autoExifGpsEnabled;
  final ValueChanged<bool> onAutoExifChanged;
  final String vaultPath;

  const DriftVaultSettingsCard({
    super.key,
    required this.unitSystem,
    required this.onUnitChanged,
    required this.autoExifGpsEnabled,
    required this.onAutoExifChanged,
    this.vaultPath = '/sandbox/documents/vault_001.drift',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isMetric = unitSystem.toLowerCase() == 'metric';

    return Container(
      padding: EdgeInsets.all(WaymarkSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(color: colors.borderDivider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Shield icon, Private Travel Storage, Offline badge
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 20.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.l10n.vaultPrivateStorageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.headlineSmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.forestVivid,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.vaultPrivateStorageSubtitle,
                      style: context.textTheme.caption.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  context.l10n.vaultOfflineBadge,
                  style: context.textTheme.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: WaymarkSpacing.spaceMd),

          // Measurement Standards Segmented Toggle
          Text(
            context.l10n.profileMeasurementStandards,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Stack(
              children: [
                // Sliding indicator pill
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    alignment: isMetric
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14000000),
                              blurRadius: 4.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Foreground interactive tabs
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (!isMetric) {
                              HapticFeedback.selectionClick();
                              onUnitChanged('metric');
                            }
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<Color?>(
                                  duration: const Duration(milliseconds: 200),
                                  tween: ColorTween(
                                    end: isMetric
                                        ? colors.primary
                                        : colors.textSecondary,
                                  ),
                                  builder: (context, color, _) => Icon(
                                    Icons.straighten_rounded,
                                    size: 16.sp,
                                    color: color,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style:
                                        (context.textTheme.labelMedium ??
                                                const TextStyle())
                                            .copyWith(
                                              color: isMetric
                                                  ? colors.textPrimary
                                                  : colors.textSecondary,
                                              fontWeight: isMetric
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                    child: Text(
                                      context.l10n.profileMetricUnit,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isMetric) {
                              HapticFeedback.selectionClick();
                              onUnitChanged('imperial');
                            }
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<Color?>(
                                  duration: const Duration(milliseconds: 200),
                                  tween: ColorTween(
                                    end: !isMetric
                                        ? colors.primary
                                        : colors.textSecondary,
                                  ),
                                  builder: (context, color, _) => Icon(
                                    Icons.navigation_rounded,
                                    size: 16.sp,
                                    color: color,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style:
                                        (context.textTheme.labelMedium ??
                                                const TextStyle())
                                            .copyWith(
                                              color: !isMetric
                                                  ? colors.textPrimary
                                                  : colors.textSecondary,
                                              fontWeight: !isMetric
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                    child: Text(
                                      context.l10n.profileImperialUnit,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: WaymarkSpacing.spaceMd),

          // Auto-EXIF GPS Extraction
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.l10n.profileAutoExifTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.headlineSmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.satellite_alt_rounded,
                          size: 16.sp,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.profileAutoExifDesc,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => onAutoExifChanged(!autoExifGpsEnabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48.w,
                  height: 28.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    color: autoExifGpsEnabled
                        ? colors.primary
                        : colors.surfaceContainerHigh,
                  ),
                  alignment: autoExifGpsEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      autoExifGpsEnabled ? Icons.check : Icons.close,
                      size: 14.sp,
                      color: autoExifGpsEnabled
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
