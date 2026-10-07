enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment fromFlavor(String? flavor) => switch (flavor) {
    null || 'dev' => AppEnvironment.dev,
    'prod' => AppEnvironment.prod,
    _ => throw ArgumentError.value(flavor, 'flavor', 'Use dev ou prod'),
  };

  String get appName => switch (this) {
    AppEnvironment.dev => 'AeroGaze AI Dev',
    AppEnvironment.prod => 'AeroGaze AI',
  };
}
