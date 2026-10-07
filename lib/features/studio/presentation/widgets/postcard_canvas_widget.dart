import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/theme/waymark_colors.dart';

import '../../domain/models/postcard_enums.dart';

/// PostcardCanvasWidget renders the travel postcard keepsake designed
/// with artistic travel-memoir aesthetics:
/// - Full-bleed scenic background from assets/images
/// - Handwritten "Another Chapter ♥ in my journey" typography
/// - Top-right mountain postmark stamp with cancellation waves
/// - Bottom flight route with airplane silhouette
/// - Prominent center cream paper field journal card with airmail envelope tab
/// - Official WayMark logo in header and memoir seal
/// - Left column: WayMark header, enlarged S-curve route map, clean 2 mini photo cards,
///   4-column stats bar, authenticated memoir seal & "Keep Exploring" stamp
/// - Right column: Dynamic 3 or 4 Polaroids with washi tape & location pins
class PostcardCanvasWidget extends StatelessWidget {
  final GlobalKey repaintBoundaryKey;
  final TripAlbum album;
  final List<TripPlace> places;
  final Map<String, List<PlaceMediaFile>> placeMediaMap;
  final PostcardAestheticStyle style;
  final PostcardRatio ratio;
  final bool showMapRoute;
  final bool isQuadPhotoLayout;
  final String? customBackgroundImage;
  final bool showFlightTrail;

