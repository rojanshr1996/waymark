import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/main_common.dart';

void main() {
  AppFlavorConfig.initialize(
    flavor: Flavor.dev,
    appTitle: 'Waymark Dev',
    apiBaseUrl: 'https://dev-api.waymark.app',
    enableLogging: true,
  );

  mainCommon(AppFlavorConfig.instance);
}
