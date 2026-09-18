import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class AvatarPreset {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;

  const AvatarPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
  });
}

class TravelerAvatarPicker extends StatelessWidget {
  final String? avatarPath;
  final VoidCallback onPickAvatar;

  const TravelerAvatarPicker({
    super.key,
    this.avatarPath,
    required this.onPickAvatar,
  });

  static const List<AvatarPreset> presets = [
    AvatarPreset(
      id: 'avatar:explorer',
      name: 'Explorer',
      icon: Icons.explore_rounded,
      gradientColors: [Color(0xFFE26D5C), Color(0xFFF9844A)],
    ),
    AvatarPreset(
      id: 'avatar:hiker',
      name: 'Hiker',
      icon: Icons.hiking_rounded,
      gradientColors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
    ),
    AvatarPreset(
      id: 'avatar:shutterbug',
      name: 'Photographer',
      icon: Icons.camera_alt_rounded,
      gradientColors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    ),
    AvatarPreset(
      id: 'avatar:stroller',
      name: 'City Walker',
      icon: Icons.directions_walk_rounded,
      gradientColors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
    AvatarPreset(
      id: 'avatar:road_trip',
      name: 'Road Tripper',
      icon: Icons.directions_car_filled_rounded,
      gradientColors: [Color(0xFFD90429), Color(0xFFEF233C)],
    ),
    AvatarPreset(
      id: 'avatar:voyager',
      name: 'Voyager',
      icon: Icons.flight_takeoff_rounded,
      gradientColors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
    ),
    AvatarPreset(
      id: 'avatar:camper',
      name: 'Camper',
      icon: Icons.cabin_rounded,
      gradientColors: [Color(0xFF6B705C), Color(0xFFA5A58D)],
    ),
    AvatarPreset(
      id: 'avatar:coastal',
      name: 'Coastal',
      icon: Icons.waves_rounded,
      gradientColors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    ),
  ];

  static AvatarPreset getPreset(String id) {
    return presets.firstWhere((p) => p.id == id, orElse: () => presets.first);
  }

  bool _doesFileExist(String? path) {
    if (path == null || path.isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  Widget _buildDefaultAvatar() {
    final defaultPreset = presets.first;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: defaultPreset.gradientColors,
        ),
      ),
      child: Center(
        child: Icon(defaultPreset.icon, color: Colors.white, size: 44.sp),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (avatarPath != null && avatarPath!.startsWith('avatar:')) {
      final preset = getPreset(avatarPath!);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: preset.gradientColors,
          ),
        ),
        child: Center(
          child: Icon(preset.icon, color: Colors.white, size: 44.sp),
        ),
      );
    }

    if (_doesFileExist(avatarPath)) {
      return Image.file(
        File(avatarPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    if (avatarPath != null && avatarPath!.startsWith('assets/')) {
      return Image.asset(
        avatarPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar circle with camera edit badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onPickAvatar,
              child: Container(
                width: 96.w,
                height: 96.w,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceCard,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x181F2421), // rgba(31,36,33,0.1)
                      blurRadius: 16.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                  border: Border.all(color: colors.borderDivider, width: 1.5),
                ),
                child: ClipOval(child: _buildAvatarContent()),
              ),
            ),

            // Camera FAB
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPickAvatar,
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
                          blurRadius: 6.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: WaymarkSpacing.spaceSm),

        // Badges: "Offline First" & "100% Private"
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.w,
          runSpacing: 6.h,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 13.sp,
                    color: colors.secondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    context.l10n.profileOfflineFirst,
                    style: context.textTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
                border: Border.all(color: colors.borderDivider, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 13.sp,
                    color: colors.forestVivid,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    context.l10n.profilePrivateBadge,
                    style: context.textTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
