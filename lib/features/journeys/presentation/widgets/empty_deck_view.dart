import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

class EmptyDeckView extends StatelessWidget {
  final UserProfile? profile;
  final VoidCallback? onStartJourney;

  const EmptyDeckView({super.key, this.profile, this.onStartJourney});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final rawName = profile?.fullName.trim() ?? '';
    final travelerName = rawName.isNotEmpty
        ? rawName.split(RegExp(r'\s+')).first
        : 'Traveler';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Dossier & Offline Status Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${context.l10n.journeysTravelerDossier.toUpperCase()} • ${context.l10n.journeysCleanSlateDossier}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.secondary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFADF2C3).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.offline_pin_rounded,
                    size: 13.sp,
                    color: const Color(0xFF2F704B),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    context.l10n.journeysOfflineReady.toUpperCase(),
                    style: context.textTheme.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F704B),
                      fontSize: 9.5.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        // Welcome Headline (compact first-name only)
        Text(
          context.l10n.journeysWelcome(travelerName),
          style: context.textTheme.headlineLarge?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: colors.textPrimary,
          ),
        ),

        SizedBox(height: 14.h),

        // Artistic Animated Empty State Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusLg),
            border: Border.all(color: colors.borderDivider, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0C1F2421),
                blurRadius: 14.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: WaymarkArtisticEmptyState(
            icon: Icons.explore_rounded,
            badgeText: context.l10n.emptyDeckBadge,
            title: context.l10n.emptyDeckJourneyAwaitsTitle,
            description: context.l10n.emptyDeckJourneyAwaitsDesc,
            buttonLabel: context.l10n.emptyDeckBtnStart,
            buttonIcon: Icons.add_location_alt_rounded,
            onButtonPressed: onStartJourney,
          ),
        ),

        SizedBox(height: 18.h),

        // Step-by-Step Recording Guide Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(WaymarkSpacing.spaceMd),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(WaymarkSpacing.radiusLg),
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
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 20.sp,
                      color: colors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.emptyDeckHowItWorksTitle,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          context.l10n.emptyDeckHowItWorksSubtitle,
                          style: context.textTheme.caption.copyWith(
                            color: colors.secondary,
                            fontWeight: FontWeight.w600,
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

              // Step 1: Snap / Batch import
              _buildStepItem(
                context: context,
                icon: Icons.add_a_photo_outlined,
                title: context.l10n.emptyDeckStep1Title,
                badge: context.l10n.emptyDeckStep1Badge,
                description: context.l10n.emptyDeckStep1Desc,
              ),

              SizedBox(height: 14.h),

              // Step 2: Continuous Vector Trails
              _buildStepItem(
                context: context,
                icon: Icons.timeline_rounded,
                title: context.l10n.emptyDeckStep2Title,
                badge: context.l10n.emptyDeckStep2Badge,
                description: context.l10n.emptyDeckStep2Desc,
              ),

              SizedBox(height: 14.h),

              // Step 3: Tactile Postcards
              _buildStepItem(
                context: context,
                icon: Icons.markunread_mailbox_outlined,
                title: context.l10n.emptyDeckStep3Title,
                badge: context.l10n.emptyDeckStep3Badge,
                description: context.l10n.emptyDeckStep3Desc,
              ),

              SizedBox(height: 16.h),
              Divider(color: colors.borderDivider, height: 1),
              SizedBox(height: 12.h),

              // Security & Zero-Cloud Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 13.sp,
                    color: colors.secondary,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      context.l10n.emptyDeckSecurityFooter,
                      textAlign: TextAlign.center,
                      style: context.textTheme.caption.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String badge,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      badge.toUpperCase(),
                      style: context.textTheme.caption.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                description,
                style: context.textTheme.caption.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
