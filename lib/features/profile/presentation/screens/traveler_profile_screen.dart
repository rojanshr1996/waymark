import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/onboarding/presentation/widgets/drift_vault_settings_card.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_avatar_picker.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_form_fields.dart';

class TravelerProfileScreen extends StatefulWidget {
  const TravelerProfileScreen({super.key});

  @override
  State<TravelerProfileScreen> createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _handleController;
  late final TextEditingController _bioController;

  final ValueNotifier<String?> _avatarPathNotifier = ValueNotifier<String?>(
    null,
  );
  String? get _avatarPath => _avatarPathNotifier.value;
  final ValueNotifier<String> _selectedArchetypeNotifier =
      ValueNotifier<String>('Wayfarer');
  final ValueNotifier<String> _unitSystemNotifier = ValueNotifier<String>(
    'metric',
  );
  final ValueNotifier<bool> _autoExifGpsEnabledNotifier = ValueNotifier<bool>(
    true,
  );
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  String _vaultPath = '/sandbox/documents/vault_001.drift';

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _handleController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _avatarPathNotifier.dispose();
    _selectedArchetypeNotifier.dispose();
    _unitSystemNotifier.dispose();
    _autoExifGpsEnabledNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  void _populateFromProfile(UserProfile profile) {
    if (_isInitialized) return;
    _isInitialized = true;
    _nameController.text = profile.fullName;
    _handleController.text = profile.handle;
    _bioController.text = profile.bio ?? '';
    _avatarPathNotifier.value = profile.avatarPath;
    _selectedArchetypeNotifier.value = profile.archetype;
    _unitSystemNotifier.value = profile.unitSystem;
    _autoExifGpsEnabledNotifier.value = profile.autoExifGpsEnabled;
    _vaultPath = profile.vaultPath;
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

  Future<void> _pickAvatar() async {
    final colors = context.colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (modalContext) {
        final modalColors = modalContext.colorScheme;
        final safeBottom = MediaQuery.paddingOf(modalContext).bottom;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: safeBottom > 0 ? safeBottom : 16.h,
            ),
            child: ScrollConfiguration(
              behavior: const WaymarkNoOverscrollScrollBehavior(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: modalColors.outlineVariant,
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusFull,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      context.l10n.profileAvatarLabel,
                      style: modalContext.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: modalColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
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
                              style: modalContext.textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: modalColors.primary,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(
                                color: modalColors.primary.withValues(
                                  alpha: 0.3,
                                ),
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
                                  context.l10n.profileGalleryError(
                                    e.toString(),
                                  ),
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
                              style: modalContext.textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: modalColors.secondary,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(
                                color: modalColors.secondary.withValues(
                                  alpha: 0.3,
                                ),
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: TravelerAvatarPicker.presets.length,
                      itemBuilder: (context, index) {
                        final preset = TravelerAvatarPicker.presets[index];
                        final isSelected = _avatarPath == preset.id;
                        return InkWell(
                          onTap: () {
                            _avatarPathNotifier.value = preset.id;
                            if (modalContext.mounted) {
                              Navigator.of(modalContext).pop();
                            }
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSavingNotifier.value) return;
    _isSavingNotifier.value = true;

    try {
      await AppDatabase.instance.userProfileDao.createOrUpdateProfile(
        UserProfilesCompanion(
          fullName: drift.Value(_nameController.text.trim()),
          handle: drift.Value(_handleController.text.trim()),
          avatarPath: drift.Value(_avatarPathNotifier.value),
          archetype: drift.Value(_selectedArchetypeNotifier.value),
          bio: drift.Value(
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
          ),
          unitSystem: drift.Value(_unitSystemNotifier.value),
          autoExifGpsEnabled: drift.Value(_autoExifGpsEnabledNotifier.value),
          vaultPath: drift.Value(_vaultPath),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      if (mounted) {
        WaymarkSnackbar.showSuccess(
          context,
          context.l10n.profileSaveSuccessToast,
        );
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  bool _doesFileExist(String? path) {
    if (path == null || path.isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;

    return StreamBuilder<UserProfile?>(
      stream: db.userProfileDao.watchProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile != null && !_isInitialized) {
          _populateFromProfile(profile);
        }

        return StreamBuilder<List<TripAlbum>>(
          stream: db.tripAlbumDao.watchAllAlbums(),
          builder: (context, albumsSnapshot) {
            final albums = albumsSnapshot.data ?? [];
            final colors = context.colorScheme;

            return Scaffold(
              backgroundColor: colors.surface,
              extendBodyBehindAppBar: true,
              appBar: WaymarkLiquidGlassAppBar(
                showBrandMasthead: true,
                sectionName: context.l10n.navProfile,
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: ScrollConfiguration(
                  behavior: const WaymarkNoOverscrollScrollBehavior(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(
                      left: WaymarkSpacing.margin(context),
                      right: WaymarkSpacing.margin(context),
                      top: MediaQuery.paddingOf(context).top + 70.h,
                      bottom: WaymarkSpacing.margin(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Title & Dossier Status
                        Text(
                          context.l10n.travelerProfileTitle,
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

                        // Avatar with edit photo button
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

                        // Exact Onboarding Step 2 Form Design
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

                        SizedBox(height: WaymarkSpacing.spaceMd),

                        // Save Profile Changes Button
                        SizedBox(
                          width: double.infinity,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isSavingNotifier,
                            builder: (context, isSaving, _) {
                              return WaymarkPrimaryButton(
                                label: context.l10n.profileBtnSaveChanges,
                                icon: Icons.save_rounded,
                                isLoading: isSaving,
                                onPressed: _saveProfile,
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Travel Albums List Section
                        _buildTravelAlbumsSection(context, albums),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTravelAlbumsSection(
    BuildContext context,
    List<TripAlbum> albums,
  ) {
    final colors = context.colorScheme;
    // final totalKm = albums.fold<double>(0.0, (acc, a) => acc + a.totalDistanceKm);
    // final totalPlaces = albums.fold<int>(0, (acc, a) => acc + a.totalPlacesCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.profileTravelAlbumsSectionTitle,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    context.l10n.profileTravelAlbumsSubtitle,
                    style: context.textTheme.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Text(
                context.l10n.profileMemoirsCount(albums.length),
                style: context.textTheme.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        if (albums.isEmpty) ...[
          WaymarkArtisticEmptyState(
            isCompact: true,
            icon: Icons.auto_stories_rounded,
            badgeText: context.l10n.profileTravelAlbumsEmptyBadge,
            title: context.l10n.profileTravelAlbumsEmpty,
            description: context.l10n.profileTravelAlbumsEmptyDesc,
            buttonLabel: context.l10n.profileStartFirstJourney,
            onButtonPressed: () => CreateJourneyBottomSheet.show(context),
          ),
        ] else ...[
          // List of User Albums
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: albums.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final album = albums[index];
              return _buildAlbumCard(context, album);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAlbumCard(BuildContext context, TripAlbum album) {
    final colors = context.colorScheme;
    final startFmt = DateFormat('MMM d, yyyy').format(album.startDate);
    final isOngoing = album.status == 'ONGOING';

    return Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
      elevation: 1,
      shadowColor: const Color(0x0D1F2421),
      child: InkWell(
        onTap: () => context.push('${AppRoutes.journeys}/${album.id}'),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
                child: SizedBox(
                  width: 64.w,
                  height: 64.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_doesFileExist(album.coverImagePath))
                        Image.file(
                          File(album.coverImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Assets
                              .images
                              .placeTwelve
                              .image(fit: BoxFit.cover),
                        )
                      else
                        Assets.images.placeTwelve.image(fit: BoxFit.cover),
                      Container(
                        color: isOngoing
                            ? colors.forestVivid.withValues(alpha: 0.1)
                            : colors.primary.withValues(alpha: 0.08),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Title and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isOngoing
                                ? colors.secondaryContainer
                                : colors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            isOngoing
                                ? context.l10n.journeyStatusOngoing
                                      .toUpperCase()
                                : context.l10n.journeyStatusCompleted
                                      .toUpperCase(),
                            style: context.textTheme.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isOngoing
                                  ? colors.onSecondaryContainer
                                  : colors.secondary,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        Text(
                          startFmt,
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 13.sp,
                          color: colors.textSecondary,
                        ),
                        Text(
                          '${album.totalDistanceKm.toStringAsFixed(1)} km',
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        Text(
                          '•',
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.place_rounded,
                          size: 13.sp,
                          color: colors.textSecondary,
                        ),
                        Text(
                          context.l10n.profileStopsCount(
                            album.totalPlacesCount,
                          ),
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: colors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
