import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/gen/assets.gen.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/presentation/widgets/waymark_shimmer.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/router/route_names.dart';
import 'package:waymark/core/services/location_search_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';

enum _JourneyDetailTab { timeline, routeMap, wall }

class JourneyAlbumDetailScreen extends StatefulWidget {
  final String journeyId;

  const JourneyAlbumDetailScreen({super.key, required this.journeyId});

  @override
  State<JourneyAlbumDetailScreen> createState() =>
      _JourneyAlbumDetailScreenState();
}

class _JourneyAlbumDetailScreenState extends State<JourneyAlbumDetailScreen> {
  final ValueNotifier<_JourneyDetailTab> _activeTabNotifier =
      ValueNotifier<_JourneyDetailTab>(_JourneyDetailTab.timeline);
  final MapController _mapController = MapController();
  final ValueNotifier<int> _selectedWaypointIndexNotifier = ValueNotifier<int>(
    0,
  );
  final ValueNotifier<bool> _isReorderingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<DateTimeRange?> _wallDateRangeFilterNotifier =
      ValueNotifier<DateTimeRange?>(null);

  final ValueNotifier<List<LatLng>?> _roadRoutePointsNotifier =
      ValueNotifier<List<LatLng>?>(null);
  final ValueNotifier<double?> _roadDistanceKmNotifier = ValueNotifier<double?>(
    null,
  );
  final ValueNotifier<bool> _isRouteLoadingNotifier = ValueNotifier<bool>(
    false,
  );
  String? _lastRouteKey;

