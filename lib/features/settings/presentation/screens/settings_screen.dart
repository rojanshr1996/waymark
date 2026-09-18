import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/settings/presentation/widgets/wipe_vault_dialog.dart';

/// Settings & Vault screen for managing offline storage, diagnostics,
/// and local SQLite data wiping.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> _isProcessingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isProcessingNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleClearJourneys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = ctx.colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            ctx.l10n.settingsDialogClearTitle,
            style: ctx.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            ctx.l10n.settingsDialogClearDesc,
            style: ctx.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                ctx.l10n.commonCancel,
                style: ctx.textTheme.labelLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(ctx.l10n.settingsDialogClearConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _isProcessingNotifier.value = true;
      try {
        await AppDatabase.instance.clearAllJourneys();
        if (mounted) {
          WaymarkSnackbar.showSuccess(
            context,
            context.l10n.settingsStorageClearedToast,
          );
        }
      } catch (e) {
        if (mounted) {
          WaymarkSnackbar.showError(context, 'Failed to clear journeys: $e');
        }
      } finally {
        if (mounted) _isProcessingNotifier.value = false;
      }
    }
  }

  void _handleWipeDatabase() {
    WipeVaultDialog.show(
      context,
      onWipeSuccess: () {
        if (mounted) {
          WaymarkSnackbar.showSuccess(
            context,
            context.l10n.settingsClearDatabaseSuccess,
          );
          context.go(AppRoutes.onboarding);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final flavorName = AppFlavorConfig.isInitialized
        ? AppFlavorConfig.instance.flavor.displayName
        : 'Development';

    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: true,
      appBar: WaymarkLiquidGlassAppBar(
        title: context.l10n.settingsTitle,
        subtitle: context.l10n.settingsSubtitle,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: WaymarkSpacing.margin(context),
          right: WaymarkSpacing.margin(context),
          top: MediaQuery.paddingOf(context).top + 76.h,
          bottom: 40.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: SQLite Vault Management
            _buildSectionHeader(
              context: context,
              icon: Icons.storage_rounded,
              title: context.l10n.settingsVaultSection,
            ),
            SizedBox(height: 10.h),
            _buildCard(
              context: context,
              children: [
                // Engine info row
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.dns_rounded,
                        color: colors.primary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsDriftEngineTitle,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            context.l10n.settingsDriftEngineSubtitle,
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFADF2C3).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(
                          WaymarkSpacing.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12.sp,
                            color: const Color(0xFF2F704B),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            context.l10n.settingsStatusActive,
                            style: context.textTheme.caption.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2F704B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: colors.borderDivider, height: 1),
                SizedBox(height: 14.h),

                // Clear Journey Memoirs Button
                ValueListenableBuilder<bool>(
                  valueListenable: _isProcessingNotifier,
                  builder: (context, isProcessing, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              color: colors.warning,
                              size: 18.sp,
                            ),
                          ),
                          title: Text(
                            context.l10n.settingsClearMemoirsTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.settingsClearMemoirsDesc,
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          trailing: isProcessing
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextButton(
                                  onPressed: _handleClearJourneys,
                                  child: Text(
                                    context.l10n.settingsBtnClear,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.warning,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 10.h),
                        Divider(color: colors.borderDivider, height: 1),
                        SizedBox(height: 14.h),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.delete_forever_rounded,
                              color: colors.error,
                              size: 20.sp,
                            ),
                          ),
                          title: Text(
                            context.l10n.settingsClearDatabaseBtn,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.error,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.settingsClearDatabaseDesc,
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          trailing: isProcessing
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colors.error,
                                      width: 1,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                  ),
                                  onPressed: _handleWipeDatabase,
                                  child: Text(
                                    context.l10n.settingsBtnWipeVault,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Section 2: Privacy & Architecture Guarantees
            _buildSectionHeader(
              context: context,
              icon: Icons.verified_user_outlined,
              title: context.l10n.settingsPrivacySection,
            ),
            SizedBox(height: 10.h),
            _buildCard(
              context: context,
              children: [
                _buildBulletPoint(
                  context: context,
                  icon: Icons.cloud_off_rounded,
                  title: context.l10n.settingsZeroCloudTitle,
                  description: context.l10n.settingsZeroCloudDesc,
                ),
                SizedBox(height: 12.h),
                _buildBulletPoint(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  title: context.l10n.settingsNativeExifTitle,
                  description: context.l10n.settingsNativeExifDesc,
                ),
                SizedBox(height: 12.h),
                _buildBulletPoint(
                  context: context,
                  icon: Icons.alt_route_rounded,
                  title: context.l10n.settingsOfflineTrailsTitle,
                  description: context.l10n.settingsOfflineTrailsDesc,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Section 3: About WayMark
            _buildSectionHeader(
              context: context,
              icon: Icons.info_outline_rounded,
              title: context.l10n.settingsAboutSection,
            ),
            SizedBox(height: 10.h),
            _buildCard(
              context: context,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.settingsAppDescription,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.l10n.settingsAppVersion,
                      style: context.textTheme.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.settingsEnvFlavor,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      flavorName,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.settingsStorageArch,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      context.l10n.settingsStorageArchValue,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: colors.secondary),
        SizedBox(width: 8.w),
        Text(
          title.toUpperCase(),
          style: context.textTheme.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: colors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final colors = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(WaymarkSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderDivider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x081F2421),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBulletPoint({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = context.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: colors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: context.textTheme.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
