import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/services/location_search_service.dart';

void main() {
  group('LocationSearchService Tests', () {
    late LocationSearchService service;

    setUp(() {
      service = LocationSearchService();
    });

    test('empty search query returns empty list', () async {
      final results = await service.search('');
      expect(results, isEmpty);

      final whitespaceResults = await service.search('   ');
      expect(whitespaceResults, isEmpty);
    });

    test('search returns results for Kyoto query', () async {
      final results = await service.search('kiyomizu');
      expect(results, isNotEmpty);
      final first = results.first;
      expect(first.name, isNotEmpty);
      expect(first.latitude, isNotNull);
      expect(first.longitude, isNotNull);
      expect(first.latitude, inInclusiveRange(-90.0, 90.0));
      expect(first.longitude, inInclusiveRange(-180.0, 180.0));
    });

    test('search returns results for global spots (e.g. Eiffel, Everest)', () async {
      final eiffelResults = await service.search('eiffel');
      expect(eiffelResults, isNotEmpty);
      expect(eiffelResults.first.name, isNotEmpty);

      final everestResults = await service.search('everest');
      expect(everestResults, isNotEmpty);
      expect(everestResults.first.name, isNotEmpty);
    });

    test('reverse geocode handles coordinates gracefully', () async {
      final res = await service.reverseGeocode(34.9949, 135.7850);
      if (res != null) {
        expect(res.latitude, equals(34.9949));
        expect(res.longitude, equals(135.7850));
      }
    });
  });
}
