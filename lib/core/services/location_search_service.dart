import 'dart:async';
import 'package:dio/dio.dart';

/// Represents a standardized location search result from OpenStreetMap / Photon geocoding.
class LocationSearchResult {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String
  category; // 'SIGHTSEEING', 'FOOD', 'STAY', 'HIKE', 'TRANSIT', 'GENERAL'

  const LocationSearchResult({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.category = 'GENERAL',
  });

  @override
  String toString() => '$name ($latitude, $longitude)';
}

/// Service providing global location search and reverse-geocoding via Dio
/// backed by OpenStreetMap (Photon & Nominatim) with an offline fallback dictionary.
class LocationSearchService {
  final Dio _dio;

  LocationSearchService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
              headers: {
                'User-Agent': 'WaymarkApp/1.0.0 (contact: support@waymark.app)',
                'Accept': 'application/json',
              },
            ),
          );

  static final LocationSearchService instance = LocationSearchService();

  /// Search places worldwide matching [query] with cancellation support.
  Future<List<LocationSearchResult>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      // 1. Primary: Photon OpenStreetMap geocoder API (fast, high rate-limit, global)
      final response = await _dio.get<Map<String, dynamic>>(
        'https://photon.komoot.io/api/',
        queryParameters: {'q': cleanQuery, 'limit': 25},
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null && data['features'] is List) {
        final features = data['features'] as List;
        final results = <LocationSearchResult>[];

        for (final item in features) {
          if (item is! Map<String, dynamic>) continue;
          final properties = item['properties'] as Map<String, dynamic>? ?? {};
          final geometry = item['geometry'] as Map<String, dynamic>? ?? {};
          final coordinates = geometry['coordinates'] as List?;

          if (coordinates == null || coordinates.length < 2) continue;

          final lng = (coordinates[0] as num).toDouble();
          final lat = (coordinates[1] as num).toDouble();

          final name =
              properties['name:en']?.toString() ??
              properties['name']?.toString() ??
              properties['street']?.toString() ??
              cleanQuery;

          final addressParts = <String>[];
          if (properties['street'] != null && properties['street'] != name) {
            addressParts.add(properties['street'].toString());
          }
          if (properties['city'] != null) {
            addressParts.add(properties['city'].toString());
          } else if (properties['district'] != null) {
            addressParts.add(properties['district'].toString());
          }
          if (properties['state'] != null) {
            addressParts.add(properties['state'].toString());
          }
          if (properties['country'] != null) {
            addressParts.add(properties['country'].toString());
          }

          final formattedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : (properties['name']?.toString() ?? cleanQuery);

          final osmKey = properties['osm_key']?.toString();
          final osmValue = properties['osm_value']?.toString();
          final category = _mapOsmCategory(osmKey, osmValue);

          results.add(
            LocationSearchResult(
              name: name,
              formattedAddress: formattedAddress,
              latitude: lat,
              longitude: lng,
              category: category,
            ),
          );
        }

        if (results.isNotEmpty) return results;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      // Fall through to secondary or offline fallback
    } catch (_) {
      // Fall through to fallback
    }

    // 2. Secondary: Nominatim OpenStreetMap
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': cleanQuery,
          'format': 'json',
          'limit': 25,
          'addressdetails': 1,
        },
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null && data.isNotEmpty) {
        final results = <LocationSearchResult>[];
        for (final item in data) {
          if (item is! Map<String, dynamic>) continue;
          final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lng = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          final displayName = item['display_name']?.toString() ?? cleanQuery;
          final name =
              item['name']?.toString() ?? displayName.split(',').first.trim();

          final type = item['type']?.toString();
          final category = _mapOsmCategory(item['class']?.toString(), type);

          results.add(
            LocationSearchResult(
              name: name.isNotEmpty ? name : cleanQuery,
              formattedAddress: displayName,
              latitude: lat,
              longitude: lng,
              category: category,
            ),
          );
        }
        if (results.isNotEmpty) return results;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
    } catch (_) {
      // Ignore network errors and use offline fallback
    }

    // 3. Offline / Mock Fallback dictionary
    return _searchOfflineDictionary(cleanQuery);
  }

  /// Reverse geocode coordinates to an address using OpenStreetMap Nominatim.
  Future<LocationSearchResult?> reverseGeocode(
    double latitude,
    double longitude, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'addressdetails': 1,
        },
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null) {
        final displayName = data['display_name']?.toString() ?? '';
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final name =
            data['name']?.toString() ??
            address['amenity']?.toString() ??
            address['tourism']?.toString() ??
            address['historic']?.toString() ??
            address['road']?.toString() ??
            displayName.split(',').first.trim();

        final cleanName = name.isNotEmpty
            ? name
            : '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';

        return LocationSearchResult(
          name: cleanName,
          formattedAddress: displayName.isNotEmpty ? displayName : cleanName,
          latitude: latitude,
          longitude: longitude,
          category: _mapOsmCategory(
            data['class']?.toString(),
            data['type']?.toString(),
          ),
        );
      }
    } catch (_) {
      // Network failed or offline
    }

    // Fallback based on coordinates
    return LocationSearchResult(
      name: '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°',
      formattedAddress:
          'Pinned Map Coordinates (${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})',
      latitude: latitude,
      longitude: longitude,
    );
  }

  String _mapOsmCategory(String? osmKey, String? osmValue) {
    if (osmKey == null && osmValue == null) return 'GENERAL';
    final key = (osmKey ?? '').toLowerCase();
    final val = (osmValue ?? '').toLowerCase();

    if (key == 'tourism' ||
        val == 'attraction' ||
        val == 'museum' ||
        val == 'viewpoint' ||
        val == 'temple' ||
        val == 'monument' ||
        val == 'historic') {
      return 'SIGHTSEEING';
    }
    if (key == 'amenity' &&
        (val == 'restaurant' || val == 'fast_food' || val == 'food_court')) {
      return 'FOOD';
    }
    if (val == 'cafe' || val == 'coffee') {
      return 'COFFEE';
    }
    if (key == 'tourism' &&
        (val == 'hotel' ||
            val == 'hostel' ||
            val == 'guest_house' ||
            val == 'motel')) {
      return 'STAY';
    }
    if (key == 'highway' && val == 'path' ||
        val == 'trail' ||
        val == 'hiking' ||
        val == 'peak') {
      return 'HIKE';
    }
    if (key == 'railway' ||
        key == 'station' ||
        val == 'subway' ||
        val == 'bus_stop' ||
        val == 'tram_stop') {
      return 'TRANSIT';
    }
    return 'GENERAL';
  }

  List<LocationSearchResult> _searchOfflineDictionary(String query) {
    final lower = query.toLowerCase();
    return _offlineLandmarks
        .where(
          (l) =>
              l.name.toLowerCase().contains(lower) ||
              l.formattedAddress.toLowerCase().contains(lower),
        )
        .toList();
  }

  static const List<LocationSearchResult> _offlineLandmarks = [
    LocationSearchResult(
      name: 'Kiyomizu-dera Temple',
      formattedAddress: '1-294 Kiyomizu, Higashiyama Ward, Kyoto, Japan',
      latitude: 34.9949,
      longitude: 135.7850,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Fushimi Inari Taisha',
      formattedAddress: '68 Fukakusa Yabunouchicho, Fushimi Ward, Kyoto, Japan',
      latitude: 34.9671,
      longitude: 135.7727,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Arashiyama Bamboo Grove',
      formattedAddress: 'Ukyo Ward, Kyoto, 616-8394, Japan',
      latitude: 35.0170,
      longitude: 135.6713,
      category: 'HIKE',
    ),
    LocationSearchResult(
      name: 'Kinkaku-ji (Golden Pavilion)',
      formattedAddress: '1 Kinkakujicho, Kita Ward, Kyoto, Japan',
      latitude: 35.0394,
      longitude: 135.7292,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Gion Historic District',
      formattedAddress: 'Higashiyama Ward, Kyoto, Japan',
      latitude: 35.0037,
      longitude: 135.7772,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Nara Park & Todaiji',
      formattedAddress: '406-1 Zoshicho, Nara, 630-8211, Japan',
      latitude: 34.6851,
      longitude: 135.8430,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Osaka Castle',
      formattedAddress: '1-1 Osakajo, Chuo Ward, Osaka, 540-0002, Japan',
      latitude: 34.6873,
      longitude: 135.5262,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Dotonbori Canal Walk',
      formattedAddress: 'Chuo Ward, Osaka, Japan',
      latitude: 34.6687,
      longitude: 135.5013,
      category: 'FOOD',
    ),
    LocationSearchResult(
      name: 'Tokyo Tower',
      formattedAddress: '4 Chome-2-8 Shibakoen, Minato City, Tokyo, Japan',
      latitude: 35.6586,
      longitude: 139.7454,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Shibuya Crossing',
      formattedAddress: 'Shibuya City, Tokyo, Japan',
      latitude: 35.6595,
      longitude: 139.7004,
      category: 'TRANSIT',
    ),
    LocationSearchResult(
      name: 'Eiffel Tower',
      formattedAddress:
          'Champ de Mars, 5 Av. Anatole France, 75007 Paris, France',
      latitude: 48.8584,
      longitude: 2.2945,
      category: 'SIGHTSEEING',
    ),
    LocationSearchResult(
      name: 'Central Park',
      formattedAddress: 'New York, NY, United States',
      latitude: 40.785091,
      longitude: -73.968285,
      category: 'HIKE',
    ),
    LocationSearchResult(
      name: 'Boudhanath Stupa',
      formattedAddress: 'Kathmandu 44600, Nepal',
      latitude: 27.7215,
      longitude: 85.3620,
      category: 'SIGHTSEEING',
    ),
  ];

  /// Fetch live real-time weather from Open-Meteo free API
  Future<
    ({
      double temperature,
      String condition,
      double? apparentTemperature,
      int? humidity,
      double? windSpeed,
    })?
  >
  fetchCurrentWeather(
    double latitude,
    double longitude, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        },
        cancelToken: cancelToken,
      );

      final current = response.data?['current'];
      if (current != null) {
        final temp = (current['temperature_2m'] as num).toDouble();
        final code = current['weather_code'] as int? ?? 0;
        final condition = _mapWeatherCodeToCondition(code);
        final apparent = (current['apparent_temperature'] as num?)?.toDouble();
        final hum = (current['relative_humidity_2m'] as num?)?.toInt();
        final wind = (current['wind_speed_10m'] as num?)?.toDouble();
        return (
          temperature: temp,
          condition: condition,
          apparentTemperature: apparent,
          humidity: hum,
          windSpeed: wind,
        );
      }
    } catch (_) {}
    return null;
  }

  static String _mapWeatherCodeToCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain Showers';
    if (code >= 71 && code <= 77) return 'Snow Fall';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Clear';
  }

  /// Fetch real road route geometry and distance via OSRM public routing API.
  /// Waypoints must have at least 2 points.
  /// Returns coordinates as a list of (latitude, longitude) and distance in km.
  Future<
    ({List<({double latitude, double longitude})> points, double distanceKm})?
  >
  fetchRoutePolyline(
    List<({double latitude, double longitude})> waypoints, {
    CancelToken? cancelToken,
  }) async {
    if (waypoints.length < 2) return null;
    try {
      final coordsString = waypoints
          .map((w) => '${w.longitude},${w.latitude}')
          .join(';');
      final response = await _dio.get<Map<String, dynamic>>(
        'https://router.project-osrm.org/route/v1/driving/$coordsString',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data != null && data['code'] == 'Ok') {
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>?;
          final coords = geometry?['coordinates'] as List?;
          final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;

          if (coords != null && coords.isNotEmpty) {
            final polylinePoints = <({double latitude, double longitude})>[];
            for (final pair in coords) {
              if (pair is List && pair.length >= 2) {
                final lng = (pair[0] as num).toDouble();
                final lat = (pair[1] as num).toDouble();
                polylinePoints.add((latitude: lat, longitude: lng));
              }
            }
            return (
              points: polylinePoints,
              distanceKm: distanceMeters / 1000.0,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
