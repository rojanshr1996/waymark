import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:waymark/core/constants/waymark_spacing.dart';
import 'package:waymark/core/database/app_database.dart';
import 'package:waymark/core/l10n/l10n_extension.dart';
import 'package:waymark/core/presentation/widgets/waymark_shimmer.dart';
import 'package:waymark/core/presentation/widgets/waymark_snackbar.dart';
import 'package:waymark/core/services/location_search_service.dart';
import 'package:waymark/core/theme/waymark_colors.dart';
import 'package:waymark/core/theme/waymark_typography.dart';

/// Represents a photo attached to the place (either newly picked or pre-existing from DB).
class _AttachedPhotoItem {
  final String? id; // Present if already in SQLite DB
  final String path;
  final int fileSizeBytes;
  final String format;
  bool isCover;

  _AttachedPhotoItem({
    this.id,
    required this.path,
    required this.fileSizeBytes,
    required this.format,
    this.isCover = false,
  });
}

class _LocationState {
  final LatLng coordinates;
  final String? address;
  final bool isGpsFromExif;

  const _LocationState({
    this.coordinates = const LatLng(37.7749, -122.4194),
    this.address,
    this.isGpsFromExif = false,
  });

  _LocationState copyWith({
    LatLng? coordinates,
    String? address,
    bool? isGpsFromExif,
  }) {
    return _LocationState(
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      isGpsFromExif: isGpsFromExif ?? this.isGpsFromExif,
    );
  }
}

class _WeatherState {
  final String condition;
  final double temperatureCelsius;
  final double? apparentTemp;
  final int? humidity;
  final double? windSpeed;
  final bool isFetching;

  String get weather => condition;
  bool get isFetchingWeather => isFetching;

  const _WeatherState({
    this.condition = 'Sunny',
    this.temperatureCelsius = 19.0,
    this.apparentTemp,
    this.humidity,
    this.windSpeed,
    this.isFetching = false,
  });

  _WeatherState copyWith({
    String? condition,
    double? temperatureCelsius,
    double? apparentTemp,
    int? humidity,
    double? windSpeed,
    bool? isFetching,
  }) {
    return _WeatherState(
      condition: condition ?? this.condition,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      apparentTemp: apparentTemp ?? this.apparentTemp,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}

class _SearchState {
  final List<LocationSearchResult> results;
  final bool isSearching;
  final bool searchPerformed;
  final bool showAll;
  final bool canDragMap;

  const _SearchState({
    this.results = const [],
    this.isSearching = false,
    this.searchPerformed = false,
    this.showAll = false,
    this.canDragMap = false,
  });

  _SearchState copyWith({
    List<LocationSearchResult>? results,
    bool? isSearching,
    bool? searchPerformed,
    bool? showAll,
    bool? canDragMap,
  }) {
    return _SearchState(
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      searchPerformed: searchPerformed ?? this.searchPerformed,
      showAll: showAll ?? this.showAll,
      canDragMap: canDragMap ?? this.canDragMap,
    );
  }
}

typedef PlaceLoggerBottomSheet = PlaceLoggerScreen;

/// Rich, tactile Place Logger full page matching Stitch Design Suite.
/// Supports both Create Mode (new stop) and Edit Mode (updating an existing stop).
class PlaceLoggerScreen extends StatefulWidget {
  final String albumId;
  final String? albumTitle;
  final TripPlace? placeToEdit;
  final List<String>? initialPhotos;

  const PlaceLoggerScreen({
    super.key,
    required this.albumId,
    this.albumTitle,
    this.placeToEdit,
    this.initialPhotos,
  });

  /// Displays the Place Logger as a dedicated full-page screen.
  static Future<void> show(
    BuildContext context, {
    required String albumId,
    String? albumTitle,
    TripPlace? placeToEdit,
    List<String>? initialPhotos,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (ctx) => PlaceLoggerScreen(
          albumId: albumId,
          albumTitle: albumTitle,
          placeToEdit: placeToEdit,
          initialPhotos: initialPhotos,
        ),
      ),
    );
  }

  @override
  State<PlaceLoggerScreen> createState() => _PlaceLoggerScreenState();
}

class _PlaceLoggerScreenState extends State<PlaceLoggerScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final _mapController = MapController();

  late final AnimationController _pulseController;

  // Notifiers
  late final ValueNotifier<_LocationState> _locationStateNotifier;
  late final ValueNotifier<String> _categoryNotifier;
  late final ValueNotifier<_WeatherState> _weatherStateNotifier;
  late final ValueNotifier<DateTime> _visitedAtNotifier;
  late final ValueNotifier<int> _recommendationScaleNotifier;
  final ValueNotifier<List<_AttachedPhotoItem>> _photosNotifier =
      ValueNotifier<List<_AttachedPhotoItem>>([]);
  final ValueNotifier<_SearchState> _searchStateNotifier =
      ValueNotifier<_SearchState>(const _SearchState());
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  int _existingVisitOrder = 0;

  // Weather & Calibration
  CancelToken? _weatherCancelToken;
  Timer? _mapMoveDebounce;

  // Search debouncing & cancellation
  Timer? _searchDebounce;
  CancelToken? _searchCancelToken;

  // Getters for transparent reads
  double get _latitude => _locationStateNotifier.value.coordinates.latitude;
  double get _longitude => _locationStateNotifier.value.coordinates.longitude;
  String? get _locationAddress => _locationStateNotifier.value.address;
  bool get _isGpsFromExif => _locationStateNotifier.value.isGpsFromExif;

  String get _category => _categoryNotifier.value;
  String get _weather => _weatherStateNotifier.value.condition;
  double get _temperatureCelsius =>
      _weatherStateNotifier.value.temperatureCelsius;

  DateTime get _visitedAt => _visitedAtNotifier.value;
  int get _recommendationScale => _recommendationScaleNotifier.value;
  List<_AttachedPhotoItem> get _photos => _photosNotifier.value;

  bool get _canDragMap => _searchStateNotifier.value.canDragMap;

  bool get _isEditing => widget.placeToEdit != null;

