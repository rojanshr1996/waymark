import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/services/remote_config_models.dart';
import 'package:waymark/core/services/remote_config_service.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/app_maintenance/presentation/screens/app_maintenance_screen.dart';

void main() {
  Widget buildSubject({required AppGateEvaluation evaluation}) {
    RemoteConfigService.instance.gateNotifier.value = evaluation;

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            textTheme: WaymarkTypography.getTextTheme(),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppMaintenanceScreen(),
        );
      },
    );
  }

  testWidgets(
    'AppMaintenanceScreen displays remote config maintenance info, timeline, and controls',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const maintenanceEval = AppGateEvaluation(
        status: AppGateStatus.maintenance,
        currentVersion: '1.0.0+1',
        minRequiredVersion: '1.0.0',
        latestRecommendedVersion: '1.0.0',
        title: 'Expedition Trail Calibration',
        message: 'We are performing routine trail tune-ups to keep your field journals safe.',
        releaseNotes: [],
        storeUrl: '',
        allowSkip: false,
        isMaintenanceMode: true,
        maintenanceStartTime: '10:00 UTC',
        maintenanceEndTime: '12:00 UTC',
        supportEmail: 'crew@waymark.app',
        statusUrl: 'https://status.waymark.app',
        canBypass: true,
      );

      await tester.pumpWidget(buildSubject(evaluation: maintenanceEval));
      await tester.pumpAndSettle();

      // Verify title & message from Remote Config
      expect(find.text('Expedition Trail Calibration'), findsOneWidget);
      expect(
        find.text(
          'We are performing routine trail tune-ups to keep your field journals safe.',
        ),
        findsOneWidget,
      );

      // Verify status pill
      expect(find.text('SCHEDULED MAINTENANCE'), findsOneWidget);

      // Verify schedule window
      expect(find.text('Started: 10:00 UTC'), findsOneWidget);
      expect(find.text('Expected Completion: 12:00 UTC'), findsOneWidget);

      // Verify controls
      expect(find.text('Check Maintenance Status'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.text('Status Page'), findsOneWidget);

      // Verify Developer Bypass trigger opens dialog
      final bypassButton = find.byTooltip('Developer Bypass');
      expect(bypassButton, findsOneWidget);
      await tester.tap(bypassButton);
      await tester.pumpAndSettle();

      expect(find.text('Developer Bypass'), findsOneWidget);
      expect(find.text('Bypass Passphrase'), findsOneWidget);
    },
  );
}
