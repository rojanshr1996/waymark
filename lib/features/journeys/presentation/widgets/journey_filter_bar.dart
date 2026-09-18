import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

enum JourneyFilter { all, ongoing, completed, favorites }

class JourneyFilterBar extends StatelessWidget {
  final JourneyFilter selectedFilter;
  final ValueChanged<JourneyFilter> onFilterChanged;
  final int allCount;
  final int ongoingCount;
  final int completedCount;
  final int favoritesCount;

  const JourneyFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.allCount = 0,
    this.ongoingCount = 0,
    this.completedCount = 0,
    this.favoritesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context: context,
            filter: JourneyFilter.all,
            label: context.l10n.filterAll,
            count: allCount,
          ),
          SizedBox(width: 8.w),
          _buildChip(
            context: context,
            filter: JourneyFilter.ongoing,
            label: context.l10n.filterOngoing,
            count: ongoingCount,
            countColor: const Color(0xFF286A46),
            countBgColor: const Color(0xFFADF2C3),
          ),
          SizedBox(width: 8.w),
          _buildChip(
            context: context,
            filter: JourneyFilter.completed,
            label: context.l10n.filterCompleted,
            count: completedCount,
          ),
          SizedBox(width: 8.w),
          _buildChip(
            context: context,
            filter: JourneyFilter.favorites,
            label: context.l10n.filterFavorites,
            icon: Icons.bookmark_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required JourneyFilter filter,
    required String label,
    int? count,
    IconData? icon,
    Color? countColor,
    Color? countBgColor,
  }) {
    final isSelected = selectedFilter == filter;
    final colors = context.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFilterChanged(filter),
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceContainer,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14.sp,
                  color: isSelected ? Colors.white : colors.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : colors.onSurfaceVariant,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : (countBgColor ?? colors.surfaceContainerHighest),
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: context.textTheme.caption.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (countColor ?? colors.onSurface),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
