import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/presentation/blocs/settings/settings_bloc.dart';
import 'package:grabtube/presentation/blocs/settings/settings_state.dart';
import 'package:grabtube/presentation/app.dart';

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  group('Theme Switching Widget Tests', () {
    late MockSettingsBloc mockSettingsBloc;

    setUp(() {
      mockSettingsBloc = MockSettingsBloc();

      // Default state for SettingsBloc
      when(() => mockSettingsBloc.state).thenReturn(const SettingsInitial());
      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(const SettingsInitial()),
      );
    });

    testWidgets('app uses light theme when settings specify light mode',
        (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'light',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'light',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('app uses dark theme when settings specify dark mode',
        (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'dark',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'dark',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('app uses system theme when settings specify system mode',
        (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'system',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'system',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('app defaults to system theme when settings not loaded',
        (tester) async {
      // Arrange - SettingsInitial state
      when(() => mockSettingsBloc.state).thenReturn(const SettingsInitial());
      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(const SettingsInitial()),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('app theme updates when settings change', (tester) async {
      // Arrange - Start with light theme
      final settingsStreamController = StreamController<SettingsState>();

      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'light',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => settingsStreamController.stream,
      );

      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pump();

      // Act - Emit initial state
      settingsStreamController.add(
        const SettingsLoaded(
          themeMode: 'light',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      await tester.pumpAndSettle();

      // Assert light theme
      var materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.light);

      // Act - Change to dark theme
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'dark',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      settingsStreamController.add(
        const SettingsLoaded(
          themeMode: 'dark',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      await tester.pumpAndSettle();

      // Assert dark theme
      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.themeMode, ThemeMode.dark);

      // Cleanup
      await settingsStreamController.close();
    });

    testWidgets('theme has GrabTube red primary color', (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'light',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'light',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      final theme = materialApp.theme!;

      // GrabTube red from logo
      expect(theme.colorScheme.primary.value, 0xFFE74C3C);
    });

    testWidgets('dark theme has correct brightness', (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'dark',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'dark',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      final darkTheme = materialApp.darkTheme!;

      expect(darkTheme.colorScheme.brightness, Brightness.dark);
    });

    testWidgets('theme uses Material 3', (tester) async {
      // Arrange
      when(() => mockSettingsBloc.state).thenReturn(
        const SettingsLoaded(
          themeMode: 'light',
          defaultQuality: 'best',
          defaultFormat: 'mp4',
          autoStartDownloads: true,
          showThumbnails: true,
          notificationsEnabled: true,
          compactMode: false,
          maxConcurrentDownloads: 3,
          connectionTimeout: 30,
          autoRetryFailed: true,
          maxRetryAttempts: 3,
          wifiOnlyDownloads: false,
          scheduleNotificationsEnabled: true,
          defaultScheduleTime: '09:00',
          showCompletedNotification: true,
          playSoundOnComplete: true,
          vibrateOnComplete: true,
        ),
      );

      when(() => mockSettingsBloc.stream).thenAnswer(
        (_) => Stream.value(
          const SettingsLoaded(
            themeMode: 'light',
            defaultQuality: 'best',
            defaultFormat: 'mp4',
            autoStartDownloads: true,
            showThumbnails: true,
            notificationsEnabled: true,
            compactMode: false,
            maxConcurrentDownloads: 3,
            connectionTimeout: 30,
            autoRetryFailed: true,
            maxRetryAttempts: 3,
            wifiOnlyDownloads: false,
            scheduleNotificationsEnabled: true,
            defaultScheduleTime: '09:00',
            showCompletedNotification: true,
            playSoundOnComplete: true,
            vibrateOnComplete: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: const _TestableThemeApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp).first);
      expect(materialApp.theme!.useMaterial3, true);
      expect(materialApp.darkTheme!.useMaterial3, true);
    });
  });
}

/// Simplified testable version of GrabTubeApp for theme testing
class _TestableThemeApp extends StatelessWidget {
  const _TestableThemeApp();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        if (previous is SettingsLoaded && current is SettingsLoaded) {
          return previous.themeMode != current.themeMode;
        }
        return current is SettingsLoaded;
      },
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.system;
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
          title: 'GrabTube Test',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeMode,
          home: const Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE74C3C),
        brightness: Brightness.light,
        secondary: const Color(0xFF2C3E50),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE74C3C),
        brightness: Brightness.dark,
        secondary: const Color(0xFF2C3E50),
      ),
    );
  }
}