  final _categoryOptions = const [
    {'name': 'SIGHTSEEING', 'icon': Icons.temple_buddhist},
    {'name': 'FOOD', 'icon': Icons.restaurant_rounded},
    {'name': 'COFFEE', 'icon': Icons.coffee_rounded},
    {'name': 'HIKE', 'icon': Icons.hiking_rounded},
    {'name': 'STAY', 'icon': Icons.bed_rounded},
    {'name': 'TRANSIT', 'icon': Icons.directions_transit_rounded},
    {'name': 'GENERAL', 'icon': Icons.place_rounded},
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    int initialRecommendationScale = 8;
    if (_isEditing) {
      final p = widget.placeToEdit!;
      _nameController.text = p.name;
      final address = p.locationAddress ?? p.name;
      _searchController.text = address;
      _existingVisitOrder = p.visitOrder;

      if (p.sensoryTags != null && p.sensoryTags!.isNotEmpty) {
        final match = RegExp(
          r'(?:rating:|rec_)(\d+)',
        ).firstMatch(p.sensoryTags!);
        if (match != null) {
          initialRecommendationScale = int.tryParse(match.group(1)!) ?? 8;
        }
      }

      _locationStateNotifier = ValueNotifier<_LocationState>(
        _LocationState(
          coordinates: LatLng(p.latitude, p.longitude),
          address: address,
          isGpsFromExif: p.isGpsFromExif,
        ),
      );
      _categoryNotifier = ValueNotifier<String>(p.category);
      _weatherStateNotifier = ValueNotifier<_WeatherState>(
        _WeatherState(
          condition: p.weatherCondition ?? 'Sunny',
          temperatureCelsius: p.temperatureCelsius ?? 19.0,
        ),
      );
      _visitedAtNotifier = ValueNotifier<DateTime>(p.visitedAt);
      _notesController.text = p.notes ?? '';

      _loadExistingMedia(p.id);
      _fetchLiveWeather(p.latitude, p.longitude);
    } else {
      _nameController.text = '';
      _searchController.text = '';
      _locationStateNotifier = ValueNotifier<_LocationState>(
        const _LocationState(
          coordinates: LatLng(37.7749, -122.4194),
          isGpsFromExif: true,
        ),
      );
      _categoryNotifier = ValueNotifier<String>('SIGHTSEEING');
      _weatherStateNotifier = ValueNotifier<_WeatherState>(
        const _WeatherState(),
      );
      _visitedAtNotifier = ValueNotifier<DateTime>(DateTime.now());

      _initUserLocation();
      _fetchLiveWeather(_latitude, _longitude);
    }
    _recommendationScaleNotifier = ValueNotifier<int>(
      initialRecommendationScale,
    );

    if (widget.initialPhotos != null && widget.initialPhotos!.isNotEmpty) {
      final initialItems = <_AttachedPhotoItem>[];
      for (int i = 0; i < widget.initialPhotos!.length; i++) {
        final path = widget.initialPhotos![i];
        final ext = path.split('.').last.toUpperCase();
        initialItems.add(
          _AttachedPhotoItem(
            path: path,
            fileSizeBytes: 2048,
            format: ext.isEmpty ? 'JPG' : ext,
            isCover: i == 0,
          ),
        );
      }
      _photosNotifier.value = initialItems;
    }
  }

