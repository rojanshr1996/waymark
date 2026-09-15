import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/main_common.dart';

void main() {
  AppFlavorConfig.initialize(
    flavor: Flavor.production,
    appTitle: 'Waymark',
    apiBaseUrl: 'https://api.waymark.app',
    enableLogging: false,
  );

  mainCommon(AppFlavorConfig.instance);
}
