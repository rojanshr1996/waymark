import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/theme/waymark_colors.dart';

import '../../domain/models/postcard_enums.dart';

class PostcardCanvasWidget extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;
  final TripAlbum album;
  final List<TripPlace> places;
  final Map<String, List<PlaceMediaFile>> placeMediaMap;
  final PostcardAestheticStyle style;
  final PostcardRatio ratio;
  final bool showMapRoute;
  final bool showWeather;
  final bool isQuadPhotoLayout;

  const PostcardCanvasWidget({
    super.key,
    required this.repaintBoundaryKey,
    required this.album,
    required this.places,
    required this.placeMediaMap,
    required this.style,
    required this.ratio,
    required this.showMapRoute,
    required this.showWeather,
    required this.isQuadPhotoLayout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final canvasBg = style.getCanvasBackgroundColor(colors);
    final cardBg = style.getCardBackgroundColor(colors);
    final textCol = style.getTextColor(colors);
    final subtextCol = style.getSubtextColor(colors);
    final accentCol = style.getAccentColor(colors);

    // Compute metrics
    final totalDistance = album.totalDistanceKm > 0
        ? album.totalDistanceKm
        : _calculateFallbackDistance();
    final placesCount = places.isNotEmpty
        ? places.length
        : album.totalPlacesCount;
    final durationDays = _calculateTripDurationDays();
    final avgTemp = _calculateAverageTemperature();
    final weatherSummary = _resolveWeatherSummary();

    // Stops trail string
    final stopsTrail = _generateStopsTrail();

    // Unique serial code based on album id
    final serialCode = 'NO. ${(album.id.hashCode.abs() % 900 + 100)}';

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: ratio.targetWidthConstraint.w,
        child: RepaintBoundary(
          key: repaintBoundaryKey,
          child: Container(
            decoration: BoxDecoration(
              color: canvasBg,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: style.isDark ? 0.35 : 0.12,
                  ),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            padding: EdgeInsets.all(10.w),
            child: Stack(
              children: [
                // Outer decorative dashed border
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: style.getBorderColor(colors),
                        strokeWidth: 1.5,
                        dashLength: 5,
                        gapLength: 4,
                        radius: 12.r,
                      ),
                    ),
                  ),
                ),

                // Canvas content with ample breathing padding from the dotted border
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Postcard Header
                      _buildHeader(
                        context,
                        accentCol: accentCol,
                        textCol: textCol,
                        subtextCol: subtextCol,
                        cardBg: cardBg,
                        stopsTrail: stopsTrail,
                        serialCode: serialCode,
                      ),

                      // 2. Mini Map & Route Visualizer (Toggleable)
                      if (showMapRoute) ...[
                        SizedBox(height: 10.h),
                        _buildRouteMap(context, accentCol: accentCol),
                      ],

                      // 3. Polaroid Photo Stage (Dynamic 1-4 polaroids)
                      SizedBox(height: 12.h),
                      _buildPhotoStage(
                        context,
                        cardBg: cardBg,
                        textCol: textCol,
                        subtextCol: subtextCol,
                        accentCol: accentCol,
                      ),

                      // 4. Summary Stats Bar (Balanced 3-column metrics without elevation)
                      SizedBox(height: 12.h),
                      _buildStatsBar(
                        context,
                        cardBg: cardBg,
                        textCol: textCol,
                        subtextCol: subtextCol,
                        accentCol: accentCol,
                        totalDistance: totalDistance,
                        placesCount: placesCount,
                        durationDays: durationDays,
                      ),

                      // 5. Ambient Weather Banner (Toggleable)
                      if (showWeather) ...[
                        SizedBox(height: 8.h),
                        _buildWeatherBanner(
                          context,
                          cardBg: cardBg,
                          textCol: textCol,
                          subtextCol: subtextCol,
                          accentCol: accentCol,
                          avgTemp: avgTemp,
                          weatherSummary: weatherSummary,
                        ),
                      ],

                      // 6. Postcard Footer & Memoir Seal
                      SizedBox(height: 10.h),
                      _buildFooter(
                        context,
                        accentCol: accentCol,
                        textCol: textCol,
                        subtextCol: subtextCol,
                        cardBg: cardBg,
                        serialCode: serialCode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required Color accentCol,
    required Color textCol,
    required Color subtextCol,
    required Color cardBg,
    required String stopsTrail,
    required String serialCode,
  }) {
    final dateStr = DateFormat('MMM yyyy').format(album.startDate);

    return Container(
      padding: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: subtextCol.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WAYMARK JOURNEY POSTCARD',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: accentCol,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  stopsTrail.isNotEmpty
                      ? '$stopsTrail • $dateStr'
                      : '${album.title} • $dateStr',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: subtextCol,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4.r,
                  offset: Offset(0, 1.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 11.sp, color: accentCol),
                SizedBox(width: 3.w),
                Text(
                  serialCode,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: textCol,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMap(BuildContext context, {required Color accentCol}) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: style.isDark ? const Color(0xFF131815) : const Color(0xFFEFF3EF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: style
              .getBorderColor(context.colorScheme)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // Background grid lines
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(
                gridColor: style.isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Dynamic route path & checkpoint dots
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePolylinePainter(
                places: places,
                accentColor: accentCol,
                style: style,
                albumId: album.id,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds photo stage dynamically matching the polaroid aesthetic for 1, 2, 3, or 4 photos
  Widget _buildPhotoStage(
    BuildContext context, {
    required Color cardBg,
    required Color textCol,
    required Color subtextCol,
    required Color accentCol,
  }) {
    final availablePlaces = places;
    final maxTarget = isQuadPhotoLayout ? 4 : 2;
    final count = availablePlaces.length.clamp(0, maxTarget);

    if (count <= 1) {
      // 1 Centered Polaroid
      final place = availablePlaces.isNotEmpty ? availablePlaces.first : null;
      final media = place != null
          ? (placeMediaMap[place.id] ?? [])
          : <PlaceMediaFile>[];

      return SizedBox(
        height: 155.h,
        child: Center(
          child: _buildPolaroidCard(
            place: place,
            mediaFiles: media,
            cardBg: cardBg,
            textCol: textCol,
            subtextCol: subtextCol,
            accentCol: accentCol,
            defaultName: album.title,
            defaultSubtitle: 'Journey Waypoint',
            width: 170.w,
            photoHeight: 95.h,
          ),
        ),
      );
    } else if (count == 2) {
      // 2 Overlapping Polaroids
      final p1 = availablePlaces[0];
      final p2 = availablePlaces[1];
      final m1 = placeMediaMap[p1.id] ?? [];
      final m2 = placeMediaMap[p2.id] ?? [];

      return SizedBox(
        height: 155.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 2.w,
              top: 4.h,
              child: Transform.rotate(
                angle: -0.06,
                child: _buildPolaroidCard(
                  place: p1,
                  mediaFiles: m1,
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p1.name,
                  defaultSubtitle: 'Waypoint #1',
                  width: 140.w,
                  photoHeight: 85.h,
                ),
              ),
            ),
            Positioned(
              right: 2.w,
              top: 8.h,
              child: Transform.rotate(
                angle: 0.06,
                child: _buildPolaroidCard(
                  place: p2,
                  mediaFiles: m2,
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p2.name,
                  defaultSubtitle: 'Waypoint #2',
                  width: 140.w,
                  photoHeight: 85.h,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (count == 3) {
      // 3 Cascading Polaroids
      final p1 = availablePlaces[0];
      final p2 = availablePlaces[1];
      final p3 = availablePlaces[2];

      return SizedBox(
        height: 155.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 8.h,
              child: Transform.rotate(
                angle: -0.08,
                child: _buildPolaroidCard(
                  place: p1,
                  mediaFiles: placeMediaMap[p1.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p1.name,
                  defaultSubtitle: 'Stop #1',
                  width: 110.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
            Positioned(
              top: 2.h,
              child: _buildPolaroidCard(
                place: p2,
                mediaFiles: placeMediaMap[p2.id] ?? [],
                cardBg: cardBg,
                textCol: textCol,
                subtextCol: subtextCol,
                accentCol: accentCol,
                defaultName: p2.name,
                defaultSubtitle: 'Stop #2',
                width: 115.w,
                photoHeight: 75.h,
              ),
            ),
            Positioned(
              right: 0,
              top: 8.h,
              child: Transform.rotate(
                angle: 0.08,
                child: _buildPolaroidCard(
                  place: p3,
                  mediaFiles: placeMediaMap[p3.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p3.name,
                  defaultSubtitle: 'Stop #3',
                  width: 110.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 4 Overlapping Polaroids (Artistic 2x2 Polaroids collage)
      final p1 = availablePlaces[0];
      final p2 = availablePlaces[1];
      final p3 = availablePlaces[2];
      final p4 = availablePlaces[3];

      return SizedBox(
        height: 200.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Left
            Positioned(
              left: 2.w,
              top: 2.h,
              child: Transform.rotate(
                angle: -0.05,
                child: _buildPolaroidCard(
                  place: p1,
                  mediaFiles: placeMediaMap[p1.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p1.name,
                  defaultSubtitle: 'Stop #1',
                  width: 135.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
            // Top Right
            Positioned(
              right: 2.w,
              top: 6.h,
              child: Transform.rotate(
                angle: 0.05,
                child: _buildPolaroidCard(
                  place: p2,
                  mediaFiles: placeMediaMap[p2.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p2.name,
                  defaultSubtitle: 'Stop #2',
                  width: 135.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
            // Bottom Left
            Positioned(
              left: 6.w,
              bottom: 2.h,
              child: Transform.rotate(
                angle: 0.04,
                child: _buildPolaroidCard(
                  place: p3,
                  mediaFiles: placeMediaMap[p3.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p3.name,
                  defaultSubtitle: 'Stop #3',
                  width: 135.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
            // Bottom Right
            Positioned(
              right: 6.w,
              bottom: 0,
              child: Transform.rotate(
                angle: -0.04,
                child: _buildPolaroidCard(
                  place: p4,
                  mediaFiles: placeMediaMap[p4.id] ?? [],
                  cardBg: cardBg,
                  textCol: textCol,
                  subtextCol: subtextCol,
                  accentCol: accentCol,
                  defaultName: p4.name,
                  defaultSubtitle: 'Stop #4',
                  width: 135.w,
                  photoHeight: 70.h,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPolaroidCard({
    required TripPlace? place,
    required List<PlaceMediaFile> mediaFiles,
    required Color cardBg,
    required Color textCol,
    required Color subtextCol,
    required Color accentCol,
    required String defaultName,
    required String defaultSubtitle,
    required double width,
    required double photoHeight,
  }) {
    final placeName = place?.name ?? defaultName;
    final placeNote = (place?.notes?.isNotEmpty ?? false)
        ? place!.notes!
        : (place?.locationAddress ?? defaultSubtitle);

    final localPath = mediaFiles.isNotEmpty
        ? (mediaFiles.first.thumbnailPath.isNotEmpty
              ? mediaFiles.first.thumbnailPath
              : mediaFiles.first.localFilePath)
        : null;

    return Container(
      width: width,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 7.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              height: photoHeight,
              width: double.infinity,
              color: style.isDark
                  ? const Color(0xFF1B221E)
                  : const Color(0xFFE9ECEF),
              child: localPath != null && File(localPath).existsSync()
                  ? Image.file(
                      File(localPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _buildFallbackPhotoArtwork(placeName, accentCol),
                    )
                  : _buildFallbackPhotoArtwork(placeName, accentCol),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: textCol,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  placeNote,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 7.5.sp,
                    fontStyle: FontStyle.italic,
                    color: subtextCol,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPhotoArtwork(String name, Color accentCol) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentCol.withValues(alpha: 0.8),
            accentCol.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_rounded, size: 18.sp, color: Colors.white),
            SizedBox(height: 2.h),
            Text(
              name.split(' ').first,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Clean 3-column stats bar without elevation info
  Widget _buildStatsBar(
    BuildContext context, {
    required Color cardBg,
    required Color textCol,
    required Color subtextCol,
    required Color accentCol,
    required double totalDistance,
    required int placesCount,
    required int durationDays,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'DIST',
            '${totalDistance.toStringAsFixed(1)} km',
            accentCol,
            subtextCol,
          ),
          _buildDivider(subtextCol),
          _buildStatItem(
            'STOPS',
            '$placesCount ${placesCount == 1 ? 'Mark' : 'Marks'}',
            textCol,
            subtextCol,
          ),
          _buildDivider(subtextCol),
          _buildStatItem(
            'SPAN',
            '$durationDays ${durationDays == 1 ? 'Day' : 'Days'}',
            textCol,
            subtextCol,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    Color subtextCol,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 7.5.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: subtextCol,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color subtextCol) {
    return Container(
      height: 18.h,
      width: 1,
      color: subtextCol.withValues(alpha: 0.15),
    );
  }

  Widget _buildWeatherBanner(
    BuildContext context, {
    required Color cardBg,
    required Color textCol,
    required Color subtextCol,
    required Color accentCol,
    required double avgTemp,
    required String weatherSummary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: subtextCol.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                size: 13.sp,
                color: const Color(0xFFFFB703),
              ),
              SizedBox(width: 4.w),
              Text(
                'Avg ${avgTemp.toStringAsFixed(0)}°C • $weatherSummary',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
            ],
          ),
          Text(
            'EXIF Synced',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 7.5.sp,
              fontWeight: FontWeight.w500,
              color: subtextCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context, {
    required Color accentCol,
    required Color textCol,
    required Color subtextCol,
    required Color cardBg,
    required String serialCode,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: subtextCol.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: accentCol.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentCol.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'WM',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w800,
                      color: accentCol,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WayMark Travel Memoir',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w700,
                      color: textCol,
                    ),
                  ),
                  Text(
                    'Field Journal Collection • Authenticated Memoir',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 7.sp,
                      color: subtextCol,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Stylized QR Matrix Block
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: subtextCol.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_2_rounded, size: 16.sp, color: textCol),
                SizedBox(width: 2.w),
                Text(
                  'WAYMARK\nMEMOIR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 5.5.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: subtextCol,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper calculations
  double _calculateFallbackDistance() {
    if (places.length < 2) return 0.0;
    return (places.length * 14.5);
  }

  int _calculateTripDurationDays() {
    final end =
        album.endDate ??
        (places.isNotEmpty ? places.last.visitedAt : DateTime.now());
    final diff = end.difference(album.startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  double _calculateAverageTemperature() {
    final temps = places
        .where((p) => p.temperatureCelsius != null)
        .map((p) => p.temperatureCelsius!)
        .toList();
    if (temps.isEmpty) return 21.0;
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  String _resolveWeatherSummary() {
    final conditions = places
        .where(
          (p) => p.weatherCondition != null && p.weatherCondition!.isNotEmpty,
        )
        .map((p) => p.weatherCondition!)
        .toList();
    if (conditions.isEmpty) return 'Mild Journey Atmosphere';
    return conditions.first;
  }

  String _generateStopsTrail() {
    if (places.isEmpty) return album.title;
    final names = places.map((p) => p.name.split(' ').first).take(3).toList();
    return names.join(' • ');
  }
}

/// Painter for drawing subtle background coordinate grid
class _MapGridPainter extends CustomPainter {
  final Color gridColor;

  _MapGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}

/// Painter for drawing stylized route curve and checkpoints
class _RoutePolylinePainter extends CustomPainter {
  final List<TripPlace> places;
  final Color accentColor;
  final PostcardAestheticStyle style;
  final String albumId;

  _RoutePolylinePainter({
    required this.places,
    required this.accentColor,
    required this.style,
    required this.albumId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final design = albumId.hashCode.abs() % 4;
    if (places.isEmpty) return;

    final points = _buildRoutePoints(size, places.length, design);

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var index = 1; index < points.length; index++) {
        final previous = points[index - 1];
        final current = points[index];
        final controlX = (previous.dx + current.dx) / 2;
        final controlY = design.isEven
            ? (previous.dy < current.dy
                  ? previous.dy - h * 0.28
                  : previous.dy + h * 0.28)
            : (previous.dy < current.dy
                  ? previous.dy + h * 0.28
                  : previous.dy - h * 0.28);
        path.quadraticBezierTo(controlX, controlY, current.dx, current.dy);
      }

      final dashPaint = Paint()
        ..color = accentColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(
        canvas,
        path,
        dashPaint,
        design.isEven ? 4.0 : 7.0,
        design.isEven ? 3.0 : 4.0,
      );
    }

    for (var index = 0; index < points.length; index++) {
      final color = index == 0
          ? const Color(0xFF3B82F6)
          : index == points.length - 1
          ? const Color(0xFFF43F5E)
          : const Color(0xFF8B5CF6);
      final place = places[index];
      _drawStopMarker(
        canvas,
        points[index],
        color,
        place.name,
        isTop: points[index].dy < h * 0.35,
        maxLabelWidth: w * 0.42,
      );
    }
  }

  List<Offset> _buildRoutePoints(Size size, int count, int design) {
    if (count == 1) return [Offset(size.width * 0.5, size.height * 0.5)];

    const patterns = [
      [0.72, 0.32, 0.24, 0.58, 0.35],
      [0.24, 0.72, 0.34, 0.18, 0.62],
      [0.50, 0.22, 0.70, 0.30, 0.60],
      [0.30, 0.58, 0.22, 0.70, 0.38],
    ];
    final pattern = patterns[design];

    return List.generate(count, (index) {
      final progress = index / (count - 1);
      final x = size.width * (0.14 + (0.72 * progress));
      final y = size.height * pattern[index % pattern.length];
      return Offset(x, y);
    });
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawStopMarker(
    Canvas canvas,
    Offset point,
    Color color,
    String label, {
    required bool isTop,
    required double maxLabelWidth,
  }) {
    // Outer glow circle
    final outerPaint = Paint()..color = color.withValues(alpha: 0.25);
    canvas.drawCircle(point, 9.0, outerPaint);

    // Inner solid circle
    final innerPaint = Paint()..color = color;
    canvas.drawCircle(point, 4.5, innerPaint);

    // Label
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 8.sp,
        fontWeight: FontWeight.w700,
        color: style.isDark ? const Color(0xFFF0F5F0) : const Color(0xFF181D1A),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxLabelWidth);

    final textOffset = Offset(
      point.dx - (textPainter.width / 2),
      isTop ? point.dy - 16 : point.dy + 8,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _RoutePolylinePainter oldDelegate) => true;
}

/// Custom painter for dashed outer rectangle border
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