  late Stream<TripAlbum?> _albumStream;
  late Stream<List<TripPlace>> _placesStream;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  @override
  void dispose() {
    _activeTabNotifier.dispose();
    _selectedWaypointIndexNotifier.dispose();
    _isReorderingNotifier.dispose();
    _wallDateRangeFilterNotifier.dispose();
    _roadRoutePointsNotifier.dispose();
    _roadDistanceKmNotifier.dispose();
    _isRouteLoadingNotifier.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant JourneyAlbumDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journeyId != widget.journeyId) {
      _lastRouteKey = null;
      _roadRoutePointsNotifier.value = null;
      _roadDistanceKmNotifier.value = null;
      _initStreams();
    }
  }

  void _initStreams() {
    final db = AppDatabase.instance;
    _albumStream = db.tripAlbumDao.watchAlbumById(widget.journeyId);
    _placesStream = db.tripPlaceDao.watchPlacesForAlbum(widget.journeyId);
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

  void _checkAndFetchRoadRoute(List<TripPlace> places) {
    final key = places
        .map((p) => '${p.id}:${p.latitude},${p.longitude}')
        .join(';');
    if (key == _lastRouteKey) return;
    _lastRouteKey = key;

    if (places.length < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _isRouteLoadingNotifier.value = false;
          _roadRoutePointsNotifier.value = null;
          _roadDistanceKmNotifier.value = null;
        }
      });
      return;
    }

    _isRouteLoadingNotifier.value = true;

    final straightKm = _calculateStraightLineKm(places);
    final waypoints = places
        .map((p) => (latitude: p.latitude, longitude: p.longitude))
        .toList();

    LocationSearchService.instance.fetchRoutePolyline(waypoints).then((result) {
      if (!mounted) return;
      _isRouteLoadingNotifier.value = false;

      final double resolvedKm;
      if (result != null && result.points.isNotEmpty) {
        _roadRoutePointsNotifier.value = result.points
            .map((pt) => LatLng(pt.latitude, pt.longitude))
            .toList();
        resolvedKm = result.distanceKm;
      } else {
        _roadRoutePointsNotifier.value = null;
        resolvedKm = straightKm;
      }
      _roadDistanceKmNotifier.value = resolvedKm;

      // Persist the resolved distance so the dashboard (and any other screen)
      // reads the same value from the DB instead of a stale 0.
      AppDatabase.instance.tripAlbumDao.getAlbumById(widget.journeyId).then((
        album,
      ) async {
        if (album == null) return;
        if ((album.totalDistanceKm - resolvedKm).abs() < 0.01) return;
        await AppDatabase.instance.tripAlbumDao.updateAlbum(
          album.copyWith(totalDistanceKm: resolvedKm),
        );
      });
    });
  }

  Future<void> _movePlaceUp(List<TripPlace> places, int index) async {
    if (index <= 0) return;
    final updatedList = List<TripPlace>.from(places);
    final temp = updatedList[index];
    updatedList[index] = updatedList[index - 1];
    updatedList[index - 1] = temp;
    await AppDatabase.instance.tripPlaceDao.updateVisitOrders(
      updatedList.map((p) => p.id).toList(),
    );
  }

  Future<void> _movePlaceDown(List<TripPlace> places, int index) async {
    if (index >= places.length - 1) return;
    final updatedList = List<TripPlace>.from(places);
    final temp = updatedList[index];
    updatedList[index] = updatedList[index + 1];
    updatedList[index + 1] = temp;
    await AppDatabase.instance.tripPlaceDao.updateVisitOrders(
      updatedList.map((p) => p.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    final colors = context.colorScheme;

    return StreamBuilder<TripAlbum?>(
      stream: _albumStream,
      builder: (context, albumSnapshot) {
        if (albumSnapshot.connectionState == ConnectionState.waiting &&
            !albumSnapshot.hasData) {
          return Scaffold(
            backgroundColor: colors.surfaceCanvas,
            body: _buildLoading(),
          );
        }

        final album = albumSnapshot.data;
        if (album == null) {
          return Scaffold(
            backgroundColor: colors.surfaceCanvas,
            appBar: WaymarkLiquidGlassAppBar(
              title: context.l10n.navJourneys,
              subtitle: context.l10n.appName,
            ),
            body: Center(
              child: Text(
                'Journey not found',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          );
        }

        return StreamBuilder<List<TripPlace>>(
          stream: _placesStream,
          builder: (context, placesSnapshot) {
            final places = placesSnapshot.data ?? [];
            final placeIds = places.map((p) => p.id).toList();

            // Trigger route polyline calculation when places load or reorder
            _checkAndFetchRoadRoute(places);

            return StreamBuilder<List<PlaceMediaFile>>(
              stream: db.placeMediaDao.watchMediaForPlaces(placeIds),
              builder: (context, mediaSnapshot) {
                final allMedia = mediaSnapshot.data ?? [];

                final topPadding = MediaQuery.paddingOf(context).top;
                final appBarHeight = topPadding + 64.h;

                return Scaffold(
                  backgroundColor: colors.surfaceCanvas,
                  extendBodyBehindAppBar: true,
                  appBar: WaymarkLiquidGlassAppBar(
                    title: 'Journey Detail',
                    subtitle: 'WayMark Journal',
                    actions: [
                      // IconButton(
                      //   icon: const Icon(Icons.share_outlined),
                      //   color: colors.onSurfaceVariant,
                      //   tooltip: 'Share Journey',
                      //   onPressed: () {
                      //     WaymarkSnackbar.showInfo(context, 'Sharing expedition summary for ${album.title}');
                      //   },
                      // ),
                    ],
                  ),
                  bottomNavigationBar: _buildStickyBottomActionBar(
                    context: context,
                    album: album,
                    placesCount: places.length,
                  ),
                  body: ScrollConfiguration(
                    behavior: const WaymarkNoOverscrollScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 0. Top spacing matching app bar height so hero image sits directly below app bar initially,
                          // and smoothly scrolls behind the liquid glass effect on scroll.
                          SizedBox(height: appBarHeight),

                          // 1. Hero Cover Banner
                          _buildHeroBanner(context, album),

                          // 2. Trip Stats Bar
                          _buildStatsBar(context, album, places),

                          // 3. Segmented View Switcher Pill Tab & Active Tab Content
                          ValueListenableBuilder<_JourneyDetailTab>(
                            valueListenable: _activeTabNotifier,
                            builder: (context, activeTab, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTabSwitcher(
                                    context,
                                    allMedia.length,
                                    activeTab,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: WaymarkSpacing.margin(context),
                                      right: WaymarkSpacing.margin(context),
                                      top: 16.h,
                                      bottom:
                                          16.h, // Space for sticky bottom bar
                                    ),
                                    child: _buildActiveTabContent(
                                      context: context,
                                      album: album,
                                      places: places,
                                      allMedia: allMedia,
                                      activeTab: activeTab,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
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
  }

  // ==========================================
  // HERO BANNER MATCHING STITCH SUITE
  // ==========================================
  Widget _buildHeroBanner(BuildContext context, TripAlbum album) {
    final colors = context.colorScheme;
    final isOngoing = album.status == 'ONGOING';
    final dateFmt = DateFormat('MMM d');
    final startStr = dateFmt.format(album.startDate);
    final endStr = album.endDate != null
        ? dateFmt.format(album.endDate!)
        : 'Present';
    final stampNumber = (album.id.hashCode.abs() % 900 + 100)
        .toString()
        .padLeft(3, '0');

    return Container(
      width: double.infinity,
      height: 240.h,
      color: colors.surfaceContainerLow,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover photo with fallback
          _buildCoverImage(album),

          // Vignette & gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.surfaceCanvas,
                    colors.surfaceCanvas.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Archival Rubber Stamp Badge (Top Right)
          Positioned(
            top: 14.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.surfaceCanvas.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOngoing ? Icons.hiking_rounded : Icons.verified_rounded,
                    size: 14.sp,
                    color: isOngoing ? colors.forestVivid : colors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isOngoing
                        ? 'ONGOING EXPEDITION'
                        : 'ARCHIVED LOG #$stampNumber',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isOngoing ? colors.forestVivid : colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Edit Album Pill Button (Top Left - avoids overlapping Archival Rubber Stamp Badge on top right)
          Positioned(
            top: 14.h,
            left: 16.w,
            child: Material(
              color: colors.surfaceCard.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              child: InkWell(
                borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
                onTap: () =>
                    CreateJourneyBottomSheet.show(context, albumToEdit: album),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14.sp,
                        color: colors.textPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Edit Album',
                        style: context.textTheme.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Header Content Overlay (Bottom Left)
          Positioned(
            bottom: 12.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14.sp,
                      color: colors.secondary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        (album.description != null &&
                                album.description!.isNotEmpty)
                            ? '${album.description} • $startStr – $endStr'
                            : 'Expedition Memoir • $startStr – $endStr',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  album.title,
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: colors.textPrimary,
                    fontSize: 22.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TRIP STATS BAR MATCHING STITCH
  // ==========================================
  Widget _buildStatsBar(
    BuildContext context,
    TripAlbum album,
    List<TripPlace> places,
  ) {
    final colors = context.colorScheme;
    final daysRecorded = album.endDate != null
        ? album.endDate!.difference(album.startDate).inDays + 1
        : DateTime.now().difference(album.startDate).inDays + 1;

    return ValueListenableBuilder<bool>(
      valueListenable: _isRouteLoadingNotifier,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<double?>(
          valueListenable: _roadDistanceKmNotifier,
          builder: (context, roadDistanceKm, _) {
            final dynamicDistance =
                roadDistanceKm ?? _calculateStraightLineKm(places);
            final totalKm = album.totalDistanceKm > 0.05
                ? album.totalDistanceKm
                : dynamicDistance;
            // Show the distance slot whenever we're loading (≥2 places) or
            // there's already a valid distance resolved.
            final willHaveDistance = places.length >= 2 || totalKm > 0.05;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: WaymarkSpacing.margin(context),
                vertical: 8.h,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0A1F2421),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stat 1: Total Path — shimmer while loading, value when ready
                  if (willHaveDistance) ...[
                    if (isLoading)
                      Expanded(
                        child: Column(
                          children: [
                            WaymarkShimmerBox(
                              width: 60.w,
                              height: 18.h,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            SizedBox(height: 4.h),
                            WaymarkShimmerBox(
                              width: 48.w,
                              height: 11.h,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildStatColumn(
                        context,
                        value: totalKm.toStringAsFixed(1),
                        unit: 'km',
                        label: 'Total Path',
                        valueColor: colors.primary,
                      ),
                    _buildStatDivider(colors),
                  ],

                  // Stat 2: Places
                  _buildStatColumn(
                    context,
                    value: '${places.length}',
                    unit: '',
                    label: 'Places',
                    valueColor: colors.textPrimary,
                  ),
                  _buildStatDivider(colors),

                  // Stat 3: Recorded Days
                  _buildStatColumn(
                    context,
                    value: '$daysRecorded',
                    unit: 'days',
                    label: 'Recorded',
                    valueColor: colors.secondary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String unit,
    required String label,
    required Color valueColor,
  }) {
    final colors = context.colorScheme;
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
                fontSize: 16.sp,
              ),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: context.textTheme.caption.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: context.textTheme.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ColorScheme colors) {
    return Container(
      width: 1,
      height: 24.h,
      color: colors.surfaceContainerHigh,
    );
  }

  // ==========================================
  // SLIDING SEGMENTED VIEW SWITCHER PILL TAB
  // ==========================================
  Widget _buildTabSwitcher(
    BuildContext context,
    int photosCount,
    _JourneyDetailTab activeTab,
  ) {
    final colors = context.colorScheme;
    final alignment = switch (activeTab) {
      _JourneyDetailTab.timeline => const Alignment(-1.0, 0.0),
      _JourneyDetailTab.routeMap => const Alignment(0.0, 0.0),
      _JourneyDetailTab.wall => const Alignment(1.0, 0.0),
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: WaymarkSpacing.margin(context),
        vertical: 8.h,
      ),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
        ),
        child: Stack(
          children: [
            // Smooth sliding indicator pill
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              alignment: alignment,
              child: FractionallySizedBox(
                widthFactor: 1.0 / 3.0,
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tab selection items
            Row(
              children: [
                _buildTabButton(
                  context: context,
                  tab: _JourneyDetailTab.timeline,
                  activeTab: activeTab,
                  label: 'Timeline',
                  icon: Icons.timeline_rounded,
                ),
                _buildTabButton(
                  context: context,
                  tab: _JourneyDetailTab.routeMap,
                  activeTab: activeTab,
                  label: 'Route Map',
                  icon: Icons.map_rounded,
                ),
                _buildTabButton(
                  context: context,
                  tab: _JourneyDetailTab.wall,
                  activeTab: activeTab,
                  label: 'Wall ($photosCount)',
                  icon: Icons.photo_library_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required _JourneyDetailTab tab,
    required _JourneyDetailTab activeTab,
    required String label,
    required IconData icon,
  }) {
    final isSelected = activeTab == tab;
    final colors = context.colorScheme;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _activeTabNotifier.value = tab;
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey('${tab.name}_$isSelected'),
                  size: 15.sp,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (context.textTheme.labelMedium ?? const TextStyle())
                      .copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ACTIVE TAB CONTENT DISPATCHER WITH SLIDING ANIMATION
  // ==========================================
  Widget _buildActiveTabContent({
    required BuildContext context,
    required TripAlbum album,
    required List<TripPlace> places,
    required List<PlaceMediaFile> allMedia,
    required _JourneyDetailTab activeTab,
  }) {
    final Widget tabWidget = switch (activeTab) {
      _JourneyDetailTab.timeline => _buildTimelineTab(
        context,
        album,
        places,
        allMedia,
      ),
      _JourneyDetailTab.routeMap => _buildRouteMapTab(context, album, places),
      _JourneyDetailTab.wall => _buildWallTab(context, album, places, allMedia),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(activeTab), child: tabWidget),
    );
  }

  // ==========================================
  // TAB 1: TIMELINE VIEW
  // ==========================================
  Widget _buildTimelineTab(
    BuildContext context,
    TripAlbum album,
    List<TripPlace> places,
    List<PlaceMediaFile> allMedia,
  ) {
    final colors = context.colorScheme;
    final dateFmt = DateFormat('EEE, MMM d');

    if (places.isEmpty) {
      return WaymarkArtisticEmptyState(
        isCompact: true,
        icon: Icons.pin_drop_rounded,
        badgeText: 'EXPEDITION LOGBOOK',
        title: 'No Waypoints Logged Yet',
        description:
            'Trek deeper into the journey by tapping "+ Log Place" below.',
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isReorderingNotifier,
      builder: (context, isReordering, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            'Day 01',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Arrival & Ancient Shrines',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (places.length > 1) ...[
                    SizedBox(width: 6.w),
                    InkWell(
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
                      ),
                      onTap: () {
                        _isReorderingNotifier.value =
                            !_isReorderingNotifier.value;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isReordering
                              ? colors.forestVivid.withValues(alpha: 0.15)
                              : colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color: isReordering
                                ? colors.forestVivid
                                : colors.borderDivider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isReordering
                                  ? Icons.done_all_rounded
                                  : Icons.swap_vert_rounded,
                              size: 13.sp,
                              color: isReordering
                                  ? colors.forestVivid
                                  : colors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isReordering ? 'Done' : 'Reorder',
                              style: context.textTheme.caption.copyWith(
                                color: isReordering
                                    ? colors.forestVivid
                                    : colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(width: 8.w),
                  Text(
                    dateFmt.format(album.startDate),
                    style: context.textTheme.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Reordering Instructions Banner
            if (isReordering)
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16.sp,
                      color: colors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Use the Up and Down arrows on each waypoint card to adjust your visit sequence.',
                        style: context.textTheme.caption.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Sequential Places with Dashed Line & Node Pins
            ListView.builder(
              key: ValueKey('timeline_list_${places.length}_$isReordering'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                final isFirst = index == 0;
                final isLast = index == places.length - 1;
                final placeMedia = allMedia
                    .where((m) => m.placeId == place.id)
                    .toList();

                return _buildTimelineNodeItem(
                  key: ValueKey('timeline_node_${place.id}'),
                  context: context,
                  album: album,
                  places: places,
                  place: place,
                  index: index,
                  isFirst: isFirst,
                  isLast: isLast,
                  media: placeMedia,
                  isReordering: isReordering,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineNodeItem({
    Key? key,
    required BuildContext context,
    required TripAlbum album,
    required List<TripPlace> places,
    required TripPlace place,
    required int index,
    required bool isFirst,
    required bool isLast,
    required List<PlaceMediaFile> media,
    required bool isReordering,
  }) {
    final colors = context.colorScheme;
    final timeStr = DateFormat('hh:mm a').format(place.visitedAt);

    Color pinColor = colors.primary;
    Widget pinIcon = Text(
      '${index + 1}',
      style: context.textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10.sp,
      ),
    );

    if (isFirst) {
      pinColor = const Color(0xFF3B82F6); // route-start blue
      pinIcon = Icon(
        Icons.flight_land_rounded,
        size: 12.sp,
        color: Colors.white,
      );
    } else if (isLast) {
      pinColor = const Color(0xFFF43F5E); // route-end rose
      pinIcon = Icon(Icons.flag_rounded, size: 12.sp, color: Colors.white);
    } else if (index % 2 == 1) {
      pinColor = colors.tertiaryContainer;
    }

    int? rating;
    final otherSensoryTags = <String>[];
    if (place.sensoryTags != null && place.sensoryTags!.isNotEmpty) {
      for (final tag in place.sensoryTags!.split(',')) {
        final t = tag.trim();
        if (t.startsWith('rating:')) {
          rating = int.tryParse(t.substring(7));
        } else if (t.isNotEmpty) {
          otherSensoryTags.add(t);
        }
      }
    }

    return Stack(
      key: key,
      children: [
        // Dashed Line running vertically on left
        if (!isLast)
          Positioned(
            left: 12.w,
            top: 24.h,
            bottom: 0,
            child: _buildDashedVerticalLine(colors),
          ),

        // Node Pin Badge
        Positioned(
          left: 3.w,
          top: 6.h,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: pinColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: pinIcon,
          ),
        ),

        // Milestone Content Container
        Padding(
          padding: EdgeInsets.only(left: 32.w, bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Milestone Card with smooth layout animation on reorder
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isReordering
                        ? colors.primary.withValues(alpha: 0.45)
                        : colors.borderDivider.withValues(alpha: 0.5),
                    width: isReordering ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isReordering
                          ? colors.primary.withValues(alpha: 0.12)
                          : const Color(0x0F1F2421),
                      blurRadius: isReordering ? 10 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () {
                          PlaceLoggerBottomSheet.show(
                            context,
                            albumId: album.id,
                            albumTitle: album.title,
                            placeToEdit: place,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Node P${index + 1} • $timeStr'
                                          .toUpperCase(),
                                      style: context.textTheme.caption.copyWith(
                                        color: pinColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            WaymarkSpacing.radiusFull,
                                          ),
                                        ),
                                        child: Text(
                                          place.category.toUpperCase(),
                                          style: context.textTheme.caption
                                              .copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 9.sp,
                                              ),
                                        ),
                                      ),
                                      if (!isReordering) ...[
                                        SizedBox(width: 4.w),
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.more_vert_rounded,
                                            size: 18.sp,
                                            color: colors.textSecondary
                                                .withValues(alpha: 0.7),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          onSelected: (action) {
                                            if (action == 'edit') {
                                              PlaceLoggerBottomSheet.show(
                                                context,
                                                albumId: album.id,
                                                albumTitle: album.title,
                                                placeToEdit: place,
                                              );
                                            } else if (action == 'delete') {
                                              _confirmDeletePlace(
                                                context,
                                                place,
                                                album,
                                                places,
                                              );
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    size: 16.sp,
                                                    color: colors.textPrimary,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    'Edit Place',
                                                    style: ctx
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: colors
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 16.sp,
                                                    color: Colors.redAccent,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    'Delete Place',
                                                    style: ctx
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              Colors.redAccent,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),

                              // Place Name
                              Text(
                                place.name,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),

                              if (place.notes != null &&
                                  place.notes!.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  place.notes!,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],

                              SizedBox(height: 8.h),

                              // Context Badges Row (Weather, Route, Elev, Recommendation, Sensory)
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                children: [
                                  if (place.weatherCondition != null)
                                    _buildContextBadge(
                                      context,
                                      icon: Icons.wb_sunny_rounded,
                                      label:
                                          '${place.weatherCondition} ${place.temperatureCelsius?.toInt() ?? 20}°C',
                                      iconColor: colors.tertiary,
                                    ),
                                  _buildContextBadge(
                                    context,
                                    icon: Icons.hiking_rounded,
                                    label:
                                        '${(place.visitOrder + 1) * 2.4} km loop',
                                    iconColor: colors.secondary,
                                  ),
                                  if (rating != null)
                                    _buildContextBadge(
                                      context,
                                      icon: Icons.star_rounded,
                                      label: '$rating/10 Rec',
                                      iconColor: const Color(0xFFC89D3C),
                                    ),
                                  ...otherSensoryTags
                                      .take(2)
                                      .map(
                                        (tag) => _buildContextBadge(
                                          context,
                                          icon: Icons.spa_rounded,
                                          label: tag,
                                          iconColor: colors.primary,
                                        ),
                                      ),
                                ],
                              ),

                              // Polaroid Photos Preview Stack
                              if (media.isNotEmpty) ...[
                                SizedBox(height: 10.h),
                                SizedBox(
                                  height: 110.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: media.length > 3
                                        ? 3
                                        : media.length,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(width: 8.w),
                                    itemBuilder: (context, photoIdx) {
                                      if (photoIdx == 2 && media.length > 3) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            // Expand 3rd photo (or first remaining photo)
                                            _showPhotoLightbox(
                                              context,
                                              media[2],
                                              place.name,
                                            );
                                          },
                                          child: _buildMorePhotosTile(
                                            context,
                                            remaining: media.length - 2,
                                          ),
                                        );
                                      }
                                      final photo = media[photoIdx];
                                      final isTilted = photoIdx % 2 == 0;

                                      return Transform.rotate(
                                        angle: isTilted ? -0.02 : 0.02,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                            onTap: () {
                                              // Expand the tapped photo in interactive lightbox viewer
                                              _showPhotoLightbox(
                                                context,
                                                photo,
                                                place.name,
                                              );
                                            },
                                            child: Container(
                                              width: 95.w,
                                              padding: EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceCard,
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4.r,
                                                          ),
                                                      child:
                                                          _buildPhotoThumbnail(
                                                            photo.localFilePath,
                                                            colors,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.h),
                                                  Text(
                                                    photo.isCoverPhoto
                                                        ? 'Cover Shot'
                                                        : 'Milestone View',
                                                    style: context
                                                        .textTheme
                                                        .caption
                                                        .copyWith(
                                                          color: colors
                                                              .textSecondary,
                                                          fontSize: 8.5.sp,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Dedicated Prominent Reordering Pill
                    if (isReordering)
                      _buildReorderControlPill(
                        context: context,
                        places: places,
                        index: index,
                      ),
                  ],
                ),
              ),

              // Transit Connector Pill between Nodes
              if (!isLast) ...[
                SizedBox(height: 8.h),
                _buildTransitConnectorPill(context, index: index),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReorderControlPill({
    required BuildContext context,
    required List<TripPlace> places,
    required int index,
  }) {
    final colors = context.colorScheme;
    final canMoveUp = index > 0;
    final canMoveDown = index < places.length - 1;

    return Padding(
      padding: EdgeInsets.only(right: 8.w, top: 10.h, bottom: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Move Up Button
            Material(
              color: canMoveUp ? colors.primaryContainer : Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canMoveUp ? () => _movePlaceUp(places, index) : null,
                child: Padding(
                  padding: EdgeInsets.all(7.w),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 22.sp,
                    color: canMoveUp
                        ? colors.primary
                        : colors.textSecondary.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                ),
                child: Text(
                  '#${index + 1}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
            // Move Down Button
            Material(
              color: canMoveDown ? colors.primaryContainer : Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: canMoveDown ? () => _movePlaceDown(places, index) : null,
                child: Padding(
                  padding: EdgeInsets.all(7.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.sp,
                    color: canMoveDown
                        ? colors.primary
                        : colors.textSecondary.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedVerticalLine(ColorScheme colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: List.generate(
            15,
            (index) => Container(
              width: 2,
              height: 4,
              margin: const EdgeInsets.only(bottom: 3),
              color: colors.borderDivider,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    final colors = context.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: iconColor),
          SizedBox(width: 3.w),
          Text(
            label,
            style: context.textTheme.caption.copyWith(
              color: colors.textPrimary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorePhotosTile(BuildContext context, {required int remaining}) {
    final colors = context.colorScheme;
    return Container(
      width: 75.w,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.borderDivider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 20.sp,
            color: colors.textSecondary,
          ),
          SizedBox(height: 4.h),
          Text(
            '+$remaining More',
            style: context.textTheme.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitConnectorPill(
    BuildContext context, {
    required int index,
  }) {
    final colors = context.colorScheme;
    final connectors = [
      (Icons.directions_subway_rounded, '35 min local train • JR Nara Line'),
      (Icons.directions_walk_rounded, '18 min stone trail walk'),
      (Icons.directions_bus_rounded, '25 min City Loop Bus #206'),
      (Icons.hiking_rounded, '45 min highland forest trail'),
    ];
    final item = connectors[index % connectors.length];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(WaymarkSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.$1, size: 13.sp, color: colors.primary),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              item.$2,
              style: context.textTheme.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: ROUTE MAP VIEW MATCHING STITCH
  // ==========================================
  Widget _buildRouteMapTab(
    BuildContext context,
    TripAlbum album,
    List<TripPlace> places,
  ) {
    final colors = context.colorScheme;

    if (places.isEmpty) {
      return WaymarkArtisticEmptyState(
        isCompact: true,
        icon: Icons.map_rounded,
        badgeText: 'GPS ROUTE TRACE',
        title: 'No Route Coordinates Available',
        description:
            'Log waypoints to view the interactive GPS route path on the map.',
      );
    }

    final points = places.map((p) => LatLng(p.latitude, p.longitude)).toList();

    return ListenableBuilder(
      listenable: Listenable.merge([
        _selectedWaypointIndexNotifier,
        _roadRoutePointsNotifier,
        _roadDistanceKmNotifier,
      ]),
      builder: (context, _) {
        final selectedWaypointIndex = _selectedWaypointIndexNotifier.value;
        final roadRoutePoints = _roadRoutePointsNotifier.value;
        final roadDistanceKm = _roadDistanceKmNotifier.value;

        final center = points.isNotEmpty
            ? points[selectedWaypointIndex.clamp(0, points.length - 1)]
            : const LatLng(34.9949, 135.7850);

        final dynamicDistance =
            roadDistanceKm ?? _calculateStraightLineKm(places);
        final totalKm = album.totalDistanceKm > 0.05
            ? album.totalDistanceKm
            : dynamicDistance;
        final hasValidDistance = totalKm > 0.05;

        final polylinePoints =
            (roadRoutePoints != null && roadRoutePoints.isNotEmpty)
            ? roadRoutePoints
            : points;

        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0A1F2421),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS Route Trace',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${places.length} Milestones${hasValidDistance ? " • ${totalKm.toStringAsFixed(1)} km traversed" : ""}',
                          style: context.textTheme.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Interactive Map Container
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  height: 280.h,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 11.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'app.waymark.journal',
                          ),
                          if (polylinePoints.length > 1)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: polylinePoints,
                                  color: colors.primary,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: places.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final p = entry.value;
                              final isStart = idx == 0;
                              final isEnd = idx == places.length - 1;
                              final isSelected = idx == selectedWaypointIndex;

                              return Marker(
                                point: LatLng(p.latitude, p.longitude),
                                width: 44.w,
                                height: 44.w,
                                child: GestureDetector(
                                  onTap: () {
                                    _selectedWaypointIndexNotifier.value = idx;
                                    _mapController.move(
                                      LatLng(p.latitude, p.longitude),
                                      13.5,
                                    );
                                  },
                                  child: _buildArtisticMapMarker(
                                    context: context,
                                    index: idx,
                                    place: p,
                                    isSelected: isSelected,
                                    isStart: isStart,
                                    isEnd: isEnd,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // Floating Map Zoom Controls (Top Right)
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceCard.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_rounded),
                                iconSize: 18.sp,
                                constraints: BoxConstraints.tight(
                                  Size(32.w, 32.w),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom + 1,
                                  );
                                },
                              ),
                              Container(
                                width: 24.w,
                                height: 1,
                                color: colors.surfaceContainerHigh,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_rounded),
                                iconSize: 18.sp,
                                constraints: BoxConstraints.tight(
                                  Size(32.w, 32.w),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    _mapController.camera.zoom - 1,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Route Legend Card (Bottom Left/Right)
                      Positioned(
                        bottom: 10.h,
                        left: 10.w,
                        right: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${places.first.name} ➔ ${places.last.name}',
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                            fontSize: 11.sp,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Optimal foot & rail path recorded',
                                      style: context.textTheme.caption.copyWith(
                                        color: colors.textSecondary,
                                        fontSize: 9.5.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.navigation_rounded,
                                size: 18.sp,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Waypoint Summary Row
              SizedBox(
                height: 48.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: places.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, idx) {
                    final p = places[idx];
                    final isSelected = idx == selectedWaypointIndex;

                    return InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () {
                        _selectedWaypointIndexNotifier.value = idx;
                        _mapController.move(
                          LatLng(p.latitude, p.longitude),
                          15.0,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.1)
                              : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.borderDivider,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'P${idx + 1}',
                              style: context.textTheme.caption.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 90.w),
                              child: Text(
                                p.name,
                                style: context.textTheme.caption.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
        );
      },
    );
  }

  Widget _buildArtisticMapMarker({
    required BuildContext context,
    required int index,
    required TripPlace place,
    required bool isSelected,
    required bool isStart,
    required bool isEnd,
  }) {
    final colors = context.colorScheme;
    final brassBorderColor = isSelected
        ? const Color(0xFFFFD54F)
        : const Color(0xFFC89D3C);
    Color coreColor;
    if (isStart) {
      coreColor = const Color(0xFF1D4ED8);
    } else if (isEnd) {
      coreColor = const Color(0xFFBE123C);
    } else {
      coreColor = isSelected ? colors.primary : const Color(0xFF1E3A2B);
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer glowing halo when selected
        if (isSelected)
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brassBorderColor.withValues(alpha: 0.35),
            ),
          ),

        // Antique Brass Seal Medallion
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: coreColor,
            border: Border.all(
              color: brassBorderColor,
              width: isSelected ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isStart
              ? Icon(Icons.near_me_rounded, size: 14.sp, color: Colors.white)
              : isEnd
              ? Icon(Icons.flag_rounded, size: 14.sp, color: Colors.white)
              : Text(
                  'P${index + 1}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFFF9E6),
                    fontWeight: FontWeight.w800,
                    fontSize: 9.sp,
                    letterSpacing: 0.2,
                  ),
                ),
        ),

        // Cardinal North Tick mark
        Positioned(
          top: 3.h,
          child: Container(
            width: 2.w,
            height: 3.5.h,
            decoration: BoxDecoration(
              color: brassBorderColor,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: VISUAL WALL VIEW MATCHING STITCH
  // ==========================================
  Widget _buildWallTab(
    BuildContext context,
    TripAlbum album,
    List<TripPlace> places,
    List<PlaceMediaFile> allMedia,
  ) {
    final colors = context.colorScheme;

    if (allMedia.isEmpty) {
      return WaymarkArtisticEmptyState(
        isCompact: true,
        icon: Icons.photo_library_rounded,
        badgeText: 'MEMORY ARTIFACTS',
        title: 'No Preserved Artifacts Yet',
        description:
            'Take and attach high-res analog photos when logging stops along your journey.',
      );
    }

    final placeNameMap = {for (final p in places) p.id: p.name};

    return ValueListenableBuilder<DateTimeRange?>(
      valueListenable: _wallDateRangeFilterNotifier,
      builder: (context, wallDateRangeFilter, _) {
        // Filter media by date range if active
        final filteredMedia = allMedia.where((m) {
          if (wallDateRangeFilter == null) return true;
          final dt = m.capturedAt ?? album.startDate;
          final start = DateTime(
            wallDateRangeFilter.start.year,
            wallDateRangeFilter.start.month,
            wallDateRangeFilter.start.day,
          );
          final end = DateTime(
            wallDateRangeFilter.end.year,
            wallDateRangeFilter.end.month,
            wallDateRangeFilter.end.day,
            23,
            59,
            59,
          );
          return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
              (dt.isBefore(end) || dt.isAtSameMomentAs(end));
        }).toList();

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
                        'Memory Artifacts',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${filteredMedia.length} high-res film photos preserved',
                        style: context.textTheme.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: wallDateRangeFilter,
                      builder: (pickerContext, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(colorScheme: colors),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      _wallDateRangeFilterNotifier.value = picked;
                    }
                  },
                  icon: Icon(
                    wallDateRangeFilter != null
                        ? Icons.filter_alt_rounded
                        : Icons.filter_list_rounded,
                    size: 16.sp,
                    color: wallDateRangeFilter != null
                        ? colors.forestVivid
                        : colors.primary,
                  ),
                  label: Text(
                    wallDateRangeFilter != null ? 'Filtered' : 'Filter',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: wallDateRangeFilter != null
                          ? colors.forestVivid
                          : colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Active Date Range Filter Chip
            if (wallDateRangeFilter != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    WaymarkSpacing.radiusFull,
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 14.sp,
                      color: colors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${DateFormat('MMM d').format(wallDateRangeFilter.start)} – ${DateFormat('MMM d').format(wallDateRangeFilter.end)}',
                      style: context.textTheme.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    InkWell(
                      onTap: () => _wallDateRangeFilterNotifier.value = null,
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.sp,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),

            if (filteredMedia.isEmpty) ...[
              SizedBox(height: 24.h),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 36.sp,
                      color: colors.textSecondary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No photos found in selected date range.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () =>
                          _wallDateRangeFilterNotifier.value = null,
                      child: const Text('Clear Date Filter'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Editorial 2-Column Polaroid Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: filteredMedia.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final mediaItem = filteredMedia[index];
                  final placeName =
                      placeNameMap[mediaItem.placeId] ?? 'Waypoint Stop';
                  final timeStr = mediaItem.capturedAt != null
                      ? DateFormat(
                          'MMM d • HH:mm',
                        ).format(mediaItem.capturedAt!)
                      : 'Expedition Photo';
                  final isTilted = index % 2 == 0;

                  return Transform.rotate(
                    angle: isTilted ? -0.015 : 0.015,
                    child: Material(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(10.r),
                      elevation: 2,
                      shadowColor: const Color(0x141F2421),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          _showPhotoLightbox(context, mediaItem, placeName);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: _buildPhotoThumbnail(
                                    mediaItem.localFilePath,
                                    colors,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                placeName,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                  fontSize: 11.sp,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                timeStr,
                                style: context.textTheme.caption.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 9.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _showPhotoLightbox(
    BuildContext context,
    PlaceMediaFile media,
    String placeName,
  ) {
    final colors = context.colorScheme;
    final timeStr = media.capturedAt != null
        ? DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(media.capturedAt!)
        : 'Expedition Photo';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lightbox Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeName,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeStr,
                          style: context.textTheme.caption.copyWith(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Interactive Pinch-to-Zoom Image
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: _buildLightboxImage(media.localFilePath, colors),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Caption / Status Pill
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        media.isCoverPhoto
                            ? Icons.star_rounded
                            : Icons.camera_alt_rounded,
                        size: 14.sp,
                        color: Colors.amberAccent,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        media.isCoverPhoto
                            ? 'Cover Shot • Memory Wall'
                            : 'Archival Field Capture',
                        style: context.textTheme.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLightboxImage(String path, ColorScheme colors) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      }
      return _buildPlaceholder(colors);
    }
  }

  // ==========================================
  // STICKY BOTTOM ACTION BAR MATCHING STITCH
  // ==========================================
  Widget _buildStickyBottomActionBar({
    required BuildContext context,
    required TripAlbum album,
    required int placesCount,
  }) {
    final colors = context.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: WaymarkSpacing.margin(context),
        right: WaymarkSpacing.margin(context),
        top: 10.h,
        bottom: MediaQuery.paddingOf(context).bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCanvas.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Artistic Postcard CTA Button
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDEA9),
                  foregroundColor: const Color(0xFF5E4100),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18.sp,
                  color: const Color(0xFF7A5500),
                ),
                label: Text(
                  'Art Postcard',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5E4100),
                    fontSize: 13.sp,
                  ),
                ),
                onPressed: () =>
                    _showArtPostcardSheet(context, album, placesCount),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // 2. Primary Action: + Log Place
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: colors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      WaymarkSpacing.radiusFull,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                icon: Icon(
                  Icons.explore_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
                label: Text(
                  '+ Log Place',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                ),
                onPressed: () {
                  PlaceLoggerBottomSheet.show(
                    context,
                    albumId: album.id,
                    albumTitle: album.title,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ARTISTIC POSTCARD MODAL SHEET
  // ==========================================
  void _showArtPostcardSheet(
    BuildContext context,
    TripAlbum album,
    int placesCount,
  ) {
    if (album.id.isNotEmpty) {
      context.push(
        AppRoutes.postcardGenerator.replaceFirst(
          ':albumId',
          Uri.encodeComponent(album.id),
        ),
      );
      return;
    }

    final colors = context.colorScheme;
    final dateFmt = DateFormat('MMM d, yyyy');

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_rounded,
                            color: colors.tertiary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Postcard Memoir',
                              style: ctx.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Postcard Canvas
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE9ECEF),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: SizedBox(
                          height: 140.h,
                          width: double.infinity,
                          child: _buildCoverImage(album),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album.title,
                                  style: ctx.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF181D1A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${dateFmt.format(album.startDate)} • ${album.totalDistanceKm.toStringAsFixed(1)} km traversed',
                                  style: ctx.textTheme.caption.copyWith(
                                    color: const Color(0xFF6C757D),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDEA9),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: const Color(
                                  0xFF7A5500,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'VERIFIED',
                              style: ctx.textTheme.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5E4100),
                                fontSize: 9.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Captured with analog telemetry and tactile preservation in WayMark Journal.',
                        style: ctx.textTheme.caption.copyWith(
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF6C757D),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        WaymarkSpacing.radiusFull,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  label: const Text(
                    'Share Postcard Memoir',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    WaymarkSnackbar.showSuccess(
                      context,
                      'Postcard Memoir ready to share!',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // HELPER METHODS: PHOTOS & LOADING
  // ==========================================
  Widget _buildCoverImage(TripAlbum album) {
    if (album.coverImagePath != null && album.coverImagePath!.isNotEmpty) {
      return _buildPhotoThumbnail(album.coverImagePath!, context.colorScheme);
    }
    return Image.asset(Assets.images.placeTwelve.path, fit: BoxFit.cover);
  }

  Widget _buildPhotoThumbnail(String path, ColorScheme colors) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(colors),
      );
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(colors),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholder(colors),
        );
      }
      return _buildPlaceholder(colors);
    }
  }

  Widget _buildPlaceholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_rounded,
        color: colors.textSecondary,
        size: 28.sp,
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.only(top: 60.h, left: 20.w, right: 20.w),
      child: Column(
        children: [
          WaymarkShimmerBox(
            width: double.infinity,
            height: 220.h,
            borderRadius: BorderRadius.circular(16.r),
          ),
          SizedBox(height: 16.h),
          WaymarkShimmerBox(
            width: double.infinity,
            height: 70.h,
            borderRadius: BorderRadius.circular(16.r),
          ),
          SizedBox(height: 16.h),
          WaymarkShimmerBox(
            width: double.infinity,
            height: 140.h,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlace(
    BuildContext context,
    TripPlace place,
    TripAlbum album,
    List<TripPlace> allPlaces,
  ) {
    final colors = context.colorScheme;
    final isDeletingNotifier = ValueNotifier<bool>(false);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top grab handle
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: colors.borderDivider.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Icon & Title
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Place Entry?',
                            style: sheetContext.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'This action cannot be undone',
                            style: sheetContext.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Place Summary Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colors.borderDivider.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.place_rounded,
                          color: colors.primary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: sheetContext.textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (place.locationAddress != null &&
                                place.locationAddress!.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                place.locationAddress!,
                                style: sheetContext.textTheme.caption.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 11.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                Text(
                  'Are you sure you want to remove "${place.name}" from ${album.title}? '
                  'Its associated photographic relics and stop order will be permanently removed.',
                  style: sheetContext.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20.h),

                // Action Buttons Row
                ValueListenableBuilder<bool>(
                  valueListenable: isDeletingNotifier,
                  builder: (context, isDeleting, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  WaymarkSpacing.radiusFull,
                                ),
                              ),
                              side: BorderSide(color: colors.borderDivider),
                            ),
                            onPressed: isDeleting
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            child: Text(
                              'Cancel',
                              style: context.textTheme.labelLarge?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  WaymarkSpacing.radiusFull,
                                ),
                              ),
                              elevation: 2,
                            ),
                            icon: isDeleting
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_forever_rounded,
                                    size: 20,
                                  ),
                            label: Text(
                              isDeleting ? 'Deleting...' : 'Delete Place',
                              style: context.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    isDeletingNotifier.value = true;
                                    Navigator.of(sheetContext).pop();
                                    await _deletePlace(place, album, allPlaces);
                                  },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      isDeletingNotifier.dispose();
    });
  }

  Future<void> _deletePlace(
    TripPlace place,
    TripAlbum album,
    List<TripPlace> allPlaces,
  ) async {
    try {
      _isRouteLoadingNotifier.value = true;
      final db = AppDatabase.instance;

      // 1. Delete media files for this place
      await db.placeMediaDao.deleteMediaForPlace(place.id);

      // 2. Delete the place record
      await db.tripPlaceDao.deletePlace(place.id);

      // 3. Re-index visit orders of remaining places
      final remaining = allPlaces.where((p) => p.id != place.id).toList();
      await db.tripPlaceDao.updateVisitOrders(
        remaining.map((p) => p.id).toList(),
      );

      // 4. Calculate new distance
      double newDistance = 0.0;
      if (remaining.length >= 2) {
        final waypoints = remaining
            .map((p) => (latitude: p.latitude, longitude: p.longitude))
            .toList();
        final routeResult = await LocationSearchService.instance
            .fetchRoutePolyline(waypoints);
        if (routeResult != null && routeResult.points.isNotEmpty) {
          newDistance = routeResult.distanceKm;
        } else {
          newDistance = _calculateStraightLineKm(remaining);
        }
      }

      // 5. Update Album metadata
      await db.tripAlbumDao.updateAlbum(
        album.copyWith(
          totalPlacesCount: remaining.length,
          totalDistanceKm: newDistance,
          updatedAt: DateTime.now(),
        ),
      );

      _roadDistanceKmNotifier.value = newDistance;
      _roadRoutePointsNotifier.value = null; // Forces re-fetch on next map load

      if (mounted) {
        WaymarkSnackbar.showSuccess(
          context,
          'Place "${place.name}" removed from journey',
        );
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Failed to delete place: $e');
      }
    } finally {
      if (mounted) {
        _isRouteLoadingNotifier.value = false;
      }
    }
  }
}