  const PostcardCanvasWidget({
    super.key,
    required this.repaintBoundaryKey,
    required this.album,
    required this.places,
    required this.placeMediaMap,
    required this.style,
    required this.ratio,
    required this.showMapRoute,
    required this.isQuadPhotoLayout,
    this.customBackgroundImage,
    this.showFlightTrail = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgAsset = customBackgroundImage ?? style.defaultBackgroundImage;

    // Metrics calculations
    final totalDistance = _calculateDistance();
    final placesCount = places.isNotEmpty
        ? places.length
        : album.totalPlacesCount;
    final durationDays = _calculateTripDurationDays();

    final targetWidth = ratio.targetWidthConstraint.w;
    final targetAspectRatio = ratio.aspectRatio;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: targetWidth,
        child: AspectRatio(
          aspectRatio: targetAspectRatio,
          child: RepaintBoundary(
            key: repaintBoundaryKey,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: style.isDark ? 0.40 : 0.18,
                    ),
                    blurRadius: 22.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full-bleed Scenic Background Image from assets
                  _buildBackgroundImage(bgAsset),

                  // 1b. Subtle atmospheric gradient
                  _buildAtmosphericGradient(),

                  // 2. Scaled Canvas Artwork Container (Adapts dynamically to canvas ratio)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: ratio.baseWidth,
                        height: ratio.baseHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Top-left artistic calligraphy: "Another Chapter ♥ in my journey"
                            _buildTopCalligraphy(),

                            // Top-right mountain postmark stamp with cancellation waves
                            if (showFlightTrail) _buildTopPostmarkStamp(),

                            // Bottom dashed flight route with airplane
                            if (showFlightTrail) _buildBottomFlightTrail(),

                            // Airmail envelope striped tab behind cream sheet
                            _buildAirmailTab(),

                            // Center Cream Journal Paper Sheet
                            _buildCenterJournalCard(
                              context,
                              totalDistance: totalDistance,
                              placesCount: placesCount,
                              durationDays: durationDays,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Background & Decorative Scenery Elements
  // ---------------------------------------------------------------------------

  Widget _buildBackgroundImage(String assetPath) {
    return Positioned.fill(
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF689BB8), Color(0xFF2A5368), Color(0xFF1E382B)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphericGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.20),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCalligraphy() {
    final textColor = style.isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0C3848);

    if (ratio == PostcardRatio.square11) {
      return Positioned(
        top: 5,
        left: 10,
        child: Transform.rotate(
          angle: -0.04,
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStrokedText(
                'Another Chapter',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fillColor: textColor,
              ),
              const SizedBox(width: 4),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.favorite, size: 14, color: Colors.white),
                  Icon(Icons.favorite, size: 11, color: textColor),
                ],
              ),
              const SizedBox(width: 4),
              _buildStrokedText(
                'in my journey',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fillColor: textColor,
              ),
            ],
          ),
        ),
      );
    }

    final isFeed = ratio == PostcardRatio.feed45;
    final topOffset = isFeed ? 8.0 : 14.0;
    final leftOffset = isFeed ? 12.0 : 14.0;
    final font1 = isFeed ? 15.0 : 20.0;
    final font2 = isFeed ? 19.0 : 26.0;
    final font3 = isFeed ? 12.0 : 15.0;
    final heartSize1 = isFeed ? 14.0 : 18.0;
    final heartSize2 = isFeed ? 12.0 : 15.0;

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: Transform.rotate(
        angle: -0.05,
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStrokedText(
              'Another',
              fontSize: font1,
              fontWeight: FontWeight.w700,
              fillColor: textColor,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStrokedText(
                  'Chapter ',
                  fontSize: font2,
                  fontWeight: FontWeight.w800,
                  fillColor: textColor,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.favorite, size: heartSize1, color: Colors.white),
                    Icon(Icons.favorite, size: heartSize2, color: textColor),
                  ],
                ),
              ],
            ),
            _buildStrokedText(
              'in my journey',
              fontSize: font3,
              fontWeight: FontWeight.w600,
              fillColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Renders calligraphy text with a thin, smooth white stroke outline
  /// so it remains distinctly visible across any bright, colorful, or dark background scenery.
  Widget _buildStrokedText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color fillColor,
    Color strokeColor = Colors.white,
    double strokeWidth = 2.2,
    double height = 1.0,
  }) {
    return Stack(
      children: [
        // 1. Thin white stroke outline behind
        Text(
          text,
          style: GoogleFonts.caveat(
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: height,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        // 2. Solid colored text fill on top
        Text(
          text,
          style: GoogleFonts.caveat(
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: height,
            color: fillColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPostmarkStamp() {
    final double top;
    final double right;
    final Size size;
    switch (ratio) {
      case PostcardRatio.story916:
        top = 10;
        right = 10;
        size = const Size(92, 48);
        break;
      case PostcardRatio.feed45:
        top = 6;
        right = 8;
        size = const Size(76, 38);
        break;
      case PostcardRatio.square11:
        top = 4;
        right = 8;
        size = const Size(62, 30);
        break;
    }

    return Positioned(
      top: top,
      right: right,
      child: Transform.rotate(
        angle: -0.07,
        child: CustomPaint(
          size: size,
          painter: _PostmarkStampPainter(color: const Color(0xEEFFFFFF)),
        ),
      ),
    );
  }

  Widget _buildBottomFlightTrail() {
    final double bottom;
    final double left;
    final double right;
    final double height;
    final double planeRight;
    final double planeBottom;
    final double planeSize;
    final double trailWidth;

    switch (ratio) {
      case PostcardRatio.story916:
        bottom = 6;
        left = 10;
        right = 10;
        height = 28;
        planeRight = 48;
        planeBottom = 6;
        planeSize = 15;
        trailWidth = 340;
        break;
      case PostcardRatio.feed45:
        bottom = 4;
        left = 8;
        right = 8;
        height = 20;
        planeRight = 40;
        planeBottom = 4;
        planeSize = 12;
        trailWidth = 344;
        break;
      case PostcardRatio.square11:
        bottom = 2;
        left = 8;
        right = 8;
        height = 15;
        planeRight = 36;
        planeBottom = 2;
        planeSize = 10;
        trailWidth = 344;
        break;
    }

    return Positioned(
      bottom: bottom,
      left: left,
      right: right,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(trailWidth, height),
            painter: _FlightTrailPainter(color: const Color(0xCCFFFFFF)),
          ),
          Positioned(
            right: planeRight,
            bottom: planeBottom,
            child: Transform.rotate(
              angle: 0.65,
              child: Icon(Icons.flight, size: planeSize, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirmailTab() {
    final double top;
    final double width;
    final double height;
    switch (ratio) {
      case PostcardRatio.story916:
        top = 96;
        width = 38;
        height = 18;
        break;
      case PostcardRatio.feed45:
        top = 54;
        width = 32;
        height = 14;
        break;
      case PostcardRatio.square11:
        top = 40;
        width = 28;
        height = 12;
        break;
    }

    return Positioned(
      top: top,
      left: 6,
      child: Transform.rotate(
        angle: -0.15,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.repeated,
              colors: [
                Color(0xFFE53935),
                Color(0xFFE53935),
                Color(0xFFFAF7F0),
                Color(0xFFFAF7F0),
                Color(0xFF0284C7),
                Color(0xFF0284C7),
                Color(0xFFFAF7F0),
                Color(0xFFFAF7F0),
              ],
              stops: [0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Uploaded Photos Collector (Strictly One Photo At A Time, No Extra Images)
  // ---------------------------------------------------------------------------

  List<_PostcardPhoto> _getAvailableUploadedPhotos() {
    final List<_PostcardPhoto> photos = [];
    final Set<String> seenMediaIds = {};

    // First pass: pick 1 photo from each place that has photos (ensures place variety)
    for (final place in places) {
      final mediaList = placeMediaMap[place.id] ?? [];
      for (final media in mediaList) {
        final path = media.thumbnailPath.isNotEmpty
            ? media.thumbnailPath
            : media.localFilePath;
        if ((path.startsWith('assets/') || File(path).existsSync()) &&
            !seenMediaIds.contains(media.id)) {
          photos.add(_PostcardPhoto(place: place, media: media));
          seenMediaIds.add(media.id);
          break; // One photo per place first
        }
      }
    }

    // Second pass: if fewer than 6, pick remaining distinct photos from places with multiple photos
    if (photos.length < 6) {
      for (final place in places) {
        final mediaList = placeMediaMap[place.id] ?? [];
        for (final media in mediaList) {
          if (photos.length >= 6) break;
          if (!seenMediaIds.contains(media.id)) {
            final path = media.thumbnailPath.isNotEmpty
                ? media.thumbnailPath
                : media.localFilePath;
            if (path.startsWith('assets/') || File(path).existsSync()) {
              photos.add(_PostcardPhoto(place: place, media: media));
              seenMediaIds.add(media.id);
            }
          }
        }
        if (photos.length >= 6) break;
      }
    }

    return photos;
  }

  // ---------------------------------------------------------------------------
  // Center Cream Journal Paper Sheet (Adapts to Ratio)
  // ---------------------------------------------------------------------------

  Widget _buildCenterJournalCard(
    BuildContext context, {
    required double totalDistance,
    required int placesCount,
    required int durationDays,
  }) {
    final colors = context.colorScheme;
    final cardBg = style.isDark
        ? const Color(0xFF1E232A)
        : const Color(0xFFFAF8F3);

    final double top;
    final double bottom;
    final EdgeInsets padding;
    final double spacing;
    final double bottomBarSpacing;

    switch (ratio) {
      case PostcardRatio.story916:
        top = 104;
        bottom = 38;
        padding = const EdgeInsets.fromLTRB(9, 8, 9, 8);
        spacing = 6.0;
        bottomBarSpacing = 6.0;
        break;
      case PostcardRatio.feed45:
        top = 58;
        bottom = 24;
        padding = const EdgeInsets.fromLTRB(8, 7, 8, 7);
        spacing = 5.0;
        bottomBarSpacing = 5.0;
        break;
      case PostcardRatio.square11:
        top = 36;
        bottom = 16;
        padding = const EdgeInsets.fromLTRB(8, 6, 8, 6);
        spacing = 4.0;
        bottomBarSpacing = 4.0;
        break;
    }

    final photos = _getAvailableUploadedPhotos();
    final hasMoreThanFourPhotos = photos.length > 4;
    final polaroidCount = isQuadPhotoLayout ? 4 : 3;
    final extraPhotos = hasMoreThanFourPhotos
        ? photos.skip(polaroidCount).take(2).toList()
        : const <_PostcardPhoto>[];
    final showMiniPhotos = extraPhotos.isNotEmpty;

    return Positioned(
      top: top,
      left: 8,
      right: 8,
      bottom: bottom,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: padding,
        child: Stack(
          children: [
            // Soft watermark stamp in top-left
            Positioned(
              top: 2,
              left: 2,
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Icons.pets,
                  size: 20,
                  color: style.getTextColor(colors),
                ),
              ),
            ),

            // Card Content: 2 Columns on top + Full-Width Bottom Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section: 2 Columns (Expanded to fill available height cleanly)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: WayMark Header, Route Map, (Optional Extra Mini Photos), Stats Bar
                      Expanded(
                        flex: 52,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. WayMark Brand Header
                            _buildJournalHeader(context),
                            SizedBox(height: spacing),

                            // 2. Route Map Box & Optional Extra Mini Photos
                            if (showMiniPhotos) ...[
                              Expanded(
                                flex: 38,
                                child: _buildRouteMapBox(context),
                              ),
                              SizedBox(height: spacing),
                              Expanded(
                                flex: 25,
                                child: _buildMiniPhotosRow(
                                  context,
                                  extraPhotos,
                                ),
                              ),
                              SizedBox(height: spacing),
                            ] else ...[
                              Expanded(child: _buildRouteMapBox(context)),
                              SizedBox(height: spacing),
                            ],

                            // 3. Summary Stats Bar
                            _buildStatsBar(
                              context,
                              totalDistance: totalDistance,
                              placesCount: placesCount,
                              durationDays: durationDays,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right Column: Dynamic Polaroids matching uploaded photos only
                      Expanded(
                        flex: 48,
                        child: _buildPolaroidsColumn(context, photos),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: bottomBarSpacing),

                // Full-Width Bottom Bar: Left Memoir Seal + Right Keep Exploring Stamp
                _buildFullWidthBottomBar(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Left Column Widgets
  // ---------------------------------------------------------------------------

  Widget _buildJournalHeader(BuildContext context) {
    final isSquare = ratio == PostcardRatio.square11;
    final isFeed = ratio == PostcardRatio.feed45;
    final logoSize = isSquare ? 18.0 : (isFeed ? 22.0 : 26.0);
    final brandSize = isSquare ? 12.0 : (isFeed ? 13.0 : 14.5);
    final subBrandSize = isSquare ? 5.5 : (isFeed ? 6.0 : 6.5);
    final studioSize = isSquare ? 10.0 : (isFeed ? 11.0 : 12.5);
    final albumSize = isSquare ? 7.2 : (isFeed ? 7.8 : 8.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Official WayMark Logo
            Image.asset(
              'assets/images/waymark_logo_transparent.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: logoSize * 0.8,
                height: logoSize * 0.8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF5350),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on,
                    size: logoSize * 0.55,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: isSquare ? 4.0 : 6.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wanderline',
                  style: GoogleFonts.outfit(
                    fontSize: brandSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF132A38),
                    height: 1.0,
                  ),
                ),
                Text(
                  'TRAVEL MEMORIES',
                  style: GoogleFonts.inter(
                    fontSize: subBrandSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: isSquare ? 1.5 : 3.0),
        Text(
          'Artistic Postcard Studio',
          style: GoogleFonts.outfit(
            fontSize: studioSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF192531),
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSquare ? 0.5 : 1.0),
        Text(
          '${album.title} • Live Memoir Preview',
          style: GoogleFonts.inter(
            fontSize: albumSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF536A7A),
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Enlarged route map box with increased vertical height like the previous template
  Widget _buildRouteMapBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD4E5D2)),
      ),
      child: Stack(
        children: [
          // Navigation arrow / paper plane icon in top-right
          Positioned(
            top: 5,
            right: 5,
            child: Transform.rotate(
              angle: 0.6,
              child: const Icon(
                Icons.navigation_outlined,
                size: 13,
                color: Color(0xFF0284C7),
              ),
            ),
          ),

          // Route polyline with colored checkpoints & stop names
          Positioned.fill(
            child: CustomPaint(
              painter: _ArtisticRoutePainter(
                places: places,
                albumId: album.id,
                showPolyline: showMapRoute,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean mini photos row shown below the route map when places have > 4 photos (at most 2 pictures)
  Widget _buildMiniPhotosRow(
    BuildContext context,
    List<_PostcardPhoto> extraPhotos,
  ) {
    return Row(
      children: [
        for (int i = 0; i < extraPhotos.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.5),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildUploadedPhotoImage(extraPhotos[i].media),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsBar(
    BuildContext context, {
    required double totalDistance,
    required int placesCount,
    required int durationDays,
  }) {
    final hasDistance = totalDistance > 0;
    final isSquare = ratio == PostcardRatio.square11;
    final isFeed = ratio == PostcardRatio.feed45;
    final barPadding = isSquare
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 2.5)
        : (isFeed
              ? const EdgeInsets.symmetric(horizontal: 3.5, vertical: 3.5)
              : const EdgeInsets.symmetric(horizontal: 4, vertical: 4.5));
    final iconSize = isSquare ? 8.0 : (isFeed ? 9.0 : 10.0);
    final labelSize = isSquare ? 4.8 : (isFeed ? 5.2 : 5.5);
    final valueSize = isSquare ? 7.5 : (isFeed ? 8.0 : 8.5);
    final dividerHeight = isSquare ? 14.0 : (isFeed ? 17.0 : 20.0);

    return Container(
      padding: barPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (hasDistance) ...[
            _buildStatCol(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFEF5350),
              label: 'DISTANCE',
              value: '${totalDistance.toStringAsFixed(2)} km',
              iconSize: iconSize,
              labelSize: labelSize,
              valueSize: valueSize,
            ),
            _buildStatDivider(dividerHeight),
          ],
          _buildStatCol(
            icon: Icons.alt_route_rounded,
            iconColor: const Color(0xFF0284C7),
            label: 'STOPS',
            value: '$placesCount Marks',
            iconSize: iconSize,
            labelSize: labelSize,
            valueSize: valueSize,
          ),
          _buildStatDivider(dividerHeight),
          _buildStatCol(
            icon: Icons.access_time_filled_rounded,
            iconColor: const Color(0xFF2563EB),
            label: 'DURATION',
            value: '$durationDays ${durationDays == 1 ? 'Day' : 'Days'}',
            iconSize: iconSize,
            labelSize: labelSize,
            valueSize: valueSize,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subValue,
    double iconSize = 10,
    double labelSize = 5.5,
    double valueSize = 8.5,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        if (subValue != null)
          Text(
            subValue,
            style: GoogleFonts.inter(
              fontSize: 5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildStatDivider([double height = 20]) {
    return Container(height: height, width: 1, color: const Color(0xFFE2E8F0));
  }

  /// Full-Width Bottom Bar spanning across both columns
  Widget _buildFullWidthBottomBar(BuildContext context) {
    final isSquare = ratio == PostcardRatio.square11;
    final isFeed = ratio == PostcardRatio.feed45;
    final barHeight = isSquare ? 23.0 : (isFeed ? 27.0 : 32.0);
    final logoContainerSize = isSquare ? 15.0 : (isFeed ? 17.0 : 20.0);
    final logoSize = isSquare ? 10.0 : (isFeed ? 12.0 : 14.0);
    final memoirTitleSize = isSquare ? 6.0 : (isFeed ? 6.5 : 7.0);
    final memoirSubSize = isSquare ? 4.2 : (isFeed ? 4.6 : 5.0);
    final keepExploringSize = isSquare ? 9.5 : (isFeed ? 10.5 : 12.0);
    final wavySize = isSquare
        ? const Size(14, 8)
        : (isFeed ? const Size(16, 10) : const Size(20, 12));
    final pillPadding = isSquare
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 5, vertical: 3);

    return SizedBox(
      height: barHeight,
      child: Row(
        children: [
          // Left Pill Badge: Official WayMark Travel Memoir
          Expanded(
            flex: 55,
            child: Container(
              padding: pillPadding,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EFE7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Container(
                    width: logoContainerSize,
                    height: logoContainerSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB7DFD2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/waymark_logo_transparent.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Text(
                          'WL',
                          style: GoogleFonts.outfit(
                            fontSize: memoirTitleSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF183B30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wanderline Travel Memoir',
                          style: GoogleFonts.inter(
                            fontSize: memoirTitleSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF183B30),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Find. Journal. Collect. • Authenticated Memoir',
                          style: GoogleFonts.inter(
                            fontSize: memoirSubSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF52796F),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Right Pill: Keep Exploring ✈ with wavy cancellation lines
          Expanded(
            flex: 45,
            child: Container(
              padding: pillPadding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 0.9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Keep Exploring ✈',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.caveat(
                        fontSize: keepExploringSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF183B30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  CustomPaint(
                    size: wavySize,
                    painter: _WavyLinesPainter(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Right Column: Dynamic Stack of Taped Polaroids (Uploaded Photos Only)
  // ---------------------------------------------------------------------------

  Widget _buildPolaroidsColumn(
    BuildContext context,
    List<_PostcardPhoto> photos,
  ) {
    if (photos.isEmpty) {
      return _buildEmptyPolaroid(context);
    } else if (photos.length == 1) {
      return _buildSinglePolaroid(context, photos.first);
    } else if (photos.length == 2) {
      return _buildDuoPolaroids(context, photos);
    } else if (photos.length == 3) {
      return _buildTrioPolaroids(context, photos);
    } else {
      if (isQuadPhotoLayout) {
        return _buildQuadPolaroids(context, photos.take(4).toList());
      }
      return _buildTrioPolaroids(context, photos.take(3).toList());
    }
  }

  /// 1 Large Centered Polaroid for when 1 photo is uploaded
  Widget _buildSinglePolaroid(BuildContext context, _PostcardPhoto photo) {
    final isSquare = ratio == PostcardRatio.square11;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _buildTapedPolaroidCard(
              angle: 0.02,
              tapeColor: const Color(0xE5FBBF24),
              placeName: photo.place.name,
              media: photo.media,
            ),
          ),
          Positioned(
            right: -3,
            bottom: 4,
            child: Text(
              '♡',
              style: GoogleFonts.caveat(
                fontSize: isSquare ? 14 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2 Taped Polaroids for when only 2 photos are available
  Widget _buildDuoPolaroids(BuildContext context, List<_PostcardPhoto> photos) {
    final isSquare = ratio == PostcardRatio.square11;
    final gap = isSquare ? 5.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Polaroid 1 (Top, yellow tape)
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: 0.03,
            tapeColor: const Color(0xE5FBBF24),
            placeName: photos[0].place.name,
            media: photos[0].media,
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 2 (Bottom, mint tape, with heart doodle)
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: _buildTapedPolaroidCard(
                  angle: -0.025,
                  tapeColor: const Color(0xE56EE7B7),
                  placeName: photos[1].place.name,
                  media: photos[1].media,
                ),
              ),
              Positioned(
                right: -3,
                bottom: 2,
                child: Text(
                  '♡',
                  style: GoogleFonts.caveat(
                    fontSize: isSquare ? 13 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3 Large Taped Polaroids Layout for when 3+ photos are available
  Widget _buildTrioPolaroids(
    BuildContext context,
    List<_PostcardPhoto> photos,
  ) {
    final isSquare = ratio == PostcardRatio.square11;
    final gap = isSquare ? 3.5 : 5.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Polaroid 1 (Top, yellow tape, tilted +0.035 rad)
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: 0.035,
            tapeColor: const Color(0xE5FBBF24),
            placeName: photos[0].place.name,
            media: photos[0].media,
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 2 (Middle, mint tape, tilted -0.03 rad, with heart doodle)
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: _buildTapedPolaroidCard(
                  angle: -0.03,
                  tapeColor: const Color(0xE56EE7B7),
                  placeName: photos[1].place.name,
                  media: photos[1].media,
                ),
              ),
              Positioned(
                right: -3,
                bottom: 2,
                child: Text(
                  '♡',
                  style: GoogleFonts.caveat(
                    fontSize: isSquare ? 13 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 3 (Bottom, peach tape, tilted +0.025 rad)
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: 0.025,
            tapeColor: const Color(0xE5FCA5A5),
            placeName: photos[2].place.name,
            media: photos[2].media,
          ),
        ),
      ],
    );
  }

  /// 4 Taped Polaroids Layout (Quad) filling column
  Widget _buildQuadPolaroids(
    BuildContext context,
    List<_PostcardPhoto> photos,
  ) {
    final isSquare = ratio == PostcardRatio.square11;
    final gap = isSquare ? 2.5 : 4.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Polaroid 1
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: 0.03,
            tapeColor: const Color(0xE5FBBF24),
            placeName: photos[0].place.name,
            media: photos[0].media,
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 2 (with heart doodle)
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: _buildTapedPolaroidCard(
                  angle: -0.025,
                  tapeColor: const Color(0xE56EE7B7),
                  placeName: photos[1].place.name,
                  media: photos[1].media,
                ),
              ),
              Positioned(
                right: -3,
                bottom: 2,
                child: Text(
                  '♡',
                  style: GoogleFonts.caveat(
                    fontSize: isSquare ? 11 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 3
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: 0.02,
            tapeColor: const Color(0xE5FCA5A5),
            placeName: photos[2].place.name,
            media: photos[2].media,
          ),
        ),
        SizedBox(height: gap),

        // Polaroid 4
        Expanded(
          child: _buildTapedPolaroidCard(
            angle: -0.018,
            tapeColor: const Color(0xE593C5FD),
            placeName: photos[3].place.name,
            media: photos[3].media,
          ),
        ),
      ],
    );
  }

  /// Clean placeholder polaroid for when 0 photos are uploaded
  Widget _buildEmptyPolaroid(BuildContext context) {
    final displayName = places.isNotEmpty ? places.first.name : album.title;

    return Center(
      child: _buildTapedPolaroidCard(
        angle: 0.02,
        tapeColor: const Color(0xE5FBBF24),
        placeName: displayName,
        media: null,
      ),
    );
  }

  Widget _buildTapedPolaroidCard({
    required double angle,
    required Color tapeColor,
    required String placeName,
    required PlaceMediaFile? media,
  }) {
    final isSquare = ratio == PostcardRatio.square11;
    final isFeed = ratio == PostcardRatio.feed45;
    final pinSize = isSquare ? 6.5 : (isFeed ? 7.2 : 8.0);
    final fontSize = isSquare ? 7.0 : (isFeed ? 7.5 : 8.0);
    final tapeW = isSquare ? 22.0 : (isFeed ? 26.0 : 30.0);
    final tapeH = isSquare ? 6.5 : (isFeed ? 7.0 : 8.0);
    final cardPadding = isSquare
        ? const EdgeInsets.fromLTRB(3.5, 4.0, 3.5, 3.0)
        : (isFeed
              ? const EdgeInsets.fromLTRB(4.0, 4.5, 4.0, 3.5)
              : const EdgeInsets.fromLTRB(4.5, 5.5, 4.5, 4.0));

    return Transform.rotate(
      angle: angle,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // White Polaroid Card Body filling the expanded area
          Positioned.fill(
            child: Container(
              padding: cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 5,
                    offset: const Offset(0, 2.5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildUploadedPhotoImage(media),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: pinSize,
                        color: const Color(0xFF0F3647),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          placeName,
                          style: GoogleFonts.outfit(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F3647),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Translucent Washi Tape at Top Center
          Positioned(
            top: -3.5,
            child: Container(
              width: tapeW,
              height: tapeH,
              decoration: BoxDecoration(
                color: tapeColor,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Uploaded Photo Image Rendering (No Fake Fallbacks)
  // ---------------------------------------------------------------------------

  Widget _buildUploadedPhotoImage(PlaceMediaFile? media) {
    if (media != null) {
      final path = media.thumbnailPath.isNotEmpty
          ? media.thumbnailPath
          : media.localFilePath;

      if (path.startsWith('assets/')) {
        return Image.asset(path, fit: BoxFit.cover);
      } else if (File(path).existsSync()) {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildEmptyPhotoPlaceholder(),
        );
      }
    }

    return _buildEmptyPhotoPlaceholder();
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 2),
            Text(
              'No photo',
              style: GoogleFonts.inter(
                fontSize: 6,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Calculations & Fallbacks
  // ---------------------------------------------------------------------------

  double _calculateDistance() {
    if (album.totalDistanceKm > 0) return album.totalDistanceKm;
    if (places.length >= 2) {
      double total = 0.0;
      for (int i = 0; i < places.length - 1; i++) {
        final p1 = places[i];
        final p2 = places[i + 1];
        total += _haversineDistance(
          p1.latitude,
          p1.longitude,
          p2.latitude,
          p2.longitude,
        );
      }
      if (total > 0) return total;
    }
    return 0.0;
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  int _calculateTripDurationDays() {
    final end =
        album.endDate ??
        (places.isNotEmpty ? places.last.visitedAt : DateTime.now());
    final diff = end.difference(album.startDate).inDays;
    return diff > 0 ? diff : 1;
  }
}

// =============================================================================
// Custom Painters for Artistic Aesthetics
// =============================================================================

/// Painter for the top-right mountain postmark stamp with cancellation waves
class _PostmarkStampPainter extends CustomPainter {
  final Color color;

  _PostmarkStampPainter({this.color = const Color(0xEEFFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.height / 2, size.height / 2);
    final outerRadius = size.height / 2 - 2;
    final innerRadius = outerRadius - 4;

    // Double circle
    canvas.drawCircle(center, outerRadius, strokePaint);
    canvas.drawCircle(center, innerRadius, strokePaint);

    // Mountain peaks inside circle
    final mtnPath = Path()
      ..moveTo(center.dx - 11, center.dy + 7)
      ..lineTo(center.dx - 3, center.dy - 5)
      ..lineTo(center.dx + 4, center.dy + 3)
      ..lineTo(center.dx + 8, center.dy - 2)
      ..lineTo(center.dx + 12, center.dy + 7);
    canvas.drawPath(mtnPath, strokePaint);

    // Mountain snow line
    final snowPath = Path()
      ..moveTo(center.dx - 6, center.dy - 1)
      ..lineTo(center.dx - 3, center.dy - 5)
      ..lineTo(center.dx, center.dy - 2);
    canvas.drawPath(snowPath, strokePaint);

    // 4 horizontal wavy cancellation lines extending off to the right
    for (int i = 0; i < 4; i++) {
      final yBase = size.height * 0.18 + i * (size.height * 0.22);
      final startX = center.dx + outerRadius + 3;
      final path = Path()..moveTo(startX, yBase);
      for (double x = startX; x <= size.width; x += 1) {
        final y = yBase + math.sin((x - startX) * 0.35) * 1.8;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PostmarkStampPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter for the bottom curved flight trail with dashed line
class _FlightTrailPainter extends CustomPainter {
  final Color color;

  _FlightTrailPainter({this.color = const Color(0xCCFFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.52, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.25,
        size.width * 0.96,
        size.height * 0.35,
      );

    _drawDashedPath(canvas, path, dashPaint, dashLength: 4.5, gapLength: 3.5);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashLength, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlightTrailPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter for the 3 wavy cancellation lines next to Keep Exploring
class _WavyLinesPainter extends CustomPainter {
  final Color color;

  _WavyLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final yBase = 2.5 + i * 4.2;
      final path = Path()..moveTo(0, yBase);
      for (double x = 0; x < size.width; x += 1) {
        final y = yBase + math.sin(x * 0.45) * 1.5;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyLinesPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter for the enlarged S-curve map route connecting all colored checkpoint waypoints
class _ArtisticRoutePainter extends CustomPainter {
  final List<TripPlace> places;
  final String albumId;
  final bool showPolyline;

  _ArtisticRoutePainter({
    required this.places,
    required this.albumId,
    this.showPolyline = true,
  });

  static const List<Color> _checkpointColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle Cartographic Topographic Contour Curves in Background
    final contourPaint = Paint()
      ..color = const Color(0xFFC8DEC2).withValues(alpha: 0.50)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final cPath1 = Path()
      ..moveTo(0, h * 0.28)
      ..quadraticBezierTo(w * 0.35, h * 0.16, w * 0.65, h * 0.30)
      ..quadraticBezierTo(w * 0.85, h * 0.38, w, h * 0.24);
    canvas.drawPath(cPath1, contourPaint);

    final cPath2 = Path()
      ..moveTo(0, h * 0.58)
      ..quadraticBezierTo(w * 0.32, h * 0.46, w * 0.70, h * 0.62)
      ..quadraticBezierTo(w * 0.88, h * 0.68, w, h * 0.54);
    canvas.drawPath(cPath2, contourPaint);

    final cPath3 = Path()
      ..moveTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.38, h * 0.78, w * 0.68, h * 0.88)
      ..quadraticBezierTo(w * 0.86, h * 0.94, w, h * 0.84);
    canvas.drawPath(cPath3, contourPaint);

    // 2. Extract stop names for ALL places
    final List<String> placeNames;
    if (places.isNotEmpty) {
      placeNames = places.map((p) {
        final trimmed = p.name.trim();
        return trimmed.contains(' ') ? trimmed.split(' ').first : trimmed;
      }).toList();
    } else {
      placeNames = const [];
    }

    final int count = placeNames.length;
    if (count == 0) return;

    // 3. Compute dynamic points across the map box for all places
    final List<Offset> points = [];
    if (count == 1) {
      points.add(Offset(w * 0.5, h * 0.52));
    } else {
      final startX = w * 0.14;
      final endX = w * 0.86;
      final stepX = (endX - startX) / (count - 1);
      final yHigh = h * 0.38;
      final yLow = h * 0.70;

      for (int i = 0; i < count; i++) {
        final x = startX + i * stepX;
        final isHigh = (i % 2 == 0);
        final y = isHigh ? yHigh : yLow;
        points.add(Offset(x, y));
      }
    }

    // 4. Draw curved dashed segments connecting ALL consecutive places if showPolyline is true
    if (showPolyline && points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final start = points[i];
        final end = points[i + 1];
        final midX = (start.dx + end.dx) / 2;
        final controlY = (i % 2 == 0) ? h * 0.60 : h * 0.48;
        final segColor = _checkpointColors[i % _checkpointColors.length];

        _drawCurvedDashedSegment(
          canvas,
          start: start,
          end: end,
          control: Offset(midX, controlY),
          color: segColor,
        );
      }
    }

    // 5. Node radius and typography scaling for place count
    final nodeRadius = count > 6 ? 4.2 : 5.5;
    final innerRadius = count > 6 ? 2.0 : 2.8;
    final labelFontSize = count > 6 ? 5.5 : (count > 4 ? 6.2 : 7.0);

    // 6. Draw Checkpoint Nodes for ALL places
    for (int i = 0; i < points.length; i++) {
      final color = _checkpointColors[i % _checkpointColors.length];
      _drawCheckpointNode(canvas, points[i], color, nodeRadius, innerRadius);
    }

    // 7. Draw Labels alternating above and below with safe edge clamping
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isTop = (i % 2 == 0);
      final labelY = isTop
          ? pt.dy - (nodeRadius + 7.5)
          : pt.dy + (nodeRadius + 6.5);
      final clampedY = labelY.clamp(7.0, h - 7.0);
      _drawLabel(canvas, placeNames[i], Offset(pt.dx, clampedY), labelFontSize);
    }
  }

  void _drawCurvedDashedSegment(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required Offset control,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(3.5, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += 3.5 + 2.5;
      }
    }
  }

  void _drawCheckpointNode(
    Canvas canvas,
    Offset point,
    Color color,
    double radius,
    double innerRadius,
  ) {
    // Outer colored ring
    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, radius, outerPaint);

    // Inner white circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point, innerRadius, innerPaint);
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double fontSize) {
    final textSpan = TextSpan(
      text: text,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final drawOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, drawOffset);
  }

  @override
  bool shouldRepaint(covariant _ArtisticRoutePainter oldDelegate) {
    return oldDelegate.showPolyline != showPolyline ||
        oldDelegate.places != places ||
        oldDelegate.albumId != albumId;
  }
}

/// Helper model for an actual uploaded photo associated with a trip place
class _PostcardPhoto {
  final TripPlace place;
  final PlaceMediaFile media;

  const _PostcardPhoto({required this.place, required this.media});
}
