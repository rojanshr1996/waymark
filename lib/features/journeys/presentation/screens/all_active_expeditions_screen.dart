import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/active_journey_hero_card.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';

class AllActiveExpeditionsScreen extends StatelessWidget {
  const AllActiveExpeditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    final colors = context.colorScheme;

    return StreamBuilder<List<TripAlbum>>(
      stream: db.tripAlbumDao.watchAllAlbums(),
      builder: (context, snapshot) {
        final albums = snapshot.data ?? [];
        final ongoingAlbums = albums
            .where((a) => a.status == 'ONGOING')
            .toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: WaymarkLiquidGlassAppBar(
            title: 'Active Expeditions',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            ),
            actions: [
              if (ongoingAlbums.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.forestVivid.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          WaymarkSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: colors.forestVivid.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: colors.forestVivid,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '${ongoingAlbums.length} ACTIVE',
                            style: context.textTheme.caption.copyWith(
                              color: colors.forestVivid,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: ScrollConfiguration(
            behavior: const WaymarkNoOverscrollScrollBehavior(),
            child: ongoingAlbums.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: WaymarkArtisticEmptyState(
                        icon: Icons.hiking_rounded,
                        badgeText: context.l10n.journeysExpeditionStatusBadge,
                        title: context.l10n.emptyOngoingTitle,
                        description: context.l10n.emptyOngoingDesc,
                        buttonLabel: context.l10n.journeysStartNewJourney,
                        onButtonPressed: () =>
                            CreateJourneyBottomSheet.show(context),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(
                      left: WaymarkSpacing.margin(context),
                      right: WaymarkSpacing.margin(context),
                      top: MediaQuery.paddingOf(context).top + 70.h,
                      bottom: MediaQuery.paddingOf(context).bottom + 30.h,
                    ),
                    itemCount: ongoingAlbums.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final album = ongoingAlbums[index];
                      return ActiveJourneyHeroCard(
                        album: album,
                        showHeader: false,
                        onContinue: () =>
                            context.push('${AppRoutes.journeys}/${album.id}'),
                        onAddWaypoint: () => PlaceLoggerBottomSheet.show(
                          context,
                          albumId: album.id,
                          albumTitle: album.title,
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