  Future<void> _initUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (mounted) {
        _locationStateNotifier.value = _locationStateNotifier.value.copyWith(
          coordinates: LatLng(pos.latitude, pos.longitude),
          isGpsFromExif: true,
        );
        _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
        await _reverseGeocode(LatLng(pos.latitude, pos.longitude));
        await _fetchLiveWeather(pos.latitude, pos.longitude);
      }
    } catch (_) {
      // Retain fallback coordinates cleanly
    }
  }

  Future<void> _loadExistingMedia(String placeId) async {
    try {
      final media = await AppDatabase.instance.placeMediaDao.getMediaForPlace(
        placeId,
      );
      if (mounted && media.isNotEmpty) {
        final existingPaths = _photos.map((p) => p.path).toSet();
        final updatedPhotos = List<_AttachedPhotoItem>.from(_photos);
        for (final m in media) {
          if (!existingPaths.contains(m.localFilePath)) {
            final ext = m.localFilePath.split('.').last.toUpperCase();
            updatedPhotos.add(
              _AttachedPhotoItem(
                id: m.id,
                path: m.localFilePath,
                fileSizeBytes: m.fileSizeBytes,
                format: ext.isEmpty ? 'JPG' : ext,
                isCover: m.isCoverPhoto,
              ),
            );
          }
        }
        // Ensure at least one is cover if photos exist
        if (updatedPhotos.isNotEmpty && !updatedPhotos.any((p) => p.isCover)) {
          updatedPhotos.first.isCover = true;
        }
        _photosNotifier.value = updatedPhotos;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _searchCancelToken?.cancel();
    _mapMoveDebounce?.cancel();
    _weatherCancelToken?.cancel();
    _locationStateNotifier.dispose();
    _categoryNotifier.dispose();
    _weatherStateNotifier.dispose();
    _visitedAtNotifier.dispose();
    _recommendationScaleNotifier.dispose();
    _photosNotifier.dispose();
    _searchStateNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveWeather(double lat, double lon) async {
    _weatherCancelToken?.cancel();
    _weatherCancelToken = CancelToken();
    if (!mounted) return;
    _weatherStateNotifier.value = _weatherStateNotifier.value.copyWith(
      isFetching: true,
    );
    try {
      final weather = await LocationSearchService.instance.fetchCurrentWeather(
        lat,
        lon,
        cancelToken: _weatherCancelToken,
      );
      if (weather != null && mounted) {
        _weatherStateNotifier.value = _weatherStateNotifier.value.copyWith(
          temperatureCelsius: weather.temperature,
          condition: weather.condition,
          apparentTemp: weather.apparentTemperature,
          humidity: weather.humidity,
          windSpeed: weather.windSpeed,
          isFetching: false,
        );
      } else if (mounted) {
        _weatherStateNotifier.value = _weatherStateNotifier.value.copyWith(
          isFetching: false,
        );
      }
    } catch (_) {
      if (mounted) {
        _weatherStateNotifier.value = _weatherStateNotifier.value.copyWith(
          isFetching: false,
        );
      }
    }
  }

  int get _wordCount {
    final text = _notesController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final clean = query.trim();
    if (clean.isEmpty) {
      _searchCancelToken?.cancel();
      _searchStateNotifier.value = const _SearchState();
      return;
    }

    _searchStateNotifier.value = _searchStateNotifier.value.copyWith(
      isSearching: true,
      showAll: false,
    );

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      _searchCancelToken?.cancel();
      _searchCancelToken = CancelToken();

      try {
        final results = await LocationSearchService.instance.search(
          clean,
          cancelToken: _searchCancelToken,
        );
        if (mounted) {
          _searchStateNotifier.value = _searchStateNotifier.value.copyWith(
            results: results,
            isSearching: false,
            searchPerformed: true,
            // Only if there is NO result in the search, allow user to drag the map!
            canDragMap: results.isEmpty,
          );
        }
      } catch (_) {
        if (mounted) {
          _searchStateNotifier.value = _searchStateNotifier.value.copyWith(
            isSearching: false,
            searchPerformed: true,
            canDragMap: true, // Error / no result -> allow dragging
          );
        }
      }
    });
  }

  void _selectSearchResult(LocationSearchResult result) {
    _nameController.text = result.name;
    _searchController.text = result.name;
    _locationStateNotifier.value = _LocationState(
      coordinates: LatLng(result.latitude, result.longitude),
      address: result.formattedAddress,
      isGpsFromExif: true,
    );
    _searchStateNotifier.value = const _SearchState();
    if (result.category != 'GENERAL') {
      _categoryNotifier.value = result.category;
    }
    _mapController.move(LatLng(result.latitude, result.longitude), 15.0);
    _fetchLiveWeather(result.latitude, result.longitude);
    FocusScope.of(context).unfocus();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_canDragMap) return;
    _locationStateNotifier.value = _locationStateNotifier.value.copyWith(
      coordinates: point,
      isGpsFromExif: false,
    );
    _reverseGeocode(point);
    _fetchLiveWeather(point.latitude, point.longitude);
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final res = await LocationSearchService.instance.reverseGeocode(
        point.latitude,
        point.longitude,
      );
      if (res != null && mounted) {
        _locationStateNotifier.value = _locationStateNotifier.value.copyWith(
          address: res.formattedAddress,
        );
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = res.name;
        }
        _searchController.text = res.formattedAddress;
      }
    } catch (_) {}
  }

  String _getRecommendationSubtitle(int score) {
    if (score <= 2) return '1–2 / 10 • Fair or skip if short on time';
    if (score <= 4) return '3–4 / 10 • Casual interest or minor stop';
    if (score <= 6) return '5–6 / 10 • Solid experience worth visiting';
    if (score <= 8) return '7–8 / 10 • Highly recommended waypoint';
    return '9–10 / 10 • Exceptional expedition highlight!';
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= 6) {
      WaymarkSnackbar.showInfo(context, context.l10n.placeLoggerMaxPhotos);
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null && mounted) {
        final bytes = await file.length();
        final ext = file.path.split('.').last.toUpperCase();
        final isFirst = _photos.isEmpty;
        _photosNotifier.value = [
          ..._photos,
          _AttachedPhotoItem(
            path: file.path,
            fileSizeBytes: bytes,
            format: ext.isEmpty ? 'JPG' : ext,
            isCover: isFirst,
          ),
        ];
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Failed to select photo: $e');
      }
    }
  }

  void _showAddPhotoSheet() {
    final colors = context.colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Grab Handle
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

                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          WaymarkSpacing.radiusFull,
                        ),
                      ),
                      child: Text(
                        'VISUAL RELICS',
                        style: ctx.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Attach Photo Artifact',
                  style: ctx.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Preserve photographic memories alongside this waypoint stop.',
                  style: ctx.textTheme.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: 18.h),

                // Option 1: Take Photo (Camera)
                _buildPhotoSourceTile(
                  context: ctx,
                  colors: colors,
                  title: 'Take Camera Photo',
                  subtitle:
                      'Capture a live shot directly from your device camera',
                  gradient: const [Color(0xFFE07A5F), Color(0xFFC85A17)],
                  icon: Icons.photo_camera_rounded,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                SizedBox(height: 10.h),

                // Option 2: Gallery Picker
                _buildPhotoSourceTile(
                  context: ctx,
                  colors: colors,
                  title: 'Choose from Gallery',
                  subtitle:
                      'Select high-resolution snapshots from your library',
                  gradient: const [Color(0xFF2A9D8F), Color(0xFF1B6B62)],
                  icon: Icons.photo_library_rounded,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                SizedBox(height: 10.h),

                // Option 3: Sample Travel Photos
                _buildPhotoSourceTile(
                  context: ctx,
                  colors: colors,
                  title: 'Sample Travel Photos',
                  subtitle:
                      'Explore curated demo shots (Kyoto, shrines, landscapes)',
                  gradient: const [Color(0xFF457B9D), Color(0xFF1D3557)],
                  icon: Icons.collections_rounded,
                  badge: 'DEMO',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showSamplePhotoPicker();
                  },
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSourceTile({
    required BuildContext context,
    required ColorScheme colors,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: colors.borderDivider.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.tertiary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              badge,
                              style: context.textTheme.caption.copyWith(
                                color: colors.tertiary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: context.textTheme.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11.5.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSamplePhoto(String assetPath) {
    if (_photos.length >= 6) {
      WaymarkSnackbar.showInfo(context, context.l10n.placeLoggerMaxPhotos);
      return;
    }
    final ext = assetPath.split('.').last.toUpperCase();
    final isFirst = _photos.isEmpty;
    _photosNotifier.value = [
      ..._photos,
      _AttachedPhotoItem(
        path: assetPath,
        fileSizeBytes: 2048,
        format: ext.isEmpty ? 'JPG' : ext,
        isCover: isFirst,
      ),
    ];
  }

  void _showSamplePhotoPicker() {
    final colors = context.colorScheme;
    final sampleImages = [
      'assets/images/place_one.jpeg',
      'assets/images/place_two.jpeg',
      'assets/images/place_three.jpeg',
      'assets/images/place_four.jpeg',
      'assets/images/place_five.jpeg',
      'assets/images/place_six.jpeg',
      'assets/images/place_seven.jpeg',
      'assets/images/place_eight.jpeg',
      'assets/images/place_nine.jpeg',
      'assets/images/place_ten.jpeg',
      'assets/images/place_eleven.jpeg',
      'assets/images/place_twelve.jpeg',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: colors.borderDivider.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Curated Travel Photos',
                            style: ctx.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Select any sample image to attach to this place',
                            style: ctx.textTheme.caption.copyWith(
                              color: colors.textSecondary,
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
                SizedBox(
                  height: 260.h,
                  child: GridView.builder(
                    itemCount: sampleImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final asset = sampleImages[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _addSamplePhoto(asset);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(asset, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoLightbox(BuildContext context, int initialIndex) {
    final colors = context.colorScheme;
    final photos = _photos;
    if (photos.isEmpty || initialIndex >= photos.length) return;

    int currentIndex = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final photo = photos[currentIndex];

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lightbox Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo ${currentIndex + 1} of ${photos.length}',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(photo.fileSizeBytes / 1024).round()} KB • ${photo.format}',
                              style: context.textTheme.caption.copyWith(
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Interactive Pinch-to-Zoom Image
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: Center(
                          child: _buildPhotoThumbnail(photo.path, colors),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Bottom Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Set as Cover Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: photo.isCover
                              ? colors.primary
                              : Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusFull,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                        icon: Icon(
                          photo.isCover
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 18.sp,
                          color: photo.isCover
                              ? Colors.amberAccent
                              : Colors.white,
                        ),
                        label: Text(
                          photo.isCover ? 'Cover Photo' : 'Set as Cover',
                          style: context.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          for (final p in photos) {
                            p.isCover = false;
                          }
                          photo.isCover = true;
                          _photosNotifier.value = List.of(photos);
                          setDialogState(() {});
                        },
                      ),
                      SizedBox(width: 12.w),

                      // Delete Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          foregroundColor: Colors.redAccent,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () {
                          final updated = List<_AttachedPhotoItem>.from(photos);
                          updated.removeAt(currentIndex);
                          if (photo.isCover && updated.isNotEmpty) {
                            updated.first.isCover = true;
                          }
                          _photosNotifier.value = updated;
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _visitedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_visitedAt),
    );
    if (pickedTime == null || !mounted) return;

    _visitedAtNotifier.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    _isSavingNotifier.value = true;

    try {
      final db = AppDatabase.instance;
      final name = _nameController.text.trim();
      final notes = _notesController.text.trim();
      final sensoryTags = 'rating:$_recommendationScale';

      if (_isEditing) {
        final existing = widget.placeToEdit!;
        final updatedPlace = existing.copyWith(
          name: name,
          notes: drift.Value(notes.isEmpty ? null : notes),
          latitude: _latitude,
          longitude: _longitude,
          visitedAt: _visitedAt,
          category: _category,
          weatherCondition: drift.Value(_weather),
          temperatureCelsius: drift.Value(_temperatureCelsius),
          locationAddress: drift.Value(_locationAddress),
          sensoryTags: drift.Value(sensoryTags),
          isGpsFromExif: _isGpsFromExif,
        );

        await db.tripPlaceDao.updatePlace(updatedPlace);

        // Sync attached photos
        final existingDbMedia = await db.placeMediaDao.getMediaForPlace(
          existing.id,
        );
        final currentMediaIds = _photos
            .map((p) => p.id)
            .whereType<String>()
            .toSet();

        for (final m in existingDbMedia) {
          if (!currentMediaIds.contains(m.id)) {
            await db.placeMediaDao.deleteMedia(m.id);
          }
        }

        for (final photo in _photos) {
          if (photo.id == null) {
            await db.placeMediaDao.insertMedia(
              PlaceMediaFilesCompanion(
                id: drift.Value(const Uuid().v4()),
                placeId: drift.Value(existing.id),
                localFilePath: drift.Value(photo.path),
                thumbnailPath: drift.Value(photo.path),
                fileSizeBytes: drift.Value(photo.fileSizeBytes),
                width: const drift.Value(800),
                height: const drift.Value(600),
                isCoverPhoto: drift.Value(photo.isCover),
                capturedAt: drift.Value(_visitedAt),
              ),
            );
          } else {
            final match = existingDbMedia.where((m) => m.id == photo.id);
            if (match.isNotEmpty) {
              final existingM = match.first;
              if (existingM.isCoverPhoto != photo.isCover) {
                await db.placeMediaDao.updateMedia(
                  existingM.copyWith(isCoverPhoto: photo.isCover),
                );
              }
            }
          }
        }

        final album = await db.tripAlbumDao.getAlbumById(widget.albumId);
        if (album != null && _photos.isNotEmpty) {
          final coverPhoto = _photos.firstWhere(
            (p) => p.isCover,
            orElse: () => _photos.first,
          );
          await db.tripAlbumDao.updateAlbum(
            album.copyWith(
              coverImagePath: drift.Value(coverPhoto.path),
              updatedAt: DateTime.now(),
            ),
          );
        }

        unawaited(_updateAlbumDistance(db, widget.albumId));

        if (mounted) {
          Navigator.of(context).pop();
          WaymarkSnackbar.showSuccess(
            context,
            context.l10n.placeLoggerUpdatedToast,
          );
        }
      } else {
        final places = await db.tripPlaceDao.getPlacesForAlbum(widget.albumId);
        final placeId = const Uuid().v4();

        await db.tripPlaceDao.insertPlace(
          TripPlacesCompanion(
            id: drift.Value(placeId),
            albumId: drift.Value(widget.albumId),
            name: drift.Value(name),
            notes: drift.Value(notes.isEmpty ? null : notes),
            latitude: drift.Value(_latitude),
            longitude: drift.Value(_longitude),
            visitedAt: drift.Value(_visitedAt),
            visitOrder: drift.Value(places.length),
            category: drift.Value(_category),
            weatherCondition: drift.Value(_weather),
            temperatureCelsius: drift.Value(_temperatureCelsius),
            locationAddress: drift.Value(_locationAddress),
            sensoryTags: drift.Value(sensoryTags),
            isGpsFromExif: drift.Value(_isGpsFromExif),
          ),
        );

        for (final photo in _photos) {
          await db.placeMediaDao.insertMedia(
            PlaceMediaFilesCompanion(
              id: drift.Value(const Uuid().v4()),
              placeId: drift.Value(placeId),
              localFilePath: drift.Value(photo.path),
              thumbnailPath: drift.Value(photo.path),
              fileSizeBytes: drift.Value(photo.fileSizeBytes),
              width: const drift.Value(800),
              height: const drift.Value(600),
              isCoverPhoto: drift.Value(photo.isCover),
              capturedAt: drift.Value(_visitedAt),
            ),
          );
        }

        final album = await db.tripAlbumDao.getAlbumById(widget.albumId);
        if (album != null) {
          String? coverPath = album.coverImagePath;
          if (_photos.isNotEmpty) {
            final coverPhoto = _photos.firstWhere(
              (p) => p.isCover,
              orElse: () => _photos.first,
            );
            coverPath = coverPhoto.path;
          }
          await db.tripAlbumDao.updateAlbum(
            album.copyWith(
              totalPlacesCount: places.length + 1,
              coverImagePath: drift.Value(coverPath),
              updatedAt: DateTime.now(),
            ),
          );
        }

        unawaited(_updateAlbumDistance(db, widget.albumId));

        if (mounted) {
          Navigator.of(context).pop();
          WaymarkSnackbar.showSuccess(
            context,
            context.l10n.placeLoggerSuccessToast,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        WaymarkSnackbar.showError(context, 'Failed to save place: $e');
      }
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  Future<void> _updateAlbumDistance(AppDatabase db, String albumId) async {
    try {
      final places = await db.tripPlaceDao.getPlacesForAlbum(albumId);
      if (places.length < 2) return;

      final waypoints = places
          .map((p) => (latitude: p.latitude, longitude: p.longitude))
          .toList();

      double total = 0.0;
      const distCalc = Distance();
      for (int i = 0; i < places.length - 1; i++) {
        total += distCalc.as(
          LengthUnit.Kilometer,
          LatLng(places[i].latitude, places[i].longitude),
          LatLng(places[i + 1].latitude, places[i + 1].longitude),
        );
      }

      final result = await LocationSearchService.instance.fetchRoutePolyline(
        waypoints,
      );
      final resolvedKm = (result != null && result.points.isNotEmpty)
          ? result.distanceKm
          : total;

      final album = await db.tripAlbumDao.getAlbumById(albumId);
      if (album != null) {
        await db.tripAlbumDao.updateAlbum(
          album.copyWith(
            totalDistanceKm: resolvedKm,
            updatedAt: DateTime.now(),
          ),
        );
      }
    } catch (_) {}
  }

  String _getCategoryLabel(BuildContext context, String key) {
    switch (key) {
      case 'SIGHTSEEING':
        return 'Sightseeing';
      case 'FOOD':
        return 'Dining';
      case 'COFFEE':
        return 'Coffee';
      case 'STAY':
        return 'Stay';
      case 'HIKE':
        return 'Hiking';
      case 'TRANSIT':
        return 'Transit';
      default:
        return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final title = widget.albumTitle ?? 'Expedition';
    final routeOrder = (_existingVisitOrder + 1).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: colors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing
              ? context.l10n.placeLoggerEditPlace
              : context.l10n.placeLoggerLogNewPlace,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: WaymarkSpacing.margin(context),
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      key: const Key('place_logger_save_button'),
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            WaymarkSpacing.radiusFull,
                          ),
                        ),
                        elevation: 4,
                        shadowColor: colors.primary.withValues(alpha: 0.4),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_location_alt_rounded,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    _isEditing
                                        ? context.l10n
                                              .placeLoggerUpdatePlaceInJourney(
                                                title,
                                              )
                                        : context.l10n.placeLoggerLogToJourney(
                                            title,
                                          ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 6.h),
              Center(
                child: Text(
                  context.l10n.placeLoggerSyncSubtitle(routeOrder),
                  style: context.textTheme.caption.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: bottomInset + 20.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar & Dropdown
              ValueListenableBuilder<_SearchState>(
                valueListenable: _searchStateNotifier,
                builder: (context, searchState, _) {
                  final searchResults = searchState.results;
                  final isSearching = searchState.isSearching;
                  final searchPerformed = searchState.searchPerformed;
                  final showAllSearchResults = searchState.showAll;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: context.l10n.placeLoggerSearchPlaceholder,
                            hintStyle: TextStyle(
                              color: colors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colors.textSecondary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.cancel_rounded,
                                      color: colors.textSecondary,
                                      size: 18.sp,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : (isSearching
                                      ? Padding(
                                          padding: EdgeInsets.all(12.w),
                                          child: SizedBox(
                                            width: 16.w,
                                            height: 16.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.primary,
                                            ),
                                          ),
                                        )
                                      : null),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),

                      // Search Suggestions Dropdown or Shimmer Loading Skeleton
                      if (isSearching) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Searching places & addresses...',
                                    style: context.textTheme.caption.copyWith(
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              ...List.generate(3, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  child: Row(
                                    children: [
                                      WaymarkShimmerBox(
                                        width: 32.w,
                                        height: 32.w,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WaymarkShimmerBox(
                                              width: 130.w + (index * 25.w),
                                              height: 13.h,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            SizedBox(height: 5.h),
                                            WaymarkShimmerBox(
                                              width: double.infinity,
                                              height: 10.h,
                                              borderRadius:
                                                  BorderRadius.circular(3.r),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ] else if (searchResults.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Container(
                          constraints: BoxConstraints(maxHeight: 280.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(12.r),
                            clipBehavior: Clip.antiAlias,
                            child: ListView(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              children: [
                                ...(showAllSearchResults
                                        ? searchResults
                                        : searchResults.take(10))
                                    .map((res) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            dense: true,
                                            leading: Icon(
                                              Icons.place_outlined,
                                              color: colors.primary,
                                            ),
                                            title: Text(
                                              res.name,
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            subtitle: Text(
                                              res.formattedAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: context.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colors.textSecondary,
                                                  ),
                                            ),
                                            onTap: () =>
                                                _selectSearchResult(res),
                                          ),
                                          Divider(
                                            height: 1,
                                            color: colors.borderDivider,
                                          ),
                                        ],
                                      );
                                    }),
                                if (searchResults.length > 10 &&
                                    !showAllSearchResults)
                                  InkWell(
                                    onTap: () {
                                      _searchStateNotifier.value = searchState
                                          .copyWith(showAll: true);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      alignment: Alignment.center,
                                      color: colors.surfaceContainerLow,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'View all (${searchResults.length} places)',
                                            style: context.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: colors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 18.sp,
                                            color: colors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (searchResults.length > 10 &&
                                    showAllSearchResults)
                                  InkWell(
                                    onTap: () {
                                      _searchStateNotifier.value = searchState
                                          .copyWith(showAll: false);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                      ),
                                      alignment: Alignment.center,
                                      color: colors.surfaceContainerLow,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Show less',
                                            style: context.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: colors.textSecondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(
                                            Icons.keyboard_arrow_up_rounded,
                                            size: 18.sp,
                                            color: colors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Banner unlocking map dragging only when no search results found
                      if (searchPerformed &&
                          searchResults.isEmpty &&
                          _searchController.text.trim().isNotEmpty &&
                          !isSearching) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFFFD8A8)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.pan_tool_rounded,
                                color: const Color(0xFFC85A17),
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No results found for "${_searchController.text.trim()}"',
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF7C2D12),
                                          ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Map dragging is now unlocked. Drag or tap the map below to position your place marker.',
                                      style: context.textTheme.caption.copyWith(
                                        color: const Color(0xFF9A3412),
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              SizedBox(height: 12.h),

              // 2. Smart EXIF Pill Banner
              ValueListenableBuilder<_LocationState>(
                valueListenable: _locationStateNotifier,
                builder: (context, locationState, _) {
                  final coords = locationState.coordinates;
                  final address = locationState.address;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFADF2C3).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: const Color(0xFF005228),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.placeLoggerDetectedGpsTitle,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002110),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${coords.latitude.toStringAsFixed(4)}° N, ${coords.longitude.toStringAsFixed(4)}° E — ${address ?? "Current GPS Location"}',
                                style: context.textTheme.caption.copyWith(
                                  color: const Color(0xFF005228),
                                  fontSize: 10.sp,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              WaymarkSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            context.l10n.placeLoggerMatched,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF005228),
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 12.h),

              // 3. Interactive Map Preview with Terracotta Draggable Beacon
              ValueListenableBuilder<_SearchState>(
                valueListenable: _searchStateNotifier,
                builder: (context, searchState, _) {
                  return ValueListenableBuilder<_LocationState>(
                    valueListenable: _locationStateNotifier,
                    builder: (context, locationState, _) {
                      final canDragMap = searchState.canDragMap;
                      final coords = locationState.coordinates;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          height: 320.h,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: coords,
                                  initialZoom: 15.0,
                                  interactionOptions: InteractionOptions(
                                    flags: canDragMap
                                        ? InteractiveFlag.all
                                        : (InteractiveFlag.pinchZoom |
                                              InteractiveFlag.doubleTapZoom),
                                  ),
                                  onTap: (tapPosition, point) {
                                    if (canDragMap) {
                                      _onMapTap(tapPosition, point);
                                    }
                                  },
                                  onPositionChanged: (camera, hasGesture) {
                                    if (canDragMap && hasGesture) {
                                      _locationStateNotifier.value =
                                          locationState.copyWith(
                                            coordinates: camera.center,
                                            isGpsFromExif: false,
                                          );
                                      _mapMoveDebounce?.cancel();
                                      _mapMoveDebounce = Timer(
                                        const Duration(milliseconds: 400),
                                        () {
                                          if (mounted) {
                                            _reverseGeocode(camera.center);
                                            _fetchLiveWeather(
                                              camera.center.latitude,
                                              camera.center.longitude,
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'app.waymark.journal',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: coords,
                                        width: 52.w,
                                        height: 52.w,
                                        alignment: Alignment.center,
                                        child: _buildPinMarker(context, colors),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Map Drag/Lock Mode Status Pill (Top Left)
                              Positioned(
                                top: 10.h,
                                left: 10.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: canDragMap
                                        ? const Color(0xFF005228)
                                        : colors.surfaceCard.withValues(
                                            alpha: 0.94,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      WaymarkSpacing.radiusFull,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        canDragMap
                                            ? Icons.pan_tool_rounded
                                            : Icons.lock_outline_rounded,
                                        size: 13.sp,
                                        color: canDragMap
                                            ? Colors.white
                                            : colors.textSecondary,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        canDragMap
                                            ? 'Drag unlocked (No results)'
                                            : 'Location locked • Search to place',
                                        style: context.textTheme.caption
                                            .copyWith(
                                              color: canDragMap
                                                  ? Colors.white
                                                  : colors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.5.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Bottom-right mini actions (Recenter)
                              Positioned(
                                bottom: 8.h,
                                right: 8.w,
                                child: FloatingActionButton.small(
                                  heroTag: 'recenter-map-pin',
                                  backgroundColor: colors.surfaceCard,
                                  elevation: 2,
                                  onPressed: () {
                                    _mapController.move(coords, 15.0);
                                  },
                                  child: Icon(
                                    Icons.my_location_rounded,
                                    color: colors.textPrimary,
                                    size: 18.sp,
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

              SizedBox(height: 16.h),

              // 4. Place Identity & Category Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.placeLoggerPlaceIdentity,
                      style: context.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? context.l10n.commonRequired
                          : null,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.placeLoggerNameHint,
                        fillColor: colors.surfaceContainerLow,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      context.l10n.placeLoggerCategoryTag,
                      style: context.textTheme.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ValueListenableBuilder<String>(
                      valueListenable: _categoryNotifier,
                      builder: (context, selectedCategory, _) {
                        return Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _categoryOptions.map((cat) {
                            final name = cat['name'] as String;
                            final icon = cat['icon'] as IconData;
                            final isSel = selectedCategory == name;
                            return InkWell(
                              borderRadius: BorderRadius.circular(
                                WaymarkSpacing.radiusFull,
                              ),
                              onTap: () => _categoryNotifier.value = name,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? colors.primary
                                      : colors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    WaymarkSpacing.radiusFull,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: colors.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 15.sp,
                                      color: isSel
                                          ? Colors.white
                                          : colors.textSecondary,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      _getCategoryLabel(context, name),
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                            color: isSel
                                                ? Colors.white
                                                : colors.textPrimary,
                                            fontWeight: isSel
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // 5. Visited Time & Weather Cards (2-Column Grid)
              Row(
                children: [
                  // Visited Time Card
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _visitedAtNotifier,
                    builder: (context, visitedAt, _) {
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: _pickDateTime,
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: colors.surfaceCard,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18.sp,
                                    color: colors.primary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.placeLoggerVisitedTime,
                                        style: context.textTheme.caption
                                            .copyWith(
                                              color: colors.textSecondary,
                                            ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        DateFormat(
                                          'MMM d • HH:mm',
                                        ).format(visitedAt),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10.w),
                  // Live Real-Time Weather Card (Open-Meteo)
                  ValueListenableBuilder<_WeatherState>(
                    valueListenable: _weatherStateNotifier,
                    builder: (context, weatherState, _) {
                      final weather = weatherState.condition;
                      final temp = weatherState.temperatureCelsius;
                      final isFetching = weatherState.isFetching;

                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: () {
                            _showWeatherDetailsModal(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: colors.surfaceCard,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFDEA9,
                                    ).withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: isFetching
                                      ? Padding(
                                          padding: EdgeInsets.all(9.w),
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF7A5500),
                                              ),
                                        )
                                      : Icon(
                                          weather == 'Rainy' ||
                                                  weather == 'Showers'
                                              ? Icons.water_drop_rounded
                                              : (_weather == 'Cloudy' ||
                                                        _weather ==
                                                            'Partly Cloudy'
                                                    ? Icons.cloud_rounded
                                                    : Icons.wb_sunny_rounded),
                                          size: 18.sp,
                                          color: const Color(0xFF7A5500),
                                        ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Live Weather',
                                              style: context.textTheme.caption
                                                  .copyWith(
                                                    color: colors.textSecondary,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Container(
                                            width: 5.w,
                                            height: 5.w,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF007A3D),
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 13.sp,
                                            color: colors.textSecondary
                                                .withValues(alpha: 0.8),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        isFetching
                                            ? 'Updating...'
                                            : '${temp.round()}°C • $weather',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.textPrimary,
                                              fontSize: 11.5.sp,
                                              height: 1.2,
                                            ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Tap for details ›',
                                        style: context.textTheme.caption
                                            .copyWith(
                                              color: colors.textSecondary
                                                  .withValues(alpha: 0.8),
                                              fontSize: 9.5.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // 6. Visual Relics & Photos Tray (Polaroid Tactile Style)
              ValueListenableBuilder<List<_AttachedPhotoItem>>(
                valueListenable: _photosNotifier,
                builder: (context, photos, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.placeLoggerVisualRelics,
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${photos.length} of 6 attached',
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 175.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length + 1,
                          separatorBuilder: (_, _) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            if (index == photos.length) {
                              // Add Photo Card
                              return InkWell(
                                borderRadius: BorderRadius.circular(14.r),
                                onTap: _showAddPhotoSheet,
                                child: Container(
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: colors.borderDivider,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 38.w,
                                        height: 38.w,
                                        decoration: BoxDecoration(
                                          color: colors.surfaceCard,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo_outlined,
                                          color: colors.primary,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        context.l10n.placeLoggerAddPhoto,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.textPrimary,
                                            ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        context.l10n.placeLoggerMaxPhotos,
                                        style: context.textTheme.caption
                                            .copyWith(
                                              color: colors.textSecondary,
                                              fontSize: 10.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final item = photos[index];
                            final rotationZ = index % 2 == 0 ? -0.015 : 0.015;

                            return Transform(
                              transform: Matrix4.rotationZ(rotationZ),
                              alignment: Alignment.center,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14.r),
                                onTap: () => _showPhotoLightbox(context, index),
                                child: Container(
                                  width: 125.w,
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceCard,
                                    borderRadius: BorderRadius.circular(14.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              child: _buildPhotoThumbnail(
                                                item.path,
                                                colors,
                                              ),
                                            ),
                                            if (item.isCover)
                                              Positioned(
                                                top: 6.h,
                                                left: 6.w,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          WaymarkSpacing
                                                              .radiusFull,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        blurRadius: 3,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.white,
                                                        size: 11.sp,
                                                      ),
                                                      SizedBox(width: 2.w),
                                                      Text(
                                                        context
                                                            .l10n
                                                            .placeLoggerCoverBadge,
                                                        style: context
                                                            .textTheme
                                                            .caption
                                                            .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 9.sp,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              top: 4.h,
                                              right: 4.w,
                                              child: Material(
                                                color: Colors.black.withValues(
                                                  alpha: 0.4,
                                                ),
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const CircleBorder(),
                                                  onTap: () {
                                                    final updated =
                                                        List<
                                                          _AttachedPhotoItem
                                                        >.from(photos);
                                                    updated.removeAt(index);
                                                    if (item.isCover &&
                                                        updated.isNotEmpty) {
                                                      updated.first.isCover =
                                                          true;
                                                    }
                                                    _photosNotifier.value =
                                                        updated;
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      4.w,
                                                    ),
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      size: 14.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${(item.fileSizeBytes / 1024).round()} KB',
                                              style: context.textTheme.caption
                                                  .copyWith(
                                                    color: colors.textSecondary,
                                                    fontSize: 10.sp,
                                                  ),
                                            ),
                                            Text(
                                              item.format,
                                              style: context.textTheme.caption
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colors.secondary,
                                                    fontSize: 10.sp,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 16.h),

              // 7. Description & Field Notes Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: colors.primary,
                                size: 20.sp,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  'Description & Notes',
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _notesController,
                          builder: (context, _, _) {
                            return Text(
                              '$_wordCount words',
                              style: context.textTheme.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      minLines: 3,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Record the history, architecture, atmosphere, or memorable moments of this waypoint...',
                        hintStyle: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.65),
                          fontSize: 13.sp,
                        ),
                        fillColor: colors.surfaceContainerLow,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 8. Animated Recommendation Scale (1 to 10)
              ValueListenableBuilder<int>(
                valueListenable: _recommendationScaleNotifier,
                builder: (context, recommendationScale, _) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.recommend_rounded,
                                    color: const Color(0xFFD97706),
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      'Recommendation Scale',
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Animated badge displaying the score
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(
                                  WaymarkSpacing.radiusFull,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD97706,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14.sp,
                                    color: const Color(0xFFD97706),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '$recommendationScale / 10',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF92400E),
                                          fontSize: 11.sp,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // Animated qualitative recommendation title
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            _getRecommendationSubtitle(recommendationScale),
                            key: ValueKey<int>(recommendationScale),
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11.5.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // 1 to 10 Numbered interactive animated selectors
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final buttonWidth =
                                (constraints.maxWidth - (9 * 6.w)) / 10;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(10, (i) {
                                final score = i + 1;
                                final isSelected = recommendationScale == score;
                                return GestureDetector(
                                  onTap: () {
                                    _recommendationScaleNotifier.value = score;
                                  },
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutBack,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: buttonWidth.clamp(24.w, 36.w),
                                      height: 36.h,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFD97706)
                                            : colors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFD97706,
                                                  ).withValues(alpha: 0.35),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$score',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? Colors.white
                                                  : colors.textPrimary,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              fontSize: 12.sp,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
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
      child: Icon(
        Icons.photo_rounded,
        color: colors.textSecondary,
        size: 32.sp,
      ),
    );
  }

  Widget _buildPinMarker(BuildContext context, ColorScheme colors) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing halo
            Container(
              width: 38.w + (14.w * pulse),
              height: 38.w + (14.w * pulse),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFFC85A17,
                ).withValues(alpha: 0.3 * (1 - pulse)),
              ),
            ),
            // Tactile amber pin circle
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC85A17),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWeatherDetailsModal(BuildContext context) {
    final colors = context.colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ValueListenableBuilder<_WeatherState>(
          valueListenable: _weatherStateNotifier,
          builder: (context, weatherState, _) {
            final currentWeather = weatherState.weather;
            final isFetching = weatherState.isFetchingWeather;
            final temp = weatherState.temperatureCelsius;
            final apparent = weatherState.apparentTemp;
            final humidity = weatherState.humidity;
            final wind = weatherState.windSpeed;

            return Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDEA9).withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentWeather == 'Rainy' ||
                                  currentWeather == 'Showers'
                              ? Icons.water_drop_rounded
                              : (currentWeather == 'Cloudy' ||
                                        currentWeather == 'Partly Cloudy'
                                    ? Icons.cloud_rounded
                                    : Icons.wb_sunny_rounded),
                          size: 22.sp,
                          color: const Color(0xFF7A5500),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Live Weather Intel',
                                  style: context.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: colors.textPrimary,
                                      ),
                                ),
                                SizedBox(width: 6.w),
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF007A3D),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Open-Meteo Global Observation',
                              style: context.textTheme.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh Weather',
                        icon: isFetching
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                size: 20.sp,
                                color: colors.textSecondary,
                              ),
                        onPressed: isFetching
                            ? null
                            : () async {
                                await _fetchLiveWeather(_latitude, _longitude);
                              },
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Main highlight banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFF8E7),
                          colors.surfaceContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE5D5BA).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentWeather,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: const Color(0xFF7A5500),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getWeatherDescription(currentWeather),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${temp.round()}°C',
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherMetricTile(
                          context: context,
                          colors: colors,
                          icon: Icons.thermostat_rounded,
                          label: 'Feels Like',
                          value: apparent != null
                              ? '${apparent.round()}°C'
                              : '${temp.round()}°C',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildWeatherMetricTile(
                          context: context,
                          colors: colors,
                          icon: Icons.water_drop_outlined,
                          label: 'Humidity',
                          value: humidity != null ? '$humidity%' : 'Normal',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildWeatherMetricTile(
                          context: context,
                          colors: colors,
                          icon: Icons.air_rounded,
                          label: 'Wind Speed',
                          value: wind != null
                              ? '${wind.toStringAsFixed(1)} km/h'
                              : '< 15 km/h',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Coordinates info badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_searching_rounded,
                          size: 14.sp,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Coords: ${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E',
                            style: context.textTheme.caption.copyWith(
                              color: colors.textSecondary,
                              fontFamily: 'monospace',
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
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

  Widget _buildWeatherMetricTile({
    required BuildContext context,
    required ColorScheme colors,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: colors.primary),
          SizedBox(height: 6.h),
          Text(
            value,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: context.textTheme.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeatherDescription(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') ||
        lower.contains('drizzle') ||
        lower.contains('shower')) {
      return 'Precipitation observed. Carry weather protection for optics and journals.';
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return 'Soft, diffused skylight ideal for high-contrast architectural portraits.';
    } else if (lower.contains('snow') || lower.contains('frost')) {
      return 'Freezing temperatures. Ensure battery packs are kept warm.';
    } else if (lower.contains('clear') || lower.contains('sun')) {
      return 'Luminous atmospheric transparency with crisp directional shadows.';
    }
    return 'Stable conditions logged for expedition cataloging.';
  }
}
