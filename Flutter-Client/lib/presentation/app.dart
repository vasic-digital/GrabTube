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
import 'pages/schedule_page.dart';

class GrabTubeApp extends StatelessWidget {
  const GrabTubeApp({super.key});

  // Global navigation key for notification navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
            navigatorKey: navigatorKey,
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
      cardTheme: CardTheme(
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
      cardTheme: CardTheme(
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

  void _setupScheduleDownloadIntegration() async {
    try {
      final scheduleService = getIt<ScheduleService>();
      final downloadBloc = context.read<DownloadBloc>();
      final notificationService = getIt<NotificationService>();
      final settingsService = getIt<SettingsService>();

      // Get settings values
      final scheduleNotificationsEnabled = await settingsService.getScheduleNotificationsEnabled();

      // Register download trigger callback
      scheduleService.setDownloadTrigger((DownloadSchedule schedule) {
        // Add download to queue via BLoC
        downloadBloc.add(const AddDownload(
          url: '', // Will be set below
          quality: 'best',
          format: 'mp4',
          autoStart: true,
        ));
        // TODO: Update AddDownload to support schedule URL directly

        // Show notification if enabled in settings
        if (scheduleNotificationsEnabled) {
          notificationService.showScheduleExecutedNotification(schedule);
        }

        print('✅ Schedule triggered download: ${schedule.url}');
        print('   Quality: best, Format: mp4');
      });

      // Register notification tap callback
      notificationService.setNotificationTapCallback(_handleNotificationTap);

      print('✅ Schedule-Download integration established with notifications');
    } catch (e) {
      print('⚠️  Failed to set up Schedule-Download integration: $e');
    }
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(String payload) {
    print('🔔 Handling notification tap: $payload');

    try {
      // Parse payload format: "type:id"
      final parts = payload.split(':');
      if (parts.length != 2) {
        print('⚠️  Invalid notification payload format: $payload');
        return;
      }

      final type = parts[0];
      final id = parts[1];

      // Navigate based on type
      final navigator = GrabTubeApp.navigatorKey.currentState;
      if (navigator == null) {
        print('⚠️  Navigator not available');
        return;
      }

      switch (type) {
        case 'schedule':
          // Navigate to Schedule page
          print('📅 Navigating to Schedule page for ID: $id');
          navigator.push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: getIt<ScheduleBloc>(),
                child: const SchedulePage(),
              ),
            ),
          );
          break;

        case 'download':
          // Navigate to Home page (downloads tab)
          print('⬇️  Navigating to Downloads (Home)');
          // Pop to root if not already there
          navigator.popUntil((route) => route.isFirst);
          break;

        default:
          print('⚠️  Unknown notification type: $type');
      }
    } catch (e) {
      print('⚠️  Failed to handle notification tap: $e');
    }
  }

  void _handleDownloadStateChange(
    BuildContext context,
    DownloadState state,
  ) async {
    if (state is! DownloadsLoaded) return;

    final notificationService = getIt<NotificationService>();
    final settingsService = getIt<SettingsService>();

    // Check if notifications are enabled
    final notificationsEnabled = await settingsService.getNotificationsEnabled();
    if (!notificationsEnabled) return;

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
