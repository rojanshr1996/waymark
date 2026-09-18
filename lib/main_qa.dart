import 'package:waymark/core/config/flavor_config.dart';
import 'package:waymark/main_common.dart';

void main() {
  AppFlavorConfig.initialize(
    flavor: Flavor.qa,
    appTitle: 'Waymark QA',
    enableLogging: true,
  );

  mainCommon(AppFlavorConfig.instance);
}
