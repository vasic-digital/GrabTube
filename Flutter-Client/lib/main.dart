import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'core/services/schedule_service.dart';
import 'presentation/app.dart';

/// Background task callback for download notifications and background processing
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.info('Background task executing: $task');
    // Handle background download updates, notifications, etc.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.init();
  AppLogger.info('GrabTube application starting...');

  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    AppLogger.info('Hive initialized');

    // Initialize dependency injection
    await configureDependencies();
    AppLogger.info('Dependencies configured');

    // Start schedule service for background schedule checking
    final scheduleService = getIt<ScheduleService>();
    scheduleService.start();
    AppLogger.info('Schedule service started');

    // Initialize background task manager (mobile only)
    if (!kIsWeb) {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: AppConstants.isDebugMode,
      );
      AppLogger.info('WorkManager initialized');

      // Register periodic sync task
      await Workmanager().registerPeriodicTask(
        'download-status-sync',
        'syncDownloadStatus',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } else {
      AppLogger.info('WorkManager skipped (web platform)');
    }

    // Run the app
    runApp(const GrabTubeApp());
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    rethrow;
  }
}
