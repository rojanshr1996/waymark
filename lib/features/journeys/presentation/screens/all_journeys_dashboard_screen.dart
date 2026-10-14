import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:waymark/core/services/location_search_service.dart';
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
  final ValueNotifier<Set<String>> _loadingRouteAlbumIdsNotifier =
      ValueNotifier<Set<String>>({});
  final Map<String, String> _lastCheckedRoutesKey = {};
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
    _loadingRouteAlbumIdsNotifier.dispose();
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
              stream: db.tripPlaceDao.watchAllPlaces(),
              builder: (context, placesSnapshot) {
                final allPlaces = placesSnapshot.data ?? [];
                final recentPlaces = allPlaces.take(10).toList();
                final placeIds = allPlaces.map((p) => p.id).toList();

                // Proactively compute & update road route distances if any album needs it
                _checkAndFetchRoadDistances(albums, allPlaces);

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
                            bottom:
                                MediaQuery.paddingOf(context).bottom + 100.h,
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
                                  places: recentPlaces,
                                  allPlaces: allPlaces,
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
    required List<TripPlace> allPlaces,
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

    // Compute straight-line per-album distances from the loaded places list.
    final albumDistances = _computeAlbumDistances(albums, allPlaces);

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
                      totalKm.toStringAsFixed(2),
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
                        child: ValueListenableBuilder<Set<String>>(
                          valueListenable: _loadingRouteAlbumIdsNotifier,
                          builder: (context, loadingIds, _) {
                            final isDistanceLoading = loadingIds.contains(
                              album.id,
                            );
                            return ActiveJourneyHeroCard(
                              album: album,
                              showHeader: false,
                              isFlexible: true,
                              liveDistanceKm: albumDistances[album.id],
                              isDistanceLoading: isDistanceLoading,
                              onContinue: () {
                                context.push(
                                  '${AppRoutes.journeys}/${album.id}',
                                );
                              },
                              onAddWaypoint: () async {
                                final newPlaceId =
                                    await PlaceLoggerBottomSheet.show(
                                      context,
                                      albumId: album.id,
                                      albumTitle: album.title,
                                    );
                                if (newPlaceId != null && context.mounted) {
                                  context.push(
                                    '${AppRoutes.journeys}/${album.id}?highlightPlaceId=$newPlaceId',
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Dot Indicator
                if (displayedExpeditions.length > 1) ...[
                  SizedBox(height: 12.h),
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
                albumDistances: albumDistances,
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

  /// Proactively fetches road routes for albums whose total distance is 0 or needs updating.
  void _checkAndFetchRoadDistances(
    List<TripAlbum> albums,
    List<TripPlace> allPlaces,
  ) {
    final grouped = <String, List<TripPlace>>{};
    for (final place in allPlaces) {
      grouped.putIfAbsent(place.albumId, () => []).add(place);
    }

    for (final album in albums) {
      final albumPlaces = grouped[album.id] ?? [];
      if (albumPlaces.length < 2) continue;

      final key = albumPlaces
          .map((p) => '${p.id}:${p.latitude},${p.longitude}')
          .join(';');
      if (key == _lastCheckedRoutesKey[album.id]) continue;
      _lastCheckedRoutesKey[album.id] = key;

      // If distance is not yet computed or places changed, fetch road route
      final straightKm = _calculateStraightLineKm(albumPlaces);
      final waypoints = albumPlaces
          .map((p) => (latitude: p.latitude, longitude: p.longitude))
          .toList();

      // Only show shimmer if we don't already have a valid stored distance
      if (album.totalDistanceKm <= 0.05) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadingRouteAlbumIdsNotifier.value = {
              ..._loadingRouteAlbumIdsNotifier.value,
              album.id,
            };
          }
        });
      }

      LocationSearchService.instance
          .fetchRoutePolyline(waypoints)
          .then((result) {
            if (!mounted) return;
            final double resolvedKm;
            if (result != null && result.points.isNotEmpty) {
              resolvedKm = result.distanceKm;
            } else {
              resolvedKm = straightKm;
            }

            if ((album.totalDistanceKm - resolvedKm).abs() >= 0.01) {
              AppDatabase.instance.tripAlbumDao.updateAlbum(
                album.copyWith(totalDistanceKm: resolvedKm),
              );
            }

            final updatedLoading = Set<String>.from(
              _loadingRouteAlbumIdsNotifier.value,
            )..remove(album.id);
            _loadingRouteAlbumIdsNotifier.value = updatedLoading;
          })
          .catchError((_) {
            if (mounted) {
              final updatedLoading = Set<String>.from(
                _loadingRouteAlbumIdsNotifier.value,
              )..remove(album.id);
              _loadingRouteAlbumIdsNotifier.value = updatedLoading;
            }
          });
    }
  }

  double _calculateStraightLineKm(List<TripPlace> places) {
    if (places.length < 2) return 0.0;
    const distCalc = Distance();
    double total = 0.0;
    for (int i = 0; i < places.length - 1; i++) {
      total += distCalc.as(
        LengthUnit.Kilometer,
        LatLng(places[i].latitude, places[i].longitude),
        LatLng(places[i + 1].latitude, places[i + 1].longitude),
      );
    }
    return total;
  }

  /// Computes straight-line total distance (km) for each album from the
  /// provided [places] list, grouped by [TripPlace.albumId].
  /// Falls back to [TripAlbum.totalDistanceKm] when the stored value > 0.
  Map<String, double> _computeAlbumDistances(
    List<TripAlbum> albums,
    List<TripPlace> places,
  ) {
    // Group places by albumId
    final grouped = <String, List<TripPlace>>{};
    for (final place in places) {
      grouped.putIfAbsent(place.albumId, () => []).add(place);
    }

    final result = <String, double>{};

    for (final album in albums) {
      // Prefer the stored DB value if it's already meaningful.
      if (album.totalDistanceKm > 0.05) {
        result[album.id] = album.totalDistanceKm;
        continue;
      }
      final albumPlaces = grouped[album.id] ?? [];
      result[album.id] = _calculateStraightLineKm(albumPlaces);
    }
    return result;
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
    sb.writeln('     WANDERLINE EXPEDITION FIELD JOURNAL');
    sb.writeln('====================================\n');
    sb.writeln(
      'Date of Export: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    sb.writeln('Total Expeditions: ${albums.length}');
    sb.writeln('Total Distance Recorded: ${totalKm.toStringAsFixed(2)} km');
    sb.writeln('Total Places: ${places.length}\n');

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
        '  Distance: ${album.totalDistanceKm.toStringAsFixed(2)} km | Stops: ${album.totalPlacesCount}',
      );
      sb.writeln('');
    }

    if (places.isNotEmpty) {
      sb.writeln('--- RECENT DISCOVERIES & PLACES ---');
      for (final place in places) {
        final visitDate = DateFormat('MMM d, yyyy').format(place.visitedAt);
        sb.writeln('#${place.visitOrder} ${place.name} (${place.category})');
        sb.writeln('  Visited: $visitDate');
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
        return _FieldJournalExportModalContent(
          albums: albums,
          places: places,
          totalKm: totalKm,
          journalContent: journalContent,
        );
      },
    );
  }
}

class _FieldJournalExportModalContent extends StatefulWidget {
  final List<TripAlbum> albums;
  final List<TripPlace> places;
  final double totalKm;
  final String journalContent;

  const _FieldJournalExportModalContent({
    required this.albums,
    required this.places,
    required this.totalKm,
    required this.journalContent,
  });

  @override
  State<_FieldJournalExportModalContent> createState() =>
      _FieldJournalExportModalContentState();
}

class _FieldJournalExportModalContentState
    extends State<_FieldJournalExportModalContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    try {
      await Share.share(
        widget.journalContent,
        subject: 'Wanderline Expedition Field Journal Dossier',
      );
    } catch (_) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Unable to open share sheet.');
      }
    }
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.journalContent));
    if (mounted) {
      WaymarkSnackbar.showSuccess(
        context,
        'Field Journal Dossier copied to clipboard!',
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final modalHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      height: modalHeight,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 14.h,
        bottom: MediaQuery.paddingOf(context).bottom + 16.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.borderDivider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDEA9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 22.sp,
                  color: const Color(0xFF5E4100),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Expedition Field Journal',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'TEXT DOSSIER',
                            style: context.textTheme.caption.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${widget.albums.length} journeys • ${widget.places.length} places recorded • ${widget.totalKm.toStringAsFixed(1)} km',
                      style: context.textTheme.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: colors.textSecondary,
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Explanatory Info Card: "What is this feature?"
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(WaymarkSpacing.radiusSm),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.16),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: colors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'A complete, plain-text ledger of your expedition history with GPS coordinates, timestamps, and notes. Copy or share directly to notes apps (Obsidian, Apple Notes), emails, or keep as an offline archive.',
                    style: context.textTheme.caption.copyWith(
                      color: colors.textPrimary.withValues(alpha: 0.85),
                      fontSize: 11.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Preview Box with smooth scrolling, selection & interactive scrollbar
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusMd),
                border: Border.all(color: colors.borderDivider),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusMd - 1,
                    ),
                    child: SelectionArea(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(4),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 14.w,
                            right: 20.w,
                            top: 14.h,
                            bottom: 50.h,
                          ),
                          child: Text(
                            widget.journalContent,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.55,
                              fontSize: 11.5.sp,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating quick-scroll jump buttons (Top / Bottom)
                  Positioned(
                    right: 8.w,
                    bottom: 8.h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceCard.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(
                          WaymarkSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: colors.borderDivider,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18.sp,
                            padding: EdgeInsets.all(6.w),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_upward_rounded),
                            tooltip: 'Scroll to top',
                            onPressed: _scrollToTop,
                          ),
                          Container(
                            height: 14.h,
                            width: 1,
                            color: colors.borderDivider,
                          ),
                          IconButton(
                            iconSize: 18.sp,
                            padding: EdgeInsets.all(6.w),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.arrow_downward_rounded),
                            tooltip: 'Scroll to bottom',
                            onPressed: _scrollToBottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Action Buttons: Copy Text & Share Dossier
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
                  onPressed: _handleCopy,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: WaymarkPrimaryButton(
                  label: 'Share Dossier',
                  icon: Icons.share_rounded,
                  onPressed: _handleShare,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
