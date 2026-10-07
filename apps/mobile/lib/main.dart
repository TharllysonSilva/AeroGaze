import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/aerogaze_app.dart';
import 'app/app_environment.dart';
import 'app/startup_diagnostics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  StartupDiagnostics.attach();
  runApp(AeroGazeApp(environment: AppEnvironment.fromFlavor(appFlavor)));
}
