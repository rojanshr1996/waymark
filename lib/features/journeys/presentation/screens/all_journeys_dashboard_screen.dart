import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/screens/waymark_navigation_shell.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_buttons.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/active_journey_hero_card.dart';
import 'package:waymark/features/journeys/presentation/widgets/archived_memoirs_section.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/empty_deck_view.dart';
import 'package:waymark/features/journeys/presentation/widgets/export_field_journal_banner.dart';
import 'package:waymark/features/journeys/presentation/widgets/journey_filter_bar.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/recent_discoveries_carousel.dart';

class AllJourneysDashboardScreen extends StatefulWidget {
  const AllJourneysDashboardScreen({super.key});

  @override
  State<AllJourneysDashboardScreen> createState() =>
      _AllJourneysDashboardScreenState();
}

class _AllJourneysDashboardScreenState
    extends State<AllJourneysDashboardScreen> {
  final ValueNotifier<JourneyFilter> _selectedFilterNotifier =
      ValueNotifier<JourneyFilter>(JourneyFilter.all);
  final ValueNotifier<int> _currentExpeditionIndexNotifier = ValueNotifier<int>(
    0,
  );
  late final PageController _expeditionsPageController;

  @override
  void initState() {
    super.initState();
    _expeditionsPageController = PageController();
  }

  @override
  void dispose() {
    _selectedFilterNotifier.dispose();
    _currentExpeditionIndexNotifier.dispose();
    _expeditionsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;

    return StreamBuilder<UserProfile?>(
      stream: db.userProfileDao.watchProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;

        return StreamBuilder<List<TripAlbum>>(
          stream: db.tripAlbumDao.watchAllAlbums(),
          builder: (context, albumsSnapshot) {
            final albums = albumsSnapshot.data ?? [];

            return StreamBuilder<List<TripPlace>>(
              stream: db.tripPlaceDao.watchRecentPlaces(),
              builder: (context, placesSnapshot) {
                final places = placesSnapshot.data ?? [];
                final placeIds = places.map((p) => p.id).toList();

                return StreamBuilder<List<PlaceMediaFile>>(
                  stream: db.placeMediaDao.watchMediaForPlaces(placeIds),
                  builder: (context, mediaSnapshot) {
                    final mediaList = mediaSnapshot.data ?? [];
                    final placeCoverMap = <String, String>{};
                    for (final m in mediaList) {
                      if (m.isCoverPhoto ||
                          !placeCoverMap.containsKey(m.placeId)) {
                        placeCoverMap[m.placeId] = m.localFilePath;
                      }
                    }

                    final colors = context.colorScheme;

                    return Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: WaymarkLiquidGlassAppBar(
                        showBrandMasthead: true,
                        sectionName: context.l10n.navJourneys,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded),
                            color: colors.onSurfaceVariant,
                            onPressed: () {
                              WaymarkSnackbar.showInfo(
                                context,
                                context.l10n.notificationsPrivateToast,
                              );
                            },
                          ),
                          // Settings Navigation Icon
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            color: colors.onSurfaceVariant,
                            tooltip: context.l10n.settingsTitle,
                            onPressed: () => context.push(AppRoutes.settings),
                          ),
                        ],
                      ),
                      body: ScrollConfiguration(
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
                          child: albums.isEmpty
                              ? EmptyDeckView(
                                  profile: profile,
                                  onStartJourney: () =>
                                      CreateJourneyBottomSheet.show(context),
                                )
                              : _buildDeckContent(
                                  context: context,
                                  profile: profile,
                                  albums: albums,
                                  places: places,
                                  placeCoverMap: placeCoverMap,
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDeckContent({
    required BuildContext context,
    required UserProfile? profile,
    required List<TripAlbum> albums,
    required List<TripPlace> places,
    Map<String, String>? placeCoverMap,
  }) {
    final rawName = profile?.fullName.trim() ?? '';
    final travelerName = rawName.isNotEmpty
        ? rawName.split(RegExp(r'\s+')).first
        : 'Traveler';
    final ongoingAlbums = albums.where((a) => a.status == 'ONGOING').toList();
    final displayedExpeditions = ongoingAlbums.take(5).toList();
    final completedAlbums = albums
        .where((a) => a.status == 'COMPLETED')
        .toList();

    final totalKm = albums.fold<double>(
      0.0,
      (acc, a) => acc + a.totalDistanceKm,
    );

    // Active featured expedition (first ongoing or latest)
    final activeAlbum = ongoingAlbums.isNotEmpty ? ongoingAlbums.first : null;

    final colors = context.colorScheme;

    return ValueListenableBuilder<JourneyFilter>(
      valueListenable: _selectedFilterNotifier,
      builder: (context, selectedFilter, _) {
        final List<TripAlbum> displayedAlbums;
        final String listTitle;
        switch (selectedFilter) {
          case JourneyFilter.all:
            displayedAlbums = albums;
            listTitle = 'Journey Albums';
            break;
          case JourneyFilter.ongoing:
            displayedAlbums = ongoingAlbums;
            listTitle = 'Ongoing Expeditions';
            break;
          case JourneyFilter.completed:
            displayedAlbums = completedAlbums;
            listTitle = context.l10n.journeysArchivedMemoirs;
            break;
          case JourneyFilter.favorites:
            displayedAlbums = const [];
            listTitle = 'Favorite Memoirs';
            break;
        }

        final showOngoingSection =
            selectedFilter == JourneyFilter.all ||
            selectedFilter == JourneyFilter.ongoing;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Greeting Header & Live Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFADF2C3).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF007A3D),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    context.l10n.journeysOfflineReady,
                    style: context.textTheme.caption.copyWith(
                      color: const Color(0xFF005228),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 6.h),

            // Welcome Headline (compact first-name only)
            Text(
              context.l10n.journeysWelcomeBack(travelerName),
              style: context.textTheme.headlineLarge?.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    context.l10n.journeysMetricsSummary(
                      albums.length,
                      totalKm.toStringAsFixed(1),
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Filter Chips Segmented Control
            JourneyFilterBar(
              selectedFilter: selectedFilter,
              allCount: albums.length,
              ongoingCount: ongoingAlbums.length,
              completedCount: completedAlbums.length,
              onFilterChanged: (filter) {
                _selectedFilterNotifier.value = filter;
              },
            ),

            SizedBox(height: 16.h),

            // Active Expedition Cards (horizontal carousel with dot indicator, max 5, view all button)
            if (showOngoingSection) ...[
              if (ongoingAlbums.isNotEmpty) ...[
                // Section Header with Title, Live GPS badge, and "View all"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (ongoingAlbums.length > 1
                                ? '${context.l10n.journeysActiveExpedition}s (${ongoingAlbums.length})'
                                : context.l10n.journeysActiveExpedition)
                            .toUpperCase(),
                        style: context.textTheme.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: colors.forestVivid,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          context.l10n.journeysGpsTrackingActive,
                          style: context.textTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.secondary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: () =>
                              context.push(AppRoutes.activeExpeditions),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View all',
                                style: context.textTheme.caption.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5.sp,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10.sp,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Horizontal Carousel of Active Expeditions (up to 5)
                SizedBox(
                  height: 335.h,
                  child: PageView.builder(
                    controller: _expeditionsPageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayedExpeditions.length,
                    onPageChanged: (index) {
                      _currentExpeditionIndexNotifier.value = index;
                    },
                    itemBuilder: (context, index) {
                      final album = displayedExpeditions[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ActiveJourneyHeroCard(
                          album: album,
                          showHeader: false,
                          isFlexible: true,
                          onContinue: () {
                            context.push('${AppRoutes.journeys}/${album.id}');
                          },
                          onAddWaypoint: () => PlaceLoggerBottomSheet.show(
                            context,
                            albumId: album.id,
                            albumTitle: album.title,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Dot Indicator
                if (displayedExpeditions.length > 1) ...[
                  SizedBox(height: 3.h),
                  ValueListenableBuilder<int>(
                    valueListenable: _currentExpeditionIndexNotifier,
                    builder: (context, currentExpeditionIndex, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(displayedExpeditions.length, (
                          idx,
                        ) {
                          final isSelected =
                              idx ==
                              currentExpeditionIndex.clamp(
                                0,
                                displayedExpeditions.length - 1,
                              );
                          return GestureDetector(
                            onTap: () {
                              _expeditionsPageController.animateToPage(
                                idx,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: isSelected ? 18.w : 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : colors.borderDivider.withValues(
                                        alpha: 0.6,
                                      ),
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
                SizedBox(height: 14.h),
              ] else if (selectedFilter == JourneyFilter.ongoing) ...[
                WaymarkArtisticEmptyState(
                  isCompact: true,
                  icon: Icons.hiking_rounded,
                  badgeText: context.l10n.journeysExpeditionStatusBadge,
                  title: context.l10n.emptyOngoingTitle,
                  description: context.l10n.emptyOngoingDesc,
                ),
                SizedBox(height: 18.h),
              ],
            ],

            // Recent Discoveries Carousel
            if (places.isNotEmpty) ...[
              RecentDiscoveriesCarousel(
                places: places,
                placeCoverMap: placeCoverMap,
                onSeeMap: () {
                  final nav = WaymarkNavigationScope.of(context);
                  if (nav != null) {
                    nav.switchToTab(1);
                  } else {
                    context.go(AppRoutes.explore);
                  }
                },
                onPlaceTap: (place) {
                  PlaceLoggerBottomSheet.show(
                    context,
                    albumId: place.albumId,
                    albumTitle: activeAlbum?.title,
                    placeToEdit: place,
                  );
                },
              ),
              SizedBox(height: 18.h),
            ],

            // Journey Albums / Memoirs Section
            if (displayedAlbums.isNotEmpty) ...[
              ArchivedMemoirsSection(
                albums: displayedAlbums,
                title: listTitle,
                onAlbumTap: (album) {
                  context.push('${AppRoutes.journeys}/${album.id}');
                },
                onAlbumEdit: (album) {
                  CreateJourneyBottomSheet.show(context, albumToEdit: album);
                },
              ),
              SizedBox(height: 10.h),
            ],

            // Export as Field Journal Banner
            ExportFieldJournalBanner(
              onPreview: () =>
                  _showExportFieldJournalModal(context, albums, places),
            ),

            SizedBox(height: 18.h),

            // Bottom CTA: + Start New Journey
            SizedBox(
              width: double.infinity,
              child: WaymarkPrimaryButton(
                label: context.l10n.journeysStartNewJourney,
                icon: Icons.add_circle_outline_rounded,
                onPressed: () => CreateJourneyBottomSheet.show(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExportFieldJournalModal(
    BuildContext context,
    List<TripAlbum> albums,
    List<TripPlace> places,
  ) {
    final colors = context.colorScheme;
    final totalKm = albums.fold<double>(
      0.0,
      (acc, a) => acc + a.totalDistanceKm,
    );

    final sb = StringBuffer();
    sb.writeln('====================================');
    sb.writeln('     WAYMARK EXPEDITION FIELD JOURNAL');
    sb.writeln('====================================\n');
    sb.writeln(
      'Date of Export: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    sb.writeln('Total Expeditions: ${albums.length}');
    sb.writeln('Total Distance Recorded: ${totalKm.toStringAsFixed(1)} km');
    sb.writeln('Total Waypoints: ${places.length}\n');

    sb.writeln('--- JOURNEYS ---');
    for (final album in albums) {
      final start = DateFormat('MMM d, yyyy').format(album.startDate);
      final end = album.endDate != null
          ? ' - ${DateFormat('MMM d, yyyy').format(album.endDate!)}'
          : ' (Ongoing)';
      sb.writeln('• ${album.title} [$start$end]');
      if (album.description != null && album.description!.isNotEmpty) {
        sb.writeln('  Description: ${album.description}');
      }
      sb.writeln(
        '  Distance: ${album.totalDistanceKm.toStringAsFixed(1)} km | Stops: ${album.totalPlacesCount}',
      );
      sb.writeln('');
    }

    if (places.isNotEmpty) {
      sb.writeln('--- RECENT DISCOVERIES & WAYPOINTS ---');
      for (final place in places) {
        final visitTime = DateFormat(
          'MMM d, yyyy HH:mm',
        ).format(place.visitedAt);
        sb.writeln('#${place.visitOrder} ${place.name} (${place.category})');
        sb.writeln('  Visited: $visitTime');
        if (place.locationAddress != null &&
            place.locationAddress!.isNotEmpty) {
          sb.writeln('  Location: ${place.locationAddress}');
        }
        sb.writeln(
          '  Coordinates: (${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)})',
        );
        if (place.notes != null && place.notes!.isNotEmpty) {
          sb.writeln('  Notes: "${place.notes}"');
        }
        if (place.temperatureCelsius != null) {
          sb.writeln(
            '  Weather: ${place.temperatureCelsius!.toInt()}°C, ${place.weatherCondition ?? "Clear"}',
          );
        }
        sb.writeln('');
      }
    }

    final journalContent = sb.toString();

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (modalContext) {
        return Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.paddingOf(modalContext).bottom + 20.h,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(modalContext).height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.borderDivider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title and icon
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDEA9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 20.sp,
                      color: const Color(0xFF5E4100),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Field Journal Export Preview',
                          style: modalContext.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${albums.length} journeys • ${places.length} waypoints recorded',
                          style: modalContext.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Preview Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd,
                    ),
                    border: Border.all(color: colors.borderDivider),
                  ),
                  child: ScrollConfiguration(
                    behavior: const WaymarkNoOverscrollScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SelectableText(
                        journalContent,
                        style: modalContext.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.5,
                          fontSize: 12.sp,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.copy_rounded, size: 18.sp),
                      label: const Text('Copy Text'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: colors.borderDivider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusSm,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: journalContent));
                        Navigator.pop(modalContext);
                        WaymarkSnackbar.showSuccess(
                          context,
                          'Field Journal copied to clipboard!',
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: WaymarkPrimaryButton(
                      label: 'Done',
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
