import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/services/remote_config_models.dart';

void main() {
  group('AppVersion', () {
    test('parses basic semantic versions correctly', () {
      final v1 = AppVersion.parse('1.0.0');
      expect(v1.major, 1);
      expect(v1.minor, 0);
      expect(v1.patch, 0);
      expect(v1.buildNumber, 0);

      final v2 = AppVersion.parse('2.4.15');
      expect(v2.major, 2);
      expect(v2.minor, 4);
      expect(v2.patch, 15);
    });

    test('parses versions with build numbers', () {
      final v = AppVersion.parse('1.2.3+45');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.buildNumber, 45);
      expect(v.toString(), '1.2.3+45');
    });

    test('handles short or malformed versions gracefully', () {
      final vShort = AppVersion.parse('2.1');
      expect(vShort.major, 2);
      expect(vShort.minor, 1);
      expect(vShort.patch, 0);

      final vSingle = AppVersion.parse('3');
      expect(vSingle.major, 3);
      expect(vSingle.minor, 0);
      expect(vSingle.patch, 0);

      final vEmpty = AppVersion.parse('');
      expect(vEmpty.major, 0);
      expect(vEmpty.minor, 0);
      expect(vEmpty.patch, 0);
    });

    test('compares semantic versions accurately', () {
      final v100 = AppVersion.parse('1.0.0');
      final v101 = AppVersion.parse('1.0.1');
      final v110 = AppVersion.parse('1.1.0');
      final v200 = AppVersion.parse('2.0.0');

      expect(v100.isLessThan(v101), isTrue);
      expect(v101.isLessThan(v110), isTrue);
      expect(v110.isLessThan(v200), isTrue);

      expect(v200.isGreaterThan(v110), isTrue);
      expect(v110.isGreaterThan(v101), isTrue);
      expect(v101.isGreaterThan(v100), isTrue);

      expect(v100.isAtLeast(AppVersion.parse('1.0.0')), isTrue);
      expect(v101.isAtLeast(v100), isTrue);
      expect(v100.isAtLeast(v101), isFalse);
    });

    test('compares build numbers when semantic versions match', () {
      final v1 = AppVersion.parse('1.0.0+1');
      final v2 = AppVersion.parse('1.0.0+2');

      expect(v1.isLessThan(v2), isTrue);
      expect(v2.isGreaterThan(v1), isTrue);
    });

    test('equality and hashCode works', () {
      final a = AppVersion.parse('1.2.3+4');
      final b = AppVersion.parse('1.2.3+4');
      final c = AppVersion.parse('1.2.3+5');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('AppGateEvaluation', () {
    test('helpers report gate status accurately', () {
      const normal = AppGateEvaluation(
        status: AppGateStatus.normal,
        currentVersion: '1.0.0',
        minRequiredVersion: '1.0.0',
        latestRecommendedVersion: '1.0.0',
        title: '',
        message: '',
        releaseNotes: [],
        storeUrl: '',
        allowSkip: true,
      );
      expect(normal.isNormal, isTrue);
      expect(normal.isMaintenance, isFalse);
      expect(normal.isForceUpdate, isFalse);
      expect(normal.isRecommendedUpdate, isFalse);

      final maintenance = normal.copyWith(
        status: AppGateStatus.maintenance,
        isMaintenanceMode: true,
      );
      expect(maintenance.isMaintenance, isTrue);
      expect(maintenance.isNormal, isFalse);

      final force = normal.copyWith(status: AppGateStatus.forceUpdate);
      expect(force.isForceUpdate, isTrue);
      expect(force.isUpdateRequiredOrRecommended, isTrue);

      final recommended = normal.copyWith(
        status: AppGateStatus.recommendedUpdate,
      );
      expect(recommended.isRecommendedUpdate, isTrue);
      expect(recommended.isUpdateRequiredOrRecommended, isTrue);
    });
  });
}
