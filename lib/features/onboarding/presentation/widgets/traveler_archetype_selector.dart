import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class ArchetypeOption {
  final String id;
  final IconData icon;
  final String title;
  final String description;

  const ArchetypeOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
}

class TravelerArchetypeSelector extends StatelessWidget {
  final String selectedArchetype;
  final ValueChanged<String> onSelectArchetype;

  const TravelerArchetypeSelector({
    super.key,
    required this.selectedArchetype,
    required this.onSelectArchetype,
  });

  static const List<ArchetypeOption> options = [
    ArchetypeOption(
      id: 'Casual Explorer',
      icon: Icons.explore_outlined,
      title: 'Casual Explorer',
      description: 'Relaxed sightseeing, hidden gems & easygoing day trips.',
    ),
    ArchetypeOption(
      id: 'Weekend Getaway',
      icon: Icons.weekend_outlined,
      title: 'Weekend Getaway',
      description: 'Quick city breaks, mini road trips & spontaneous escapes.',
    ),
    ArchetypeOption(
      id: 'City Walker',
      icon: Icons.location_city_outlined,
      title: 'City Walker',
      description:
          'Historic streets, neighborhood cafes, museums & architecture.',
    ),
    ArchetypeOption(
      id: 'Nature Hiker',
      icon: Icons.terrain_outlined,
      title: 'Nature Hiker',
      description: 'Mountain trails, national parks, scenic peaks & summits.',
    ),
    ArchetypeOption(
      id: 'Road Tripper',
      icon: Icons.directions_car_outlined,
      title: 'Road Tripper',
      description:
          'Scenic highways, playlists, scenic overlooks & open horizons.',
    ),
    ArchetypeOption(
      id: 'Backpacker',
      icon: Icons.backpack_outlined,
      title: 'Backpacker',
      description: 'Spontaneous trails, budget adventures & traveling light.',
    ),
    ArchetypeOption(
      id: 'Food & Culture',
      icon: Icons.restaurant_outlined,
      title: 'Food & Culture',
      description:
          'Local culinary discoveries, farmers markets & cultural stories.',
    ),
    ArchetypeOption(
      id: 'Photographer',
      icon: Icons.photo_camera_outlined,
      title: 'Photographer',
      description:
          'Chasing golden hours, scenic viewpoints & visual postcards.',
    ),
    ArchetypeOption(
      id: 'Beach & Coastal',
      icon: Icons.beach_access_outlined,
      title: 'Beach & Coastal',
      description: 'Seaside strolls, ocean breeze, sunsets & coastal retreats.',
    ),
    ArchetypeOption(
      id: 'Slow Traveler',
      icon: Icons.coffee_outlined,
      title: 'Slow Traveler',
      description: 'Staying longer, living like a local & unhurried days.',
    ),
  ];

  ArchetypeOption get _currentSelection {
    return options.firstWhere(
      (opt) =>
          opt.id.toLowerCase() == selectedArchetype.toLowerCase() ||
          (selectedArchetype == 'Wayfarer' && opt.id == 'Casual Explorer') ||
          (selectedArchetype == 'Urban Flâneur' && opt.id == 'City Walker') ||
          (selectedArchetype == 'Alpinist' && opt.id == 'Nature Hiker') ||
          (selectedArchetype == 'Cyclotourist' && opt.id == 'Road Tripper'),
      orElse: () => options.first,
    );
  }

  void _showArchetypeBottomSheet(BuildContext context) {
    final colors = context.colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (modalContext) {
        final modalColors = modalContext.colorScheme;
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modalContext.l10n.archetypeModalTitle,
                        style: modalContext.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: modalColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        modalContext.l10n.archetypeModalSubtitle,
                        style: modalContext.textTheme.bodySmall?.copyWith(
                          color: modalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: modalColors.borderDivider, height: 1.h),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    itemCount: options.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final itemColors = context.colorScheme;
                      final option = options[index];
                      final isSelected = _currentSelection.id == option.id;

                      return InkWell(
                        onTap: () {
                          onSelectArchetype(option.id);
                          Navigator.pop(modalContext);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? itemColors.primary.withValues(alpha: 0.08)
                                : itemColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? itemColors.primary
                                  : itemColors.borderDivider.withValues(
                                      alpha: 0.5,
                                    ),
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? itemColors.primary
                                      : itemColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : itemColors.primary,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.title,
                                      style: context.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? itemColors.primary
                                                : itemColors.textPrimary,
                                          ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      option.description,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 12.sp,
                                            color: itemColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: itemColors.primary,
                                  size: 22.sp,
                                ),
                            ],
                          ),
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final current = _currentSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.profileArchetypeLabel,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () => _showArchetypeBottomSheet(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.borderDivider, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(current.icon, size: 20.sp, color: colors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        current.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: colors.borderDivider, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.archetypeBtnChange,
                        style: context.textTheme.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14.sp,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
