import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/widgets/traveler_archetype_selector.dart';

class TravelerFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController handleController;
  final TextEditingController bioController;
  final String selectedArchetype;
  final ValueChanged<String> onSelectArchetype;

  const TravelerFormFields({
    super.key,
    required this.nameController,
    required this.handleController,
    required this.bioController,
    required this.selectedArchetype,
    required this.onSelectArchetype,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
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
          // Traveler Full Name
          Text(
            context.l10n.profileFullNameLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: nameController,
            builder: (context, value, _) {
              final fieldColors = context.colorScheme;
              final hasContent = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: fieldColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 20.sp,
                      color: fieldColors.outline,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TextField(
                          controller: nameController,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: fieldColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: context.l10n.profileFullNamePlaceholder,
                            hintStyle: context.textTheme.bodyMedium?.copyWith(
                              color: fieldColors.outline,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasContent)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w, right: 2.w),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 18.sp,
                          color: fieldColors.secondary,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: WaymarkSpacing.spaceSm),

          // Email Address
          Text(
            context.l10n.profileHandleLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: handleController,
            builder: (context, value, _) {
              final fieldColors = context.colorScheme;
              return Container(
                decoration: BoxDecoration(
                  color: fieldColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.alternate_email_rounded,
                      size: 20.sp,
                      color: fieldColors.outline,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TextField(
                          controller: handleController,
                          keyboardType: TextInputType.emailAddress,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: fieldColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: context.l10n.profileHandlePlaceholder,
                            hintStyle: context.textTheme.bodyMedium?.copyWith(
                              color: fieldColors.outline,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: WaymarkSpacing.spaceMd),

          // Traveler Archetype Chips
          TravelerArchetypeSelector(
            selectedArchetype: selectedArchetype,
            onSelectArchetype: onSelectArchetype,
          ),

          SizedBox(height: WaymarkSpacing.spaceMd),

          // Traveler Bio / Philosophy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.l10n.profileBioLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                context.l10n.profileBioFieldNote,
                style: context.textTheme.caption.copyWith(
                  color: colors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.all(12.w),
            child: TextField(
              controller: bioController,
              maxLines: 3,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),

              decoration: InputDecoration(
                hintText: context.l10n.profileBioPlaceholder,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.outline,
                  fontStyle: FontStyle.italic,
                ),

                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
