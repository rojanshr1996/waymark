import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/services/remote_config_models.dart';
import 'package:waymark/core/services/remote_config_service.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/app_update/presentation/screens/app_update_screen.dart';

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
          home: AppUpdateScreen(initialEvaluation: evaluation),
        );
      },
    );
  }

  testWidgets(
    'AppUpdateScreen displays Force Update with Wanderline branding, high contrast texts, pinned visible buttons, and no release notes',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const forceEvaluation = AppGateEvaluation(
        status: AppGateStatus.forceUpdate,
        currentVersion: '1.0.0+1',
        minRequiredVersion: '1.2.0',
        latestRecommendedVersion: '1.2.0',
        title: 'Mandatory Overhaul Required',
        message: 'Your field journals require updated database schemas to remain intact.',
        releaseNotes: [
          'Critical cloud schema migration',
          'Offline journal recovery protection',
        ],
        storeUrl: 'https://play.google.com/store/apps/details?id=com.wanderline.app',
        allowSkip: false,
      );

      await tester.pumpWidget(buildSubject(evaluation: forceEvaluation));
      await tester.pumpAndSettle();

      // Verify Wanderline brand header
      expect(find.text('Wanderline'), findsOneWidget);
      expect(find.text('Expedition Journal & Field Memoir'), findsOneWidget);

      // Verify custom title & message from Remote Config
      expect(find.text('Mandatory Overhaul Required'), findsOneWidget);
      expect(
        find.text(
          'Your field journals require updated database schemas to remain intact.',
        ),
        findsOneWidget,
      );

      // Verify status pill
      expect(find.text('MANDATORY UPDATE'), findsOneWidget);

      // Verify versions
      expect(find.text('v1.0.0+1'), findsOneWidget);
      expect(find.text('v1.2.0'), findsOneWidget);

      // Verify release notes section is NOT shown
      expect(find.text("WHAT'S NEW IN THIS VERSION"), findsNothing);
      expect(find.text('Critical cloud schema migration'), findsNothing);
      expect(
        find.text('Offline journal recovery protection'),
        findsNothing,
      );

      // Verify BOTH buttons at the bottom are visible
      expect(find.text('Update Now to Continue'), findsOneWidget);
      expect(find.text('Already Updated? Verify Status'), findsOneWidget);

      // CRITICAL: Force update MUST NOT have skip button
      expect(find.textContaining('Maybe Later'), findsNothing);
    },
  );

  testWidgets(
    'AppUpdateScreen displays Recommended Update with Wanderline branding, both bottom buttons visible, and no release notes',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const recommendedEvaluation = AppGateEvaluation(
        status: AppGateStatus.recommendedUpdate,
        currentVersion: '1.1.0',
        minRequiredVersion: '1.0.0',
        latestRecommendedVersion: '1.2.0',
        title: 'New Trails Unlocked',
        message: 'Discover our newest expedition postcards and offline sync features.',
        releaseNotes: ['New postcard layouts', 'Faster map rendering'],
        storeUrl: 'https://play.google.com/store/apps/details?id=com.wanderline.app',
        allowSkip: true,
      );

      await tester.pumpWidget(buildSubject(evaluation: recommendedEvaluation));
      await tester.pumpAndSettle();

      // Verify Wanderline brand header
      expect(find.text('Wanderline'), findsOneWidget);

      // Verify custom title & message
      expect(find.text('New Trails Unlocked'), findsOneWidget);
      expect(
        find.text(
          'Discover our newest expedition postcards and offline sync features.',
        ),
        findsOneWidget,
      );

      // Verify status pill
      expect(find.text('RECOMMENDED UPGRADE'), findsOneWidget);

      // Verify release notes section is NOT shown
      expect(find.text("WHAT'S NEW IN THIS VERSION"), findsNothing);
      expect(find.text('New postcard layouts'), findsNothing);

      // Verify BOTH action buttons at the bottom are visible
      expect(find.text('Update Wanderline'), findsOneWidget);
      expect(
        find.text('Maybe Later — Continue to Field Journal'),
        findsOneWidget,
      );
    },
  );
}
