import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
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

  @override
  void dispose() {
    _isProcessingNotifier.dispose();
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
      if (mounted)
        WaymarkSnackbar.showSuccess(
          context,
          context.l10n.settingsStorageClearedToast,
        );
    } catch (_) {
      if (mounted)
        WaymarkSnackbar.showError(context, 'Unable to clear journey records.');
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
