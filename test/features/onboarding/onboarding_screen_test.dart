import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/core/l10n/app_localizations.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass.dart';
import 'package:waymark/core/presentation/widgets/waymark_liquid_glass_app_bar.dart';
import 'package:waymark/core/theme/waymark_typography.dart';
import 'package:waymark/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders Step 1 and navigates to Step 2 with liquid glass app bar and bottom bar', (
    WidgetTester tester,
  ) async {
    // Set screen size for mobile responsiveness
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(textTheme: WaymarkTypography.getTextTheme()),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const OnboardingScreen(),
          );
        },
      ),
    );

    await tester.pump();

    // Verify Step 1: Welcome & Philosophy elements exist
    expect(find.byType(WaymarkLiquidGlassAppBar), findsOneWidget);
    expect(find.byType(WaymarkLiquidGlass), findsAtLeastNWidgets(2));
    expect(find.text('WAYMARK ARCHIVE'), findsOneWidget);
    expect(find.text('PLATE NO. 12'), findsOneWidget);
    expect(find.text('Interactive Route Maps'), findsOneWidget);
    expect(find.text('Artistic Postcards'), findsOneWidget);
    expect(find.text('Private Local Vault'), findsOneWidget);
    expect(find.text('Begin Expedition Setup'), findsOneWidget);

    // Tap sticky "Begin Expedition Setup" button (always visible at bottom) to proceed to Step 2
    final buttonFinder = find.text('Begin Expedition Setup');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify Step 2: Profile & Vault Creation elements exist
    expect(find.byType(WaymarkLiquidGlassAppBar), findsOneWidget);
    expect(find.byType(WaymarkLiquidGlass), findsAtLeastNWidgets(2));
    expect(find.text('Claim Your Compass'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Compass ID / Email'), findsOneWidget);
    expect(find.text('Traveler Type'), findsOneWidget);
    expect(find.text('Initialize Local Vault'), findsOneWidget);

    // Verify generic hint and email placeholders
    expect(find.text('e.g. Rojan Shrestha'), findsOneWidget);
    expect(find.text('e.g. rojan@waymark.app'), findsOneWidget);

    // Enter text and verify tick mark and claimed badge appear
    await tester.enterText(find.byType(TextField).first, 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.pump();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text('CLAIMED'), findsOneWidget);
  });
}
