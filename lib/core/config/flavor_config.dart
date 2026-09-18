enum Flavor {
  dev,
  qa,
  uat,
  production;

  bool get isDev => this == Flavor.dev;
  bool get isQa => this == Flavor.qa;
  bool get isUat => this == Flavor.uat;
  bool get isProduction => this == Flavor.production;

  String get displayName => switch (this) {
    Flavor.dev => 'Development',
    Flavor.qa => 'QA Testing',
    Flavor.uat => 'User Acceptance Testing',
    Flavor.production => 'Production',
  };
}

class AppFlavorConfig {
  final Flavor flavor;
  final String appTitle;
  final bool enableLogging;
  final Map<String, dynamic> extraConfig;

  static AppFlavorConfig? _instance;

  AppFlavorConfig._({
    required this.flavor,
    required this.appTitle,
    required this.enableLogging,
    required this.extraConfig,
  });

  static AppFlavorConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppFlavorConfig has not been initialized. Call initialize() before accessing instance.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  static void initialize({
    required Flavor flavor,
    required String appTitle,
    bool enableLogging = false,
    Map<String, dynamic> extraConfig = const {},
  }) {
    _instance = AppFlavorConfig._(
      flavor: flavor,
      appTitle: appTitle,
      enableLogging: enableLogging,
      extraConfig: extraConfig,
    );
  }
}
