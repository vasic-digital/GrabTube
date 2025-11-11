import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/constants/app_constants.dart';
import '../core/services/schedule_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/settings_service.dart';
import '../domain/entities/download.dart';
import '../domain/entities/download_schedule.dart';
import 'blocs/download/download_bloc.dart';
import 'blocs/download/download_event.dart';
import 'blocs/download/download_state.dart';
import 'blocs/jdownloader/jdownloader_bloc.dart';
import 'blocs/qr_scanner/qr_scanner_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/favorites/favorites_bloc.dart';
import 'blocs/schedule/schedule_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_event.dart';
import 'blocs/settings/settings_state.dart';
import 'pages/home_page.dart';

class GrabTubeApp extends StatelessWidget {
  const GrabTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DownloadBloc>(
          create: (_) => getIt<DownloadBloc>(),
        ),
        BlocProvider<JDownloaderBloc>(
          create: (_) => getIt<JDownloaderBloc>(),
        ),
        BlocProvider<QRScannerBloc>(
          create: (_) => getIt<QRScannerBloc>(),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => getIt<SearchBloc>(),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => getIt<FavoritesBloc>(),
        ),
        BlocProvider<ScheduleBloc>(
          create: (_) => getIt<ScheduleBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(const LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          // Rebuild when settings are loaded or theme mode changes
          if (previous is SettingsLoaded && current is SettingsLoaded) {
            return previous.themeMode != current.themeMode;
          }
          return current is SettingsLoaded;
        },
        builder: (context, state) {
          // Determine theme mode from settings
          ThemeMode themeMode = ThemeMode.system; // default
          if (state is SettingsLoaded) {
            switch (state.themeMode) {
              case 'light':
                themeMode = ThemeMode.light;
                break;
              case 'dark':
                themeMode = ThemeMode.dark;
                break;
              case 'system':
              default:
                themeMode = ThemeMode.system;
                break;
            }
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeMode,
            home: const _AppHomeWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE74C3C), // GrabTube red from logo
        brightness: Brightness.light,
        secondary: const Color(0xFF2C3E50), // Dark charcoal from logo
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE74C3C), // GrabTube red from logo
        brightness: Brightness.dark,
        secondary: const Color(0xFF2C3E50), // Dark charcoal from logo
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Wrapper widget that sets up Schedule-Download integration
/// This ensures the integration is established after BLoCs are available
class _AppHomeWrapper extends StatefulWidget {
  const _AppHomeWrapper();

  @override
  State<_AppHomeWrapper> createState() => _AppHomeWrapperState();
}

class _AppHomeWrapperState extends State<_AppHomeWrapper> {
  // Track download statuses to detect completion/failure
  final Map<String, DownloadStatus> _previousDownloadStatuses = {};

  @override
  void initState() {
    super.initState();
    // Set up Schedule-Download integration after the frame is rendered
    // This ensures the BLoC is available in the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScheduleDownloadIntegration();
    });
  }

  void _setupScheduleDownloadIntegration() {
    try {
      final scheduleService = getIt<ScheduleService>();
      final downloadBloc = context.read<DownloadBloc>();
      final notificationService = getIt<NotificationService>();
      final settingsService = getIt<SettingsService>();

      // Register download trigger callback
      scheduleService.setDownloadTrigger((DownloadSchedule schedule) {
        // Add download to queue via BLoC
        downloadBloc.add(AddDownload(
          url: schedule.url,
          quality: schedule.quality ?? 'best',
          format: schedule.format,
          autoStart: true,
        ));

        // Show notification if enabled in settings
        if (settingsService.scheduleNotificationsEnabled) {
          notificationService.showScheduleExecutedNotification(schedule);
        }

        print('✅ Schedule triggered download: ${schedule.url}');
        print('   Quality: ${schedule.quality ?? "best"}, Format: ${schedule.format ?? "mp4"}');
      });

      print('✅ Schedule-Download integration established with notifications');
    } catch (e) {
      print('⚠️  Failed to set up Schedule-Download integration: $e');
    }
  }

  void _handleDownloadStateChange(
    BuildContext context,
    DownloadState state,
  ) {
    if (state is! DownloadsLoaded) return;

    final notificationService = getIt<NotificationService>();
    final settingsService = getIt<SettingsService>();

    // Check if notifications are enabled
    if (!settingsService.notificationsEnabled) return;

    // Check all downloads for status changes
    final allDownloads = [...state.queue, ...state.completed, ...state.pending];

    for (final download in allDownloads) {
      final previousStatus = _previousDownloadStatuses[download.id];
      final currentStatus = download.status;

      // Skip if status hasn't changed
      if (previousStatus == currentStatus) continue;

      // Update tracked status
      _previousDownloadStatuses[download.id] = currentStatus;

      // Skip if previous status was null (first time seeing this download)
      if (previousStatus == null) continue;

      // Show notification for completed downloads
      if (currentStatus == DownloadStatus.completed &&
          previousStatus != DownloadStatus.completed) {
        notificationService.showDownloadCompletedNotification(
          download.title,
          null, // filename not available in current model
        );
        print('✅ Download completed notification shown: ${download.title}');
      }

      // Show notification for failed downloads
      if (currentStatus == DownloadStatus.error &&
          previousStatus != DownloadStatus.error) {
        notificationService.showDownloadFailedNotification(
          download.title,
          download.error ?? 'Unknown error',
        );
        print('⚠️  Download failed notification shown: ${download.title}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadBloc, DownloadState>(
      listener: _handleDownloadStateChange,
      child: const HomePage(),
    );
  }
}
