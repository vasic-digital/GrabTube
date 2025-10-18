import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'core/di/injection.dart';
import 'core/utils/logger.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy (removes # from URLs)
  setPathUrlStrategy();

  // Initialize logger
  AppLogger.init();
  AppLogger.info('GrabTube Web starting...');

  try {
    // Initialize shared preferences
    await SharedPreferences.getInstance();
    AppLogger.info('SharedPreferences initialized');

    // Initialize dependency injection
    await configureDependencies();
    AppLogger.info('Dependencies configured');

    // Run the app
    runApp(const GrabTubeWebApp());
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    rethrow;
  }
}
