import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_animated_entrance.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/journeys/presentation/screens/journey_album_detail_screen.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';
import 'package:waymark/features/journeys/presentation/widgets/place_logger_bottom_sheet.dart';

class ExploreMapViewScreen extends StatefulWidget {
  const ExploreMapViewScreen({super.key});

  @override
  State<ExploreMapViewScreen> createState() => _ExploreMapViewScreenState();
}

class _ExploreMapViewScreenState extends State<ExploreMapViewScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  PageController? _pageController;
  AnimationController? _mapAnimationController;

  final ValueNotifier<String> _selectedCategoryNotifier = ValueNotifier<String>(
    'ALL',
  );
  final ValueNotifier<String?> _selectedPlaceIdNotifier =
      ValueNotifier<String?>(null);
  String? get _selectedPlaceId => _selectedPlaceIdNotifier.value;
  int _currentCarouselIndex = 0;

  static const List<String> _categories = [
    'ALL',
    'SIGHTSEEING',
    'FOOD',
    'STAY',
    'HIKE',
    'TRANSIT',
  ];

  late Stream<List<TripAlbum>> _albumsStream;
  late Stream<List<TripPlace>> _placesStream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
    final db = AppDatabase.instance;
    _albumsStream = db.tripAlbumDao.watchAllAlbums();
    _placesStream = db.tripPlaceDao.watchRecentPlaces(limit: 500);
  }

  @override
  void dispose() {
    _selectedCategoryNotifier.dispose();
    _selectedPlaceIdNotifier.dispose();
    _mapAnimationController?.dispose();
    _pageController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    try {
      if (!mounted) return;
      _mapAnimationController?.stop();
      _mapAnimationController?.dispose();
      _mapAnimationController = null;

      final camera = _mapController.camera;
      final latTween = Tween<double>(
        begin: camera.center.latitude,
        end: destLocation.latitude,
      );
      final lngTween = Tween<double>(
        begin: camera.center.longitude,
        end: destLocation.longitude,
      );
      final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

      final controller = AnimationController(
        duration: const Duration(milliseconds: 450),
        vsync: this,
      );
      _mapAnimationController = controller;

      final Animation<double> animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      );

      controller.addListener(() {
        if (!mounted) return;
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          if (_mapAnimationController == controller) {
            _mapAnimationController?.dispose();
            _mapAnimationController = null;
          }
        }
      });

      controller.forward();
    } catch (_) {
      if (mounted) {
        _mapController.move(destLocation, destZoom);
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'SIGHTSEEING':
        return Icons.photo_camera_rounded;
      case 'FOOD':
        return Icons.restaurant_rounded;
      case 'STAY':
        return Icons.hotel_rounded;
      case 'HIKE':
        return Icons.terrain_rounded;
      case 'TRANSIT':
        return Icons.directions_transit_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'SIGHTSEEING':
        return const Color(0xFFD4AF37); // Bright Gold
      case 'FOOD':
        return const Color(0xFFFF7043); // Vivid Terracotta Orange
      case 'STAY':
        return const Color(0xFF42A5F5); // Vivid Sapphire Blue
      case 'HIKE':
        return const Color(0xFF43A047); // Vivid Emerald Green
      case 'TRANSIT':
        return const Color(0xFF8E24AA); // Vivid Violet
      default:
        return const Color(0xFF2E6E49); // Forest Green
    }
  }

  LatLng _getDisplacedPoint(TripPlace place, List<TripPlace> all) {
    final duplicates = all
        .where(
          (p) =>
              (p.latitude - place.latitude).abs() < 0.00005 &&
              (p.longitude - place.longitude).abs() < 0.00005,
        )
        .toList();

    if (duplicates.length <= 1) {
      return LatLng(place.latitude, place.longitude);
    }

    final idx = duplicates.indexOf(place);
    final angle = (2 * math.pi / duplicates.length) * idx;
    const radius = 0.00022; // ~25 meters offset
    return LatLng(
      place.latitude + radius * math.cos(angle),
      place.longitude + radius * math.sin(angle),
    );
  }

  void _onMarkerTapped(TripPlace place, List<TripPlace> filteredPlaces) {
    final targetIndex = filteredPlaces.indexWhere((p) => p.id == place.id);
    if (targetIndex != -1) {
      _selectedPlaceIdNotifier.value = place.id;
      _currentCarouselIndex = targetIndex;

      _animatedMapMove(LatLng(place.latitude, place.longitude), 14.5);

      if (_pageController != null && _pageController!.hasClients) {
        _pageController!.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _onCarouselPageChanged(int index, List<TripPlace> filteredPlaces) {
    if (index >= 0 && index < filteredPlaces.length) {
      final place = filteredPlaces[index];
      if (_selectedPlaceIdNotifier.value != place.id ||
          _currentCarouselIndex != index) {
        _selectedPlaceIdNotifier.value = place.id;
        _currentCarouselIndex = index;
        _animatedMapMove(LatLng(place.latitude, place.longitude), 14.5);
      }
    }
  }

  void _goToIndex(int targetIndex, List<TripPlace> filteredPlaces) {
    if (targetIndex < 0 || targetIndex >= filteredPlaces.length) return;
    final place = filteredPlaces[targetIndex];
    _selectedPlaceIdNotifier.value = place.id;
    _currentCarouselIndex = targetIndex;
    _animatedMapMove(LatLng(place.latitude, place.longitude), 14.5);
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _fitAllPlaces(List<TripPlace> places) {
    if (places.isEmpty) return;

    if (places.length == 1) {
      _animatedMapMove(
        LatLng(places.first.latitude, places.first.longitude),
        13.5,
      );
      return;
    }

    final points = places.map((p) => LatLng(p.latitude, p.longitude)).toList();
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 100.h,
            bottom: MediaQuery.paddingOf(context).bottom + 180.h,
            left: 36.w,
            right: 36.w,
          ),
          maxZoom: 14.0,
        ),
      );
    } catch (_) {
      // Fallback center calculation
      double minLat = places.first.latitude;
      double maxLat = places.first.latitude;
      double minLng = places.first.longitude;
      double maxLng = places.first.longitude;
      for (final p in places) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      _animatedMapMove(center, 11.0);
    }
  }

  void _showAllPlacesListSheet(
    BuildContext context,
    List<TripPlace> places,
    Map<String, TripAlbum> albumMap,
    Map<String, List<PlaceMediaFile>> mediaByPlace,
  ) {
    final colors = context.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.88,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.5.h,
                      decoration: BoxDecoration(
                        color: colors.borderDivider,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explored Footprints',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              '${places.length} places recorded across journeys',
                              style: context.textTheme.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colors.borderDivider.withValues(alpha: 0.6)),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      itemCount: places.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (_, idx) {
                        final p = places[idx];
                        final album = albumMap[p.albumId];
                        final photos = mediaByPlace[p.id] ?? [];
                        final hasPhoto =
                            photos.isNotEmpty &&
                            File(photos.first.localFilePath).existsSync();

                        return InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _onMarkerTapped(p, places);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: p.id == _selectedPlaceId
                                    ? const Color(0xFFC89D3C)
                                    : colors.borderDivider.withValues(
                                        alpha: 0.6,
                                      ),
                                width: p.id == _selectedPlaceId ? 1.6 : 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Container(
                                    width: 52.w,
                                    height: 52.w,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                        p.category,
                                      ).withValues(alpha: 0.15),
                                    ),
                                    child: hasPhoto
                                        ? Image.file(
                                            File(photos.first.localFilePath),
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            _getCategoryIcon(p.category),
                                            color: _getCategoryColor(
                                              p.category,
                                            ),
                                            size: 24.sp,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.textPrimary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        album?.title ??
                                            DateFormat(
                                              'MMM d, yyyy',
                                            ).format(p.visitedAt),
                                        style: context.textTheme.caption
                                            .copyWith(
                                              color: colors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14.sp,
                                  color: colors.textSecondary,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    final colors = context.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: WaymarkLiquidGlassAppBar(
        showBrandMasthead: true,
        sectionName: context.l10n.navExplore,
        backgroundColor: colors.surfaceCard,
        backgroundAlpha: 0.90,
        actions: [
          StreamBuilder<List<TripPlace>>(
            stream: _placesStream,
            builder: (context, snapshot) {
              final places = snapshot.data ?? [];
              if (places.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: const Icon(Icons.center_focus_strong_rounded),
                  tooltip: 'Fit All Explored Places',
                  iconSize: 22.sp,
                  color: const Color(0xFFC89D3C),
                  onPressed: () {
                    final selectedCategory = _selectedCategoryNotifier.value;
                    final filtered = selectedCategory == 'ALL'
                        ? places
                        : places
                              .where(
                                (p) =>
                                    p.category.toUpperCase() ==
                                    selectedCategory,
                              )
                              .toList();
                    _fitAllPlaces(filtered.isNotEmpty ? filtered : places);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TripAlbum>>(
        stream: _albumsStream,
        builder: (context, albumSnapshot) {
          final albums = albumSnapshot.data ?? [];

          if (albumSnapshot.connectionState == ConnectionState.waiting &&
              albums.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (albums.isEmpty) {
            return Center(
              child: WaymarkAnimatedEntrance(
                child: WaymarkArtisticEmptyState(
                  badgeText: context.l10n.exploreBadgeUnmapped,
                  icon: Icons.map_rounded,
                  title: context.l10n.emptyExploreTitle,
                  description: context.l10n.emptyExploreDesc,
                  buttonLabel: context.l10n.emptyExploreBtn,
                  onButtonPressed: () => CreateJourneyBottomSheet.show(context),
                ),
              ),
            );
          }

          final albumMap = {for (final a in albums) a.id: a};

          return StreamBuilder<List<TripPlace>>(
            stream: _placesStream,
            builder: (context, placeSnapshot) {
              final allPlaces = placeSnapshot.data ?? [];

              if (placeSnapshot.connectionState == ConnectionState.waiting &&
                  allPlaces.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (allPlaces.isEmpty) {
                return Center(
                  child: WaymarkAnimatedEntrance(
                    child: WaymarkArtisticEmptyState(
                      badgeText: context.l10n.exploreBadgeUnmapped,
                      icon: Icons.explore_rounded,
                      title: 'No Explored Footprints Yet',
                      description:
                          'Start documenting your adventures by adding places to your journey albums.',
                      buttonLabel: 'Log First Place',
                      onButtonPressed: () {
                        if (albums.isNotEmpty) {
                          PlaceLoggerBottomSheet.show(
                            context,
                            albumId: albums.first.id,
                            albumTitle: albums.first.title,
                          );
                        } else {
                          CreateJourneyBottomSheet.show(context);
                        }
                      },
                    ),
                  ),
                );
              }

              return ValueListenableBuilder<String>(
                valueListenable: _selectedCategoryNotifier,
                builder: (context, selectedCategory, _) {
                  final filteredPlaces = selectedCategory == 'ALL'
                      ? allPlaces
                      : allPlaces
                            .where(
                              (p) =>
                                  p.category.toUpperCase() == selectedCategory,
                            )
                            .toList();

                  final placeIds = allPlaces.map((p) => p.id).toList();

                  return StreamBuilder<List<PlaceMediaFile>>(
                    stream: db.placeMediaDao.watchMediaForPlaces(placeIds),
                    builder: (context, mediaSnapshot) {
                      final mediaList = mediaSnapshot.data ?? [];
                      final mediaByPlace = <String, List<PlaceMediaFile>>{};
                      for (final m in mediaList) {
                        mediaByPlace.putIfAbsent(m.placeId, () => []).add(m);
                      }

                      final points = allPlaces
                          .map((p) => LatLng(p.latitude, p.longitude))
                          .toList();
                      final initialCenter = points.isNotEmpty
                          ? points.first
                          : const LatLng(35.0, 135.0);

                      return ValueListenableBuilder<String?>(
                        valueListenable: _selectedPlaceIdNotifier,
                        builder: (context, selectedPlaceId, _) {
                          final effectiveSelectedPlaceId =
                              selectedPlaceId ??
                              (filteredPlaces.isNotEmpty
                                  ? filteredPlaces.first.id
                                  : null);

                          return Stack(
                            children: [
                              // Fullscreen Interactive OpenStreetMap
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCameraFit: points.length > 1
                                      ? CameraFit.bounds(
                                          bounds: LatLngBounds.fromPoints(
                                            points,
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 140.h,
                                            bottom: 270.h,
                                            left: 45.w,
                                            right: 45.w,
                                          ),
                                          maxZoom: 13.5,
                                        )
                                      : null,
                                  initialCenter: initialCenter,
                                  initialZoom: 12.5,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'app.waymark.journal',
                                  ),
                                  MarkerLayer(
                                    markers: filteredPlaces.map((place) {
                                      final isSelected =
                                          place.id == effectiveSelectedPlaceId;
                                      final coord = _getDisplacedPoint(
                                        place,
                                        filteredPlaces,
                                      );
                                      return Marker(
                                        point: coord,
                                        width: 50.w,
                                        height: 50.w,
                                        child: GestureDetector(
                                          onTap: () => _onMarkerTapped(
                                            place,
                                            filteredPlaces,
                                          ),
                                          child: _buildArtisticMapMarker(
                                            context: context,
                                            place: place,
                                            isSelected: isSelected,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),

                              // Floating Top Category Filter Bar (Brighter Liquid Glass)
                              Positioned(
                                top: MediaQuery.paddingOf(context).top + 56.h,
                                left: 0,
                                right: 0,
                                child: _buildCategoryFilterBar(
                                  context,
                                  allPlaces,
                                  selectedCategory,
                                ),
                              ),

                              // Floating Zoom and Recenter Controls (Right Edge)
                              Positioned(
                                right: 14.w,
                                top: MediaQuery.paddingOf(context).top + 110.h,
                                child: _buildMapControls(
                                  context,
                                  filteredPlaces.isNotEmpty
                                      ? filteredPlaces
                                      : allPlaces,
                                ),
                              ),

                              // Floating Summary & View All List Button (Top Left)
                              Positioned(
                                left: 14.w,
                                top: MediaQuery.paddingOf(context).top + 110.h,
                                child: _buildSummaryCapsule(
                                  context,
                                  filteredPlaces.length,
                                  () => _showAllPlacesListSheet(
                                    context,
                                    filteredPlaces,
                                    albumMap,
                                    mediaByPlace,
                                  ),
                                ),
                              ),

                              // Floating Place Cards Carousel (Bottom)
                              if (filteredPlaces.isNotEmpty)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom:
                                      MediaQuery.paddingOf(context).bottom +
                                      18.h,
                                  child: _buildPlacesCarousel(
                                    context: context,
                                    places: filteredPlaces,
                                    albumMap: albumMap,
                                    mediaByPlace: mediaByPlace,
                                    selectedPlaceId: effectiveSelectedPlaceId,
                                    onOpenList: () => _showAllPlacesListSheet(
                                      context,
                                      filteredPlaces,
                                      albumMap,
                                      mediaByPlace,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCapsule(
    BuildContext context,
    int placesCount,
    VoidCallback onOpenList,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onOpenList,
        child: WaymarkLiquidGlass(
          blurSigma: 10.0,
          tintAlpha: 0.82,
          tintColor: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          border: Border.all(
            color: const Color(0xFFC89D3C).withValues(alpha: 0.65),
            width: 1.0,
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_outlined,
                size: 14.sp,
                color: const Color(0xFFC89D3C),
              ),
              SizedBox(width: 6.w),
              Text(
                '$placesCount ${placesCount == 1 ? "footprint" : "footprints"}',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  color: const Color(0xFF1B2A1E),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.list_rounded,
                size: 14.sp,
                color: const Color(0xFF4A5D4E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar(
    BuildContext context,
    List<TripPlace> allPlaces,
    String selectedCategory,
  ) {
    final counts = <String, int>{'ALL': allPlaces.length};
    for (final p in allPlaces) {
      final cat = p.category.toUpperCase();
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = selectedCategory == cat;
          final count = counts[cat] ?? 0;
          if (cat != 'ALL' && count == 0) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () {
                  final filtered = cat == 'ALL'
                      ? allPlaces
                      : allPlaces
                            .where((p) => p.category.toUpperCase() == cat)
                            .toList();
                  _selectedCategoryNotifier.value = cat;
                  _selectedPlaceIdNotifier.value = filtered.isNotEmpty
                      ? filtered.first.id
                      : null;
                  _currentCarouselIndex = 0;
                  if (_pageController != null && _pageController!.hasClients) {
                    _pageController!.jumpToPage(0);
                  }
                  if (filtered.isNotEmpty) {
                    _fitAllPlaces(filtered);
                  }
                },
                child: WaymarkLiquidGlass(
                  blurSigma: 10.0,
                  tintAlpha: isSelected ? 0.94 : 0.82,
                  tintColor: isSelected
                      ? const Color(0xFFFFF7DB)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFC89D3C)
                        : Colors.white.withValues(alpha: 0.8),
                    width: isSelected ? 1.5 : 0.9,
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat != 'ALL') ...[
                        Icon(
                          _getCategoryIcon(cat),
                          size: 13.sp,
                          color: isSelected
                              ? const Color(0xFF8C6615)
                              : const Color(0xFF4A5D4E),
                        ),
                        SizedBox(width: 5.w),
                      ],
                      Text(
                        cat,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 10.5.sp,
                          color: isSelected
                              ? const Color(0xFF8C6615)
                              : const Color(0xFF1B2A1E),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFC89D3C).withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$count',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF8C6615)
                                : const Color(0xFF4A5D4E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapControls(BuildContext context, List<TripPlace> places) {
    return WaymarkLiquidGlass(
      blurSigma: 10.0,
      tintAlpha: 0.82,
      tintColor: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.8),
        width: 1.0,
      ),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Zoom In',
            iconSize: 20.sp,
            color: const Color(0xFF1B2A1E),
            constraints: BoxConstraints.tight(Size(36.w, 36.w)),
            padding: EdgeInsets.zero,
            onPressed: () {
              final newZoom = (_mapController.camera.zoom + 1).clamp(3.0, 18.0);
              _animatedMapMove(_mapController.camera.center, newZoom);
            },
          ),
          Container(
            width: 24.w,
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            tooltip: 'Zoom Out',
            iconSize: 20.sp,
            color: const Color(0xFF1B2A1E),
            constraints: BoxConstraints.tight(Size(36.w, 36.w)),
            padding: EdgeInsets.zero,
            onPressed: () {
              final newZoom = (_mapController.camera.zoom - 1).clamp(3.0, 18.0);
              _animatedMapMove(_mapController.camera.center, newZoom);
            },
          ),
          Container(
            width: 24.w,
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Recenter on Footprints',
            iconSize: 18.sp,
            color: const Color(0xFFC89D3C),
            constraints: BoxConstraints.tight(Size(36.w, 36.w)),
            padding: EdgeInsets.zero,
            onPressed: () => _fitAllPlaces(places),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisticMapMarker({
    required BuildContext context,
    required TripPlace place,
    required bool isSelected,
  }) {
    final brassBorderColor = isSelected
        ? const Color(0xFFFFD54F)
        : Colors.white;
    final categoryColor = _getCategoryColor(place.category);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer glowing pulse halo when selected
        if (isSelected)
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD54F).withValues(alpha: 0.45),
            ),
          ),

        // Antique Brass & Jewel Seal Medallion
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isSelected
                  ? [categoryColor, categoryColor.withValues(alpha: 0.85)]
                  : [categoryColor, categoryColor.withValues(alpha: 0.78)],
            ),
            border: Border.all(
              color: brassBorderColor,
              width: isSelected ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            _getCategoryIcon(place.category),
            size: 17.sp,
            color: Colors.white,
          ),
        ),

        // Cardinal North Tick mark
        Positioned(
          top: 3.h,
          child: Container(
            width: 2.2.w,
            height: 3.5.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesCarousel({
    required BuildContext context,
    required List<TripPlace> places,
    required Map<String, TripAlbum> albumMap,
    required Map<String, List<PlaceMediaFile>> mediaByPlace,
    required String? selectedPlaceId,
    required VoidCallback onOpenList,
  }) {
    final selectedIndex = places.indexWhere((p) => p.id == selectedPlaceId);
    final currentIndex = selectedIndex != -1
        ? selectedIndex
        : _currentCarouselIndex.clamp(0, places.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation & Indicator Bar above card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Footprint X of Y Badge
              Flexible(
                child: WaymarkLiquidGlass(
                  blurSigma: 8.0,
                  tintAlpha: 0.82,
                  tintColor: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  border: Border.all(
                    color: const Color(0xFFC89D3C).withValues(alpha: 0.65),
                    width: 1.0,
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pin_drop_rounded,
                        size: 12.sp,
                        color: const Color(0xFFC89D3C),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          'Footprint ${currentIndex + 1} of ${places.length}',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5.sp,
                            color: const Color(0xFF1B2A1E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Controls: Prev, Next, View All List, Hide Toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous arrow button
                  _buildMiniCircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Previous Footprint',
                    onTap: currentIndex > 0
                        ? () => _goToIndex(currentIndex - 1, places)
                        : null,
                  ),
                  SizedBox(width: 4.w),
                  // Next arrow button
                  _buildMiniCircleButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Next Footprint',
                    onTap: currentIndex < places.length - 1
                        ? () => _goToIndex(currentIndex + 1, places)
                        : null,
                  ),
                  SizedBox(width: 6.w),
                  // View All List button
                  GestureDetector(
                    onTap: onOpenList,
                    child: WaymarkLiquidGlass(
                      blurSigma: 8.0,
                      tintAlpha: 0.82,
                      tintColor: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 13.sp,
                            color: const Color(0xFF2C6E49),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'All (${places.length})',
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B2A1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        // PageView of place cards
        SizedBox(
          height: 148.h,
          child: ScrollConfiguration(
            behavior: const WaymarkNoOverscrollScrollBehavior(),
            child: PageView.builder(
              controller:
                  _pageController ??
                  PageController(
                    initialPage: currentIndex,
                    viewportFraction: 0.90,
                  ),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: places.length,
              onPageChanged: (idx) => _onCarouselPageChanged(idx, places),
              itemBuilder: (context, index) {
                final place = places[index];
                final album = albumMap[place.albumId];
                final photos = mediaByPlace[place.id] ?? [];
                final isSelected = place.id == selectedPlaceId;

                return _buildCarouselPlaceCard(
                  key: ValueKey(place.id),
                  context: context,
                  place: place,
                  album: album,
                  photos: photos,
                  isSelected: isSelected,
                  onTap: () {
                    if (_selectedPlaceId != place.id) {
                      _goToIndex(index, places);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: WaymarkLiquidGlass(
          blurSigma: 8.0,
          tintAlpha: isEnabled ? 0.82 : 0.45,
          tintColor: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          padding: EdgeInsets.all(5.w),
          border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
          child: Icon(
            icon,
            size: 15.sp,
            color: isEnabled
                ? const Color(0xFF1B2A1E)
                : const Color(0xFFA0AAB0),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselPlaceCard({
    Key? key,
    required BuildContext context,
    required TripPlace place,
    required TripAlbum? album,
    required List<PlaceMediaFile> photos,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final colors = context.colorScheme;
    final photo = photos.isNotEmpty ? photos.first : null;
    final hasLocalImage =
        photo != null && File(photo.localFilePath).existsSync();

    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: onTap,
        child: WaymarkLiquidGlass(
          blurSigma: 10.0,
          tintAlpha: 0.82,
          tintColor: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.0,
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail / Bright Category Icon Box
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 78.w,
                  height: 110.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C6E49), Color(0xFF4E9F6E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: hasLocalImage
                      ? Image.file(
                          File(photo.localFilePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildCategoryFallbackIcon(place.category),
                        )
                      : _buildCategoryFallbackIcon(place.category),
                ),
              ),

              SizedBox(width: 12.w),

              // Place Details & Action Buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badges: Album name & Category
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(
                                0xFFC89D3C,
                              ).withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            place.category.toUpperCase(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF7A5600),
                              fontWeight: FontWeight.bold,
                              fontSize: 8.5.sp,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (album != null) ...[
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              album.title,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF4A5D4E),
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 5.h),

                    // Place Title
                    Text(
                      place.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5.sp,
                        color: const Color(0xFF1B2A1E),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2.h),

                    // Address / Date Subtitle
                    Row(
                      children: [
                        Icon(
                          place.locationAddress != null &&
                                  place.locationAddress!.isNotEmpty
                              ? Icons.place_outlined
                              : Icons.calendar_today_outlined,
                          size: 11.sp,
                          color: const Color(0xFF4A5D4E),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            place.locationAddress != null &&
                                    place.locationAddress!.isNotEmpty
                                ? place.locationAddress!
                                : DateFormat(
                                    'MMM d, yyyy',
                                  ).format(place.visitedAt),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4A5D4E),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Action Buttons Row
                    Row(
                      children: [
                        // View / Edit Memories
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 4.h,
                              ),
                              minimumSize: Size(0, 30.h),
                              side: BorderSide(
                                color: const Color(
                                  0xFF2C6E49,
                                ).withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.edit_note_rounded,
                              size: 14.sp,
                              color: colors.primary,
                            ),
                            label: Text(
                              'Memories',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1B2A1E),
                              ),
                            ),
                            onPressed: () {
                              if (album != null) {
                                PlaceLoggerBottomSheet.show(
                                  context,
                                  albumId: album.id,
                                  albumTitle: album.title,
                                  placeToEdit: place,
                                );
                              }
                            },
                          ),
                        ),

                        if (album != null) ...[
                          SizedBox(width: 6.w),
                          // Open Journey
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 4.h,
                                ),
                                minimumSize: Size(0, 30.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              icon: Icon(Icons.explore_rounded, size: 13.sp),
                              label: Text(
                                'Journey',
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => JourneyAlbumDetailScreen(
                                      journeyId: album.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFallbackIcon(String category) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 28.sp,
            color: const Color(0xFFFFF9E6),
          ),
          SizedBox(height: 4.h),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFFFFF9E6).withValues(alpha: 0.85),
              fontSize: 7.5.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
