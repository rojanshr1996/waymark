import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_animated_entrance.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';

class PostcardStudioScreen extends StatelessWidget {
  const PostcardStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    final colors = context.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: WaymarkLiquidGlassAppBar(
        showBrandMasthead: true,
        sectionName: context.l10n.navStudio,
      ),
      body: StreamBuilder<List<TripAlbum>>(
        stream: db.tripAlbumDao.watchAllAlbums(),
        builder: (context, albumSnapshot) {
          final albums = albumSnapshot.data ?? [];
          if (albumSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<TripPlace>>(
            stream: db.tripPlaceDao.watchRecentPlaces(limit: 50),
            builder: (context, placeSnapshot) {
              final places = placeSnapshot.data ?? [];
              if (placeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (places.isEmpty || albums.isEmpty) {
                return Center(
                  child: WaymarkAnimatedEntrance(
                    child: WaymarkArtisticEmptyState(
                      badgeText: context.l10n.studioBadgeClosed,
                      icon: Icons.camera_alt_rounded,
                      title: context.l10n.studioNoMemoriesTitle,
                      description: context.l10n.studioNoMemoriesDesc,
                      buttonLabel: context.l10n.emptyExploreBtn,
                      onButtonPressed: () =>
                          CreateJourneyBottomSheet.show(context),
                    ),
                  ),
                );
              }

              return ScrollConfiguration(
                behavior: const WaymarkNoOverscrollScrollBehavior(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 70.h,
                    bottom: WaymarkSpacing.margin(context),
                    left: WaymarkSpacing.margin(context),
                    right: WaymarkSpacing.margin(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WaymarkAnimatedEntrance(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                context.l10n.studioBadgeAtelier,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              context.l10n.studioMemoryPrintsTitle,
                              style: context.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              context.l10n.studioMemoryPrintsSubtitle,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      WaymarkAnimatedEntrance(
                        delay: const Duration(milliseconds: 80),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusMd,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: colors.primary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  context.l10n.studioBannerNotice,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      WaymarkAnimatedEntrance(
                        delay: const Duration(milliseconds: 160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.l10n.studioSectionMemories,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(color: colors.textSecondary),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '${places.length}',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(color: colors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.w,
                                    mainAxisSpacing: 10.h,
                                    childAspectRatio: 0.78,
                                  ),
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                return _PostcardPreviewCard(
                                  place: places[index],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      WaymarkAnimatedEntrance(
                        delay: const Duration(milliseconds: 240),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: colors.borderDivider),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: colors.secondary,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.studioGeneratorTitle,
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      context.l10n.studioGeneratorDesc,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostcardPreviewCard extends StatelessWidget {
  final TripPlace place;

  const _PostcardPreviewCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Material(
      color: colors.surfaceCard,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => WaymarkSnackbar.showInfo(
          context,
          context.l10n.studioComingSoonToast(place.name),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.8),
                      colors.secondary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: context.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('MMM d, yyyy').format(place.visitedAt),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      context.l10n.studioBtnCreatePostcard,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
