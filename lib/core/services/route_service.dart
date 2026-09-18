import 'dart:convert';
import 'dart:io';

/// Service for route computation between geographic coordinates.
/// Uses the free public OSRM routing API (no API key required).
/// Implements the Google Polyline Algorithm for encoding/decoding.
class RouteService {
  static const String _osrmBaseUrl = 'router.project-osrm.org';

  /// Decodes a Google Encoded Polyline string into a list of [lat, lng] pairs.
  static List<List<double>> decodeEncodedPolyline(String encoded) {
    final List<List<double>> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add([lat / 1e5, lng / 1e5]);
    }
    return points;
  }

  /// Encodes a list of [lat, lng] pairs into a Google Encoded Polyline string.
  static String encodePolyline(List<List<double>> points) {
    final StringBuffer result = StringBuffer();
    for (final point in points) {
      result.write(_encodeValue((point[0] * 1e5).round()));
      result.write(_encodeValue((point[1] * 1e5).round()));
    }
    return result.toString();
  }

  static String _encodeValue(int value) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    final StringBuffer encoded = StringBuffer();
    while (value >= 0x20) {
      encoded.writeCharCode(((0x20 | (value & 0x1f)) + 63));
      value >>= 5;
    }
    encoded.writeCharCode(value + 63);
    return encoded.toString();
  }

  /// Fetches a driving route between two coordinates using the free OSRM API.
  /// Returns null on network failure or invalid response.
  /// OSRM endpoint: http://router.project-osrm.org/route/v1/driving/{lng1},{lat1};{lng2},{lat2}?overview=full&geometries=polyline
  static Future<({String encodedPolyline, double distanceMeters})?>
  fetchOsrmRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final uri = Uri.http(
        _osrmBaseUrl,
        '/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat',
        {'overview': 'full', 'geometries': 'polyline'},
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['code'] != 'Ok') return null;
      final routes = json['routes'] as List<dynamic>;
      if (routes.isEmpty) return null;
      final route = routes.first as Map<String, dynamic>;
      final polyline = route['geometry'] as String;
      final distance = (route['distance'] as num).toDouble();
      return (encodedPolyline: polyline, distanceMeters: distance);
    } catch (_) {
      return null;
    }
  }
}
