import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/permission_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/widgets/drift_vault_settings_card.dart';
import 'package:waymark/features/onboarding/presentation/widgets/onboarding_feature_bento_card.dart';
import 'package:waymark/features/onboarding/presentation/widgets/onboarding_hero_card.dart';
import 'package:waymark/features/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_avatar_picker.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_form_fields.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PermissionService _permissionService = PermissionService();

  final ValueNotifier<int> _currentStepNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  // Step 2 Form Controllers & States
  late final TextEditingController _nameController;
  late final TextEditingController _handleController;
  late final TextEditingController _bioController;

  final ValueNotifier<String> _selectedArchetypeNotifier =
      ValueNotifier<String>('Casual Explorer');
  final ValueNotifier<String> _unitSystemNotifier = ValueNotifier<String>(
    'metric',
  );
  final ValueNotifier<bool> _autoExifGpsEnabledNotifier = ValueNotifier<bool>(
    true,
  );
  final ValueNotifier<String?> _avatarPathNotifier = ValueNotifier<String?>(
    'avatar:explorer',
  );
  String? get _avatarPath => _avatarPathNotifier.value;
  static const String _vaultPath = '/sandbox/documents/vault_001.drift';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _handleController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _currentStepNotifier.dispose();
    _isSavingNotifier.dispose();
    _selectedArchetypeNotifier.dispose();
    _unitSystemNotifier.dispose();
    _autoExifGpsEnabledNotifier.dispose();
    _avatarPathNotifier.dispose();
    super.dispose();
  }

  Future<void> _processAndSetAvatar(
    String pickedPath,
    BuildContext modalContext,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(p.join(appDir.path, 'avatars'));
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }
      final ext = p.extension(pickedPath).isNotEmpty
          ? p.extension(pickedPath)
          : '.jpg';
      final permanentFile = File(
        p.join(
          avatarDir.path,
          'avatar_${DateTime.now().millisecondsSinceEpoch}$ext',
        ),
      );
      await File(pickedPath).copy(permanentFile.path);
      _avatarPathNotifier.value = permanentFile.path;
    } catch (_) {
      _avatarPathNotifier.value = pickedPath;
    }
    if (modalContext.mounted) {
      Navigator.of(modalContext).pop();
    }
  }

  void _pickAvatar() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (modalContext) {
        final modalColors = modalContext.colorScheme;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: WaymarkSpacing.margin(modalContext),
              vertical: WaymarkSpacing.spaceMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: modalColors.borderDivider,
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  modalContext.l10n.onboardingPortraitTitle,
                  style: modalContext.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  modalContext.l10n.onboardingPortraitSubtitle,
                  style: modalContext.textTheme.bodySmall?.copyWith(
                    color: modalColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Camera & Gallery actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final picker = ImagePicker();
                            final photo = await picker.pickImage(
                              source: ImageSource.camera,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 85,
                            );
                            if (photo != null &&
                                mounted &&
                                modalContext.mounted) {
                              await _processAndSetAvatar(
                                photo.path,
                                modalContext,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            WaymarkSnackbar.showError(
                              context,
                              context.l10n.profileCameraError(e.toString()),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 18.sp,
                          color: modalColors.primary,
                        ),
                        label: Text(
                          modalContext.l10n.profileBtnTakePhoto,
                          style: modalContext.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: modalColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: modalColors.primary.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 85,
                            );
                            if (image != null &&
                                mounted &&
                                modalContext.mounted) {
                              await _processAndSetAvatar(
                                image.path,
                                modalContext,
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            WaymarkSnackbar.showError(
                              context,
                              context.l10n.profileGalleryError(e.toString()),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.photo_library_rounded,
                          size: 18.sp,
                          color: modalColors.secondary,
                        ),
                        label: Text(
                          modalContext.l10n.profileBtnFromGallery,
                          style: modalContext.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: modalColors.secondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: modalColors.secondary.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                Text(
                  modalContext.l10n.profileChoosePresetTitle,
                  style: modalContext.textTheme.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: modalColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),

                // Grid of 8 preset avatars
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: TravelerAvatarPicker.presets.length,
                  itemBuilder: (context, index) {
                    final preset = TravelerAvatarPicker.presets[index];
                    final isSelected =
                        _avatarPath == preset.id ||
                        (_avatarPath == null && index == 0);
                    return InkWell(
                      onTap: () {
                        _avatarPathNotifier.value = preset.id;
                        Navigator.pop(modalContext);
                      },
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusMd,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? modalColors.primary.withValues(alpha: 0.08)
                              : modalColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusMd,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? modalColors.primary
                                : modalColors.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: preset.gradientColors,
                                ),
                              ),
                              child: Icon(
                                preset.icon,
                                size: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              preset.name,
                              style: context.textTheme.caption.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? modalColors.primary
                                    : modalColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _completeOnboarding() async {
    if (_isSavingNotifier.value) return;
    _isSavingNotifier.value = true;

    try {
      if (_autoExifGpsEnabledNotifier.value) {
        await _permissionService.requestLocationPermission();
        await _permissionService.requestPhotosPermission();
      }

      // Persist profile to Drift SQLite
      await AppDatabase.instance.userProfileDao.createOrUpdateProfile(
        UserProfilesCompanion(
          fullName: drift.Value(
            _nameController.text.trim().isEmpty
                ? 'Traveler'
                : _nameController.text.trim(),
          ),
          handle: drift.Value(
            _handleController.text.trim().isEmpty
                ? 'traveler@example.com'
                : _handleController.text.trim(),
          ),
          avatarPath: drift.Value(
            _avatarPathNotifier.value ?? 'avatar:explorer',
          ),
          archetype: drift.Value(_selectedArchetypeNotifier.value),
          bio: drift.Value(
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          ),
          unitSystem: drift.Value(_unitSystemNotifier.value),
          autoExifGpsEnabled: drift.Value(_autoExifGpsEnabledNotifier.value),
          vaultPath: const drift.Value(_vaultPath),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      if (!mounted) return;
      context.go(AppRoutes.journeys);
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(
          context,
          context.l10n.onboardingVaultInitError(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ValueListenableBuilder<int>(
        valueListenable: _currentStepNotifier,
        builder: (context, currentStep, _) {
          return Scaffold(
            backgroundColor: colors.surface,
            extendBodyBehindAppBar: true,
            appBar: OnboardingStepHeader(
              step: currentStep,
              totalSteps: 2,
              onBack: currentStep > 1
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              onSkip: null, // Mandatory onboarding: skipping is disabled
            ),
            body: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                _currentStepNotifier.value = index + 1;
              },
              children: [_buildWelcomeStep(), _buildProfileVaultStep()],
            ),
          );
        },
      ),
    );
  }

  // --- Step 1: Welcome & Philosophy ---
  Widget _buildWelcomeStep() {
    final colors = context.colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top + 86.h;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: WaymarkSpacing.margin(context),
            right: WaymarkSpacing.margin(context),
            top: topPadding + WaymarkSpacing.spaceSm,
            bottom: bottomPadding + 130.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Poster Print with Paper Elevation Treatment
              const OnboardingHeroCard(),

              SizedBox(height: WaymarkSpacing.spaceLg),

              // Title & Narrative Subtitle
              Text.rich(
                TextSpan(
                  text: '${context.l10n.onboardingHeroTitle}\n',
                  style: context.textTheme.displayMedium?.copyWith(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: context.l10n.onboardingHeroTitleItalic,
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: colors.primary,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.l10n.onboardingHeroDesc,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: WaymarkSpacing.spaceLg),

              // Feature Highlights: Tactile Editorial Bento Cards
              OnboardingFeatureBentoCard(
                icon: Icons.lock_clock_rounded,
                iconColor: colors.primary,
                title: context.l10n.onboardingFeature1Title,
                badgeText: context.l10n.onboardingFeature1Badge,
                badgeBackgroundColor: colors.secondaryContainer,
                badgeTextColor: colors.onSecondaryContainer,
                description: context.l10n.onboardingFeature1Desc,
              ),
              SizedBox(height: WaymarkSpacing.spaceSm),
              OnboardingFeatureBentoCard(
                icon: Icons.timeline_rounded,
                iconColor: colors.secondary,
                title: context.l10n.onboardingFeature2Title,
                badgeText: context.l10n.onboardingFeature2Badge,
                badgeBackgroundColor: colors.primaryContainer,
                badgeTextColor: colors.onPrimaryContainer,
                description: context.l10n.onboardingFeature2Desc,
              ),
              SizedBox(height: WaymarkSpacing.spaceSm),
              OnboardingFeatureBentoCard(
                icon: Icons.photo_library_rounded,
                iconColor: colors.tertiary,
                title: context.l10n.onboardingFeature3Title,
                badgeText: context.l10n.onboardingFeature3Badge,
                badgeBackgroundColor: colors.tertiaryContainer,
                badgeTextColor: colors.onTertiaryContainer,
                description: context.l10n.onboardingFeature3Desc,
              ),
            ],
          ),
        ),

        // Sticky Bottom Action Bar with Liquid Glass Effect
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: WaymarkLiquidGlass(
            width: double.infinity,
            blurSigma: 20.0,
            tintColor: colors.surface,
            tintAlpha: 0.88,
            showSpecularHighlight: true,
            border: Border(
              top: BorderSide(
                color: colors.borderDivider.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 16.r,
                offset: Offset(0, -4.h),
              ),
            ],
            padding: EdgeInsets.only(
              left: WaymarkSpacing.margin(context),
              right: WaymarkSpacing.margin(context),
              top: 12.h,
              bottom: bottomPadding > 0 ? bottomPadding + 8.h : 16.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary CTA: Begin Setup & Profile (Always Visible)
                SizedBox(
                  width: double.infinity,
                  child: WaymarkPrimaryButton(
                    label: context.l10n.onboardingBtnBeginSetup,
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),

                SizedBox(height: 8.h),

                // Secondary Restore Link
                Center(
                  child: InkWell(
                    onTap: () {
                      WaymarkSnackbar.showInfo(
                        context,
                        context.l10n.onboardingRestoreBackupSnackbar,
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 12.w,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.unarchive_rounded,
                            size: 15.sp,
                            color: colors.outline,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                text:
                                    context.l10n.onboardingRestoreBackupPrefix,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: context
                                        .l10n
                                        .onboardingRestoreBackupFile,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          fontFamily: 'monospace',
                                          color: colors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                  TextSpan(
                                    text: context
                                        .l10n
                                        .onboardingRestoreBackupSuffix,
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.textSecondary,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Step 2: Profile & Vault Creation ---
  Widget _buildProfileVaultStep() {
    final colors = context.colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top + 86.h;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: WaymarkSpacing.margin(context),
            right: WaymarkSpacing.margin(context),
            top: topPadding + WaymarkSpacing.spaceSm,
            bottom: bottomPadding + 110.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Description
              Text(
                context.l10n.profileClaimCompassTitle,
                style: context.textTheme.displayMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                context.l10n.profileClaimCompassDesc,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),

              SizedBox(height: WaymarkSpacing.spaceLg),

              // Traveler Avatar Picker
              Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _avatarPathNotifier,
                  builder: (context, avatarPath, _) {
                    return TravelerAvatarPicker(
                      avatarPath: avatarPath,
                      onPickAvatar: _pickAvatar,
                    );
                  },
                ),
              ),

              SizedBox(height: WaymarkSpacing.spaceLg),

              // Traveler Form Fields (Name, Handle, Archetype, Bio)
              ValueListenableBuilder<String>(
                valueListenable: _selectedArchetypeNotifier,
                builder: (context, selectedArchetype, _) {
                  return TravelerFormFields(
                    nameController: _nameController,
                    handleController: _handleController,
                    bioController: _bioController,
                    selectedArchetype: selectedArchetype,
                    onSelectArchetype: (archetype) {
                      _selectedArchetypeNotifier.value = archetype;
                    },
                  );
                },
              ),

              SizedBox(height: WaymarkSpacing.spaceMd),

              // Local Drift Vault Settings Card
              ValueListenableBuilder<String>(
                valueListenable: _unitSystemNotifier,
                builder: (context, unitSystem, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _autoExifGpsEnabledNotifier,
                    builder: (context, autoExifGpsEnabled, _) {
                      return DriftVaultSettingsCard(
                        unitSystem: unitSystem,
                        onUnitChanged: (unit) {
                          _unitSystemNotifier.value = unit;
                        },
                        autoExifGpsEnabled: autoExifGpsEnabled,
                        onAutoExifChanged: (enabled) {
                          _autoExifGpsEnabledNotifier.value = enabled;
                        },
                        vaultPath: _vaultPath,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // Sticky Bottom Action Bar with Liquid Glass Effect
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: WaymarkLiquidGlass(
            width: double.infinity,
            blurSigma: 20.0,
            tintColor: colors.surface,
            tintAlpha: 0.88,
            showSpecularHighlight: true,
            border: Border(
              top: BorderSide(
                color: colors.borderDivider.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x14000000),
                blurRadius: 16.r,
                offset: Offset(0, -4.h),
              ),
            ],
            padding: EdgeInsets.only(
              left: WaymarkSpacing.margin(context),
              right: WaymarkSpacing.margin(context),
              top: 12.h,
              bottom: bottomPadding > 0 ? bottomPadding + 8.h : 16.h,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, _) {
                  return WaymarkPrimaryButton(
                    label: context.l10n.profileBtnInitializeVault,
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading: isSaving,
                    onPressed: isSaving ? null : _completeOnboarding,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
