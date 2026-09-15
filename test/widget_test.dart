import 'package:flutter_test/flutter_test.dart';
import 'package:waymark/app.dart';
import 'package:waymark/core/config/flavor_config.dart';

void main() {
  testWidgets('WaymarkApp renders with flavor configuration', (
    WidgetTester tester,
  ) async {
    AppFlavorConfig.initialize(
      flavor: Flavor.dev,
      appTitle: 'Waymark Dev',
      apiBaseUrl: 'https://dev-api.waymark.app',
      enableLogging: false,
    );

    await tester.pumpWidget(const WaymarkApp());
    await tester.pumpAndSettle();

    expect(find.text('Waymark Dev'), findsWidgets);
    expect(find.text('Environment: Development'), findsOneWidget);
  });
}
