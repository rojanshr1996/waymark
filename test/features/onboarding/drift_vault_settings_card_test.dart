import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/widgets/drift_vault_settings_card.dart';

void main() {
  testWidgets('DriftVaultSettingsCard toggles measurement standards with animated sliding tab', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String currentUnit = 'metric';

    Widget buildSubject() {
      return ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(textTheme: WaymarkTypography.getTextTheme()),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return DriftVaultSettingsCard(
                    unitSystem: currentUnit,
                    onUnitChanged: (unit) {
                      setState(() => currentUnit = unit);
                    },
                    autoExifGpsEnabled: true,
                    onAutoExifChanged: (_) {},
                  );
                },
              ),
            ),
          );
        },
      );
    }

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Verify initial metric alignment
    final animatedAlignFinder = find.byType(AnimatedAlign);
    expect(animatedAlignFinder, findsOneWidget);
    AnimatedAlign align = tester.widget(animatedAlignFinder);
    expect(align.alignment, Alignment.centerLeft);

    // Tap imperial tab
    final imperialTabFinder = find.text('Imperial (mi, ft, °F)');
    expect(imperialTabFinder, findsOneWidget);
    await tester.tap(imperialTabFinder);
    await tester.pumpAndSettle();

    expect(currentUnit, 'imperial');
    align = tester.widget(animatedAlignFinder);
    expect(align.alignment, Alignment.centerRight);

    // Tap metric tab
    final metricTabFinder = find.text('Metric (km, m, °C)');
    expect(metricTabFinder, findsOneWidget);
    await tester.tap(metricTabFinder);
    await tester.pumpAndSettle();

    expect(currentUnit, 'metric');
    align = tester.widget(animatedAlignFinder);
    expect(align.alignment, Alignment.centerLeft);
  });
}
