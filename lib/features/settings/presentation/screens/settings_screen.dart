import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/backup_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/settings/presentation/widgets/wipe_vault_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> _isProcessingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _autoBackupEnabledNotifier = ValueNotifier<bool>(
    true,
  );

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  Future<void> _loadBackupSettings() async {
    final isEnabled = await BackupService.isAutoBackupEnabled();
    if (mounted) {
      _autoBackupEnabledNotifier.value = isEnabled;
    }
  }

  @override
  void dispose() {
    _isProcessingNotifier.dispose();
    _autoBackupEnabledNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleClearJourneys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          title: Text(dialogContext.l10n.settingsDialogClearTitle),
          content: Text(dialogContext.l10n.settingsDialogClearDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogContext.l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(dialogContext.l10n.settingsDialogClearConfirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    _isProcessingNotifier.value = true;
    try {
      await AppDatabase.instance.clearAllJourneys();
      if (mounted) {
        WaymarkSnackbar.showSuccess(
          context,
          context.l10n.settingsStorageClearedToast,
        );
      }
    } catch (_) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Unable to clear journey records.');
      }
    } finally {
      if (mounted) _isProcessingNotifier.value = false;
    }
  }

  void _handleWipeDatabase() {
    WipeVaultDialog.show(
      context,
      onWipeSuccess: () {
        if (!mounted) return;
        WaymarkSnackbar.showSuccess(
          context,
          context.l10n.settingsClearDatabaseSuccess,
        );
        context.go(AppRoutes.onboarding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
            _buildSectionHeader(
              context,
              Icons.tune_rounded,
              'WayMark Settings',
            ),
            SizedBox(height: 10.h),
            _buildMenuCard(context),
            SizedBox(height: 24.h),
            _buildSectionHeader(
              context,
              Icons.storage_rounded,
              'Data Management',
            ),
            SizedBox(height: 10.h),
            _buildDataCard(context),
            SizedBox(height: 24.h),
            _buildSectionHeader(
              context,
              Icons.backup_rounded,
              'Backup & Restore',
            ),
            SizedBox(height: 10.h),
            _buildBackupCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return _buildCard(
      context,
      child: Column(
        children: [
          _buildMenuTile(
            context,
            Icons.support_agent_rounded,
            'Help & Support',
            'Contact support and get troubleshooting guidance',
            AppRoutes.helpSupport,
          ),
          _buildDivider(context),
          _buildMenuTile(
            context,
            Icons.help_outline_rounded,
            'Frequently Asked Questions',
            'Quick answers about using WayMark',
            AppRoutes.faq,
          ),
          _buildDivider(context),
          _buildMenuTile(
            context,
            Icons.info_outline_rounded,
            'About WayMark',
            'Learn about the app and its purpose',
            AppRoutes.about,
          ),
          _buildDivider(context),
          _buildMenuTile(
            context,
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'How your journey information is handled',
            AppRoutes.privacyPolicy,
          ),
          _buildDivider(context),
          _buildMenuTile(
            context,
            Icons.gavel_outlined,
            'Terms & Conditions',
            'Terms for using WayMark',
            AppRoutes.termsConditions,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return _buildCard(
      context,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isProcessingNotifier,
        builder: (context, isProcessing, _) => Column(
          children: [
            _buildActionRow(
              context,
              Icons.cleaning_services_rounded,
              context.l10n.settingsClearMemoirsTitle,
              context.l10n.settingsClearMemoirsDesc,
              TextButton(
                onPressed: isProcessing ? null : _handleClearJourneys,
                child: Text(context.l10n.settingsBtnClear),
              ),
            ),
            _buildDataDivider(context),
            _buildActionRow(
              context,
              Icons.delete_forever_rounded,
              context.l10n.settingsClearDatabaseBtn,
              context.l10n.settingsClearDatabaseDesc,
              OutlinedButton(
                onPressed: isProcessing ? null : _handleWipeDatabase,
                child: Text(context.l10n.settingsBtnWipeVault),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(BuildContext context) {
    return _buildCard(
      context,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isProcessingNotifier,
        builder: (context, isProcessing, _) => ValueListenableBuilder<bool>(
          valueListenable: _autoBackupEnabledNotifier,
          builder: (context, autoBackup, _) => Column(
            children: [
              _buildActionRow(
                context,
                Icons.update_rounded,
                'Automated Backup',
                'Backup journey data every time the app is opened',
                Switch(
                  value: autoBackup,
                  onChanged: isProcessing
                      ? null
                      : (val) async {
                          _isProcessingNotifier.value = true;
                          await BackupService.setAutoBackupEnabled(val);
                          _autoBackupEnabledNotifier.value = val;
                          _isProcessingNotifier.value = false;
                        },
                ),
              ),
              if (!autoBackup) ...[
                _buildDataDivider(context),
                _buildActionRow(
                  context,
                  Icons.save_rounded,
                  'Create Manual Backup',
                  'Save a .csv backup to Downloads/waymark folder',
                  TextButton(
                    onPressed: isProcessing ? null : _handleManualBackup,
                    child: const Text('Backup'),
                  ),
                ),
              ],
              _buildDataDivider(context),
              _buildActionRow(
                context,
                Icons.restore_rounded,
                'Restore Backup',
                'Restore from a previous backup file',
                OutlinedButton(
                  onPressed: isProcessing ? null : _handleRestoreBackup,
                  child: const Text('Restore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleManualBackup() async {
    _isProcessingNotifier.value = true;
    try {
      final path = await BackupService.createBackup(isManual: true);
      if (mounted && path != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: ctx.colorScheme.surfaceCard,
            title: const Text('Backup Successful'),
            content: Text(
              'Journal backup saved as CSV:\n$path\n\nApp Signature: ${BackupService.appSignature}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        WaymarkSnackbar.showError(context, message);
      }
    } finally {
      if (mounted) {
        _isProcessingNotifier.value = false;
      }
    }
  }

  Future<void> _handleRestoreBackup() async {
    _isProcessingNotifier.value = true;
    try {
      final backups = await BackupService.getAvailableBackups();
      if (!mounted) return;

      if (backups.isEmpty) {
        WaymarkSnackbar.showInfo(
          context,
          'No backup files found in Downloads folder.',
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        backgroundColor: context.colorScheme.surface,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (ctx) {
          final colors = ctx.colorScheme;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colors.borderDivider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Select Backup to Restore',
                    style: ctx.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Restoring replaces current database records. Newer active data will be protected.',
                    style: ctx.textTheme.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: backups.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: colors.borderDivider),
                      itemBuilder: (context, index) {
                        final file = backups[index];
                        final fileName = p.basename(file.path);
                        final isCsv = fileName.endsWith('.csv');
                        final size = (file.lengthSync() / 1024).toStringAsFixed(
                          1,
                        );
                        final backupTimestamp =
                            BackupService.getBackupTimestamp(file);
                        final formattedDate = DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(backupTimestamp);
                        final sig = BackupService.getBackupSignature(file);
                        final isMatch = BackupService.isSignatureMatch(file);

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                          leading: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isMatch
                                  ? colors.primary.withValues(alpha: 0.1)
                                  : colors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              isCsv
                                  ? Icons.table_chart_rounded
                                  : Icons.storage_rounded,
                              color: isMatch ? colors.primary : colors.warning,
                              size: 22.sp,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (sig != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMatch
                                        ? colors.primary.withValues(alpha: 0.12)
                                        : colors.warning.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    isMatch
                                        ? 'Sig $sig'
                                        : 'Sig $sig (Mismatch)',
                                    style: context.textTheme.caption.copyWith(
                                      color: isMatch
                                          ? colors.primary
                                          : colors.warning,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            '$fileName • $size KB • ${isCsv ? 'CSV' : 'SQLite'}',
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.textSecondary,
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _processBackupSelection(file);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) WaymarkSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) {
        _isProcessingNotifier.value = false;
      }
    }
  }

  Future<void> _processBackupSelection(File backupFile) async {
    _isProcessingNotifier.value = true;
    try {
      final validation = await BackupService.validateRestoreSafety(backupFile);
      if (!mounted) return;

      if (!validation.isSafeToRestore) {
        // Show Blocked Dialog
        await _showRestoreBlockedDialog(validation);
        return;
      }

      // Safe to restore -> Show Confirmation Dialog
      final shouldRestore = await _showRestoreConfirmationDialog(validation);
      if (shouldRestore == true && mounted) {
        await _performRestore(backupFile);
      }
    } catch (e) {
      if (mounted) WaymarkSnackbar.showError(context, 'Validation error: $e');
    } finally {
      if (mounted) {
        _isProcessingNotifier.value = false;
      }
    }
  }

  Future<void> _showRestoreBlockedDialog(
    RestoreValidationResult validation,
  ) async {
    final colors = context.colorScheme;
    final isSigMismatch = !validation.isSignatureMatch;
    final latestActiveDate = validation.activeSummary.latestTimestamp != null
        ? DateFormat(
            'MMM dd, yyyy • hh:mm a',
          ).format(validation.activeSummary.latestTimestamp!)
        : 'Recent date';
    final backupDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(validation.backupTimestamp);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(color: colors.borderDivider),
          ),
          icon: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSigMismatch ? Icons.fingerprint_rounded : Icons.block_rounded,
              color: colors.error,
              size: 26.sp,
            ),
          ),
          title: Text(
            isSigMismatch
                ? 'Restore Blocked: Signature Mismatch'
                : 'Restore Blocked: Newer Data Detected',
            textAlign: TextAlign.center,
            style: dialogCtx.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                validation.blockReason ??
                    'Your current journal contains records modified on $latestActiveDate, which is newer than this backup snapshot taken on $backupDate.',
                style: dialogCtx.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.w),
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
                      Icons.shield_outlined,
                      size: 16.sp,
                      color: colors.error,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        isSigMismatch
                            ? 'App signature verification prevents importing data from incompatible builds or different app signing certificates.'
                            : 'To prevent accidental loss of recent memories, Waymark blocks overwriting newer records. Backup restore is intended for recovering data onto a clean reinstall or reset device.',
                        style: dialogCtx.textTheme.caption.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showRestoreConfirmationDialog(
    RestoreValidationResult validation,
  ) async {
    final colors = context.colorScheme;
    final backupDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(validation.backupTimestamp);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(color: colors.borderDivider),
          ),
          icon: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: colors.warning,
              size: 26.sp,
            ),
          ),
          title: Text(
            'Confirm Journal Restore',
            textAlign: TextAlign.center,
            style: dialogCtx.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to restore this journal snapshot?',
                style: dialogCtx.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
                  border: Border.all(color: colors.borderDivider, width: 0.8),
                ),
                child: Column(
                  children: [
                    _buildDialogInfoRow(dialogCtx, 'Snapshot Date', backupDate),
                    SizedBox(height: 4.h),
                    _buildDialogInfoRow(
                      dialogCtx,
                      'App Signature',
                      '${validation.backupSignature ?? BackupService.appSignature} (Matches App)',
                    ),
                    SizedBox(height: 4.h),
                    _buildDialogInfoRow(
                      dialogCtx,
                      'Backup Format',
                      validation.backupSignature != null
                          ? 'CSV Data File'
                          : 'Journal Snapshot',
                    ),
                    SizedBox(height: 4.h),
                    _buildDialogInfoRow(
                      dialogCtx,
                      'Target Vault',
                      'Active Database',
                    ),
                    SizedBox(height: 4.h),
                    _buildDialogInfoRow(
                      dialogCtx,
                      'Current Vault',
                      validation.activeSummary.isEmpty
                          ? 'Empty (Ready for restore)'
                          : '${validation.activeSummary.albumCount} albums, ${validation.activeSummary.placeCount} places',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '⚠️ Restoring will overwrite existing journeys, places, and waypoints with the contents of this backup file. This action cannot be undone.',
                style: dialogCtx.textTheme.caption.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.warning,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Confirm Restore'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogInfoRow(BuildContext context, String label, String value) {
    final colors = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: context.textTheme.caption.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _performRestore(File backupFile) async {
    _isProcessingNotifier.value = true;
    try {
      await BackupService.restoreBackup(backupFile);
      if (!mounted) return;
      WaymarkSnackbar.showSuccess(context, 'Journal restored successfully!');

      final profile = await AppDatabase.instance.userProfileDao.getProfile();
      if (!mounted) return;
      if (profile != null) {
        context.go(AppRoutes.journeys);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (mounted) WaymarkSnackbar.showError(context, 'Failed to restore: $e');
    } finally {
      if (mounted) _isProcessingNotifier.value = false;
    }
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    final colors = context.colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Icon(icon, color: colors.primary, size: 21.sp),
        ),
        title: Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.textSecondary,
        ),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Widget action,
  ) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, color: colors.primary, size: 19.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
        SizedBox(width: 6.w),
        action,
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: colors.secondary),
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

  Widget _buildDivider(BuildContext context) =>
      Divider(height: 1, color: context.colorScheme.borderDivider);

  Widget _buildDataDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: _buildDivider(context),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final colors = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.borderDivider, width: 0.8),
      ),
      child: child,
    );
  }
}
