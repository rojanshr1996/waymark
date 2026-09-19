import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_animated_entrance.dart';
import 'package:waymark/core/presentation/widgets/waymark_artistic_empty_state.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/presentation/widgets/waymark_scroll_behavior.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/features/journeys/presentation/widgets/create_journey_bottom_sheet.dart';

import '../../domain/models/postcard_enums.dart';
import '../widgets/postcard_canvas_widget.dart';
import '../widgets/postcard_controls_widget.dart';

class PostcardStudioScreen extends StatefulWidget {
  final String? initialAlbumId;

  const PostcardStudioScreen({super.key, this.initialAlbumId});

  @override
  State<PostcardStudioScreen> createState() => _PostcardStudioScreenState();
}

class _PostcardStudioScreenState extends State<PostcardStudioScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // Reactive State Notifiers (Strict No setState rule)
  late final ValueNotifier<TripAlbum?> _selectedAlbumNotifier;
  late final ValueNotifier<PostcardAestheticStyle> _selectedStyleNotifier;
  late final ValueNotifier<PostcardRatio> _selectedRatioNotifier;
  late final ValueNotifier<bool> _showMapRouteNotifier;
  late final ValueNotifier<bool> _showWeatherNotifier;
  late final ValueNotifier<bool> _isQuadPhotoLayoutNotifier;
  late final ValueNotifier<bool> _isExportingNotifier;

  @override
  void initState() {
    super.initState();
    _selectedAlbumNotifier = ValueNotifier<TripAlbum?>(null);
    _selectedStyleNotifier = ValueNotifier<PostcardAestheticStyle>(
      PostcardAestheticStyle.vintage,
    );
    _selectedRatioNotifier = ValueNotifier<PostcardRatio>(
      PostcardRatio.story916,
    );
    _showMapRouteNotifier = ValueNotifier<bool>(true);
    _showWeatherNotifier = ValueNotifier<bool>(true);
    _isQuadPhotoLayoutNotifier = ValueNotifier<bool>(false);
    _isExportingNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _selectedAlbumNotifier.dispose();
    _selectedStyleNotifier.dispose();
    _selectedRatioNotifier.dispose();
    _showMapRouteNotifier.dispose();
    _showWeatherNotifier.dispose();
    _isQuadPhotoLayoutNotifier.dispose();
    _isExportingNotifier.dispose();
    super.dispose();
  }

  /// Captures the postcard canvas as a PNG in the temporary directory.
  Future<File?> _capturePostcardPng() async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final albumName =
          _selectedAlbumNotifier.value?.title.replaceAll(' ', '_') ?? 'memoir';
      final fileName =
          'waymark_postcard_${albumName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint('Error capturing postcard PNG: $e');
      return null;
    }
  }

  Future<void> _handleDownloadPostcard() async {
    if (_isExportingNotifier.value) return;
    _isExportingNotifier.value = true;

    try {
      final file = await _capturePostcardPng();
      if (!mounted) return;

      if (file != null) {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess && !await Gal.requestAccess()) return;
        await Gal.putImage(file.path, album: 'Waymark');
        if (mounted) await _showPostcardPreview(file);
      } else {
        if (mounted) {
          WaymarkSnackbar.showError(
            context,
            'Failed to render postcard. Please try again.',
          );
        }
      }
    } on GalException {
      if (mounted) {
        WaymarkSnackbar.showError(
          context,
          'Unable to save the postcard to your gallery.',
        );
      }
    } finally {
      if (mounted) {
        _isExportingNotifier.value = false;
      }
    }
  }

  Future<void> _showPostcardPreview(File file) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20.w),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: IconButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close preview',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSharePostcard() async {
    if (_isExportingNotifier.value) return;
    _isExportingNotifier.value = true;

    try {
      final file = await _capturePostcardPng();
      if (!mounted) return;

      if (file != null) {
        final albumTitle = _selectedAlbumNotifier.value?.title ?? 'My Journey';
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Check out my $albumTitle travel postcard captured with WayMark!',
          subject: 'WayMark Travel Memoir',
        );
      } else {
        if (mounted) {
          WaymarkSnackbar.showError(
            context,
            'Unable to generate postcard for sharing.',
          );
        }
      }
    } finally {
      if (mounted) {
        _isExportingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;

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

          if (albums.isEmpty) {
            return Center(
              child: WaymarkAnimatedEntrance(
                child: WaymarkArtisticEmptyState(
                  badgeText: context.l10n.studioBadgeClosed,
                  icon: Icons.camera_alt_rounded,
                  title: context.l10n.studioNoMemoriesTitle,
                  description: context.l10n.studioNoMemoriesDesc,
                  buttonLabel: context.l10n.emptyExploreBtn,
                  onButtonPressed: () => CreateJourneyBottomSheet.show(context),
                ),
              ),
            );
          }

          // Maintain selected album
          final activeAlbum = _selectedAlbumNotifier.value;
          TripAlbum? requestedAlbum;
          for (final album in albums) {
            if (album.id == widget.initialAlbumId) {
              requestedAlbum = album;
              break;
            }
          }
          if (activeAlbum == null ||
              !albums.any((a) => a.id == activeAlbum.id)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _selectedAlbumNotifier.value = requestedAlbum ?? albums.first;
              }
            });
          }

          return ValueListenableBuilder<TripAlbum?>(
            valueListenable: _selectedAlbumNotifier,
            builder: (context, selectedAlbum, _) {
              final album = selectedAlbum ?? albums.first;

              return StreamBuilder<List<TripPlace>>(
                stream: db.tripPlaceDao.watchPlacesForAlbum(album.id),
                builder: (context, placeSnapshot) {
                  final places = placeSnapshot.data ?? [];

                  return StreamBuilder<List<PlaceMediaFile>>(
                    stream: db.placeMediaDao.watchMediaForPlaces(
                      places.map((p) => p.id).toList(),
                    ),
                    builder: (context, mediaSnapshot) {
                      final mediaList = mediaSnapshot.data ?? [];
                      final mediaMap = <String, List<PlaceMediaFile>>{};
                      for (final m in mediaList) {
                        mediaMap.putIfAbsent(m.placeId, () => []).add(m);
                      }

                      return ScrollConfiguration(
                        behavior: const WaymarkNoOverscrollScrollBehavior(),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.only(
                            top: MediaQuery.paddingOf(context).top + 16.h,
                            bottom: WaymarkSpacing.margin(context) + 16.h,
                            left: WaymarkSpacing.margin(context),
                            right: WaymarkSpacing.margin(context),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Studio Header Title & Quick Export Button
                              _buildScreenHeader(context, album),
                              SizedBox(height: 14.h),

                              // Live Render Boundary Status Bar
                              _buildLiveRenderStatusBar(context),
                              SizedBox(height: 10.h),

                              // Live Postcard Canvas Viewport
                              WaymarkAnimatedEntrance(
                                child: ValueListenableBuilder<PostcardAestheticStyle>(
                                  valueListenable: _selectedStyleNotifier,
                                  builder: (context, style, _) {
                                    return ValueListenableBuilder<
                                      PostcardRatio
                                    >(
                                      valueListenable: _selectedRatioNotifier,
                                      builder: (context, ratio, _) {
                                        return ValueListenableBuilder<bool>(
                                          valueListenable:
                                              _showMapRouteNotifier,
                                          builder: (context, showRoute, _) {
                                            return ValueListenableBuilder<bool>(
                                              valueListenable:
                                                  _showWeatherNotifier,
                                              builder: (context, showWeather, _) {
                                                return ValueListenableBuilder<
                                                  bool
                                                >(
                                                  valueListenable:
                                                      _isQuadPhotoLayoutNotifier,
                                                  builder: (context, isQuad, _) {
                                                    return PostcardCanvasWidget(
                                                      repaintBoundaryKey:
                                                          _repaintBoundaryKey,
                                                      album: album,
                                                      places: places,
                                                      placeMediaMap: mediaMap,
                                                      style: style,
                                                      ratio: ratio,
                                                      showMapRoute: showRoute,
                                                      showWeather: showWeather,
                                                      isQuadPhotoLayout: isQuad,
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
                              ),
                              SizedBox(height: 22.h),

                              // Customization Controls & Actions
                              WaymarkAnimatedEntrance(
                                delay: const Duration(milliseconds: 100),
                                child: PostcardControlsWidget(
                                  albums: albums,
                                  selectedAlbumNotifier: _selectedAlbumNotifier,
                                  selectedStyleNotifier: _selectedStyleNotifier,
                                  selectedRatioNotifier: _selectedRatioNotifier,
                                  showMapRouteNotifier: _showMapRouteNotifier,
                                  showWeatherNotifier: _showWeatherNotifier,
                                  isQuadPhotoLayoutNotifier:
                                      _isQuadPhotoLayoutNotifier,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildScreenHeader(BuildContext context, TripAlbum album) {
    final colors = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artistic Postcard Studio',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${album.title} • Live Memoir Preview',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: colors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        ValueListenableBuilder<bool>(
          valueListenable: _isExportingNotifier,
          builder: (context, isExporting, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filled(
                style: IconButton.styleFrom(fixedSize: Size(44.w, 44.w)),
                onPressed: isExporting ? null : _handleDownloadPostcard,
                icon: isExporting
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_for_offline_rounded),
                tooltip: 'Download postcard',
              ),
              SizedBox(width: 4.w),
              IconButton.filledTonal(
                style: IconButton.styleFrom(fixedSize: Size(44.w, 44.w)),
                onPressed: isExporting ? null : _handleSharePostcard,
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Share postcard',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveRenderStatusBar(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 13.sp, color: colors.tertiary),
              SizedBox(width: 4.w),
              Text(
                'LIVE RENDER BOUNDARY',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: colors.forestVivid,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Live Preview',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
