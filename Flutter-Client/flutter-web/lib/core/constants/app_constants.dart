import 'package:flutter/foundation.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GrabTube';
  static const String appVersion = '1.0.0';

  // Network - connects to existing Python backend
  static const String defaultServerUrl = kDebugMode
      ? 'http://localhost:8081'  // Development
      : '';  // Production: same origin

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // WebSocket
  static const Duration socketReconnectDelay = Duration(seconds: 5);
  static const int socketMaxReconnectAttempts = 10;

  // Storage Keys
  static const String prefKeyServerUrl = 'server_url';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyDefaultQuality = 'default_quality';
  static const String prefKeyDefaultFormat = 'default_format';

  // Default Values
  static const String defaultQuality = 'best';
  static const String defaultFormat = 'any';

  // Quality Options (matching Python backend)
  static const List<String> qualityOptions = [
    'best',
    '2160',
    '1440',
    '1080',
    '720',
    '480',
    '360',
    'worst',
  ];

  // Format Options (matching Python backend)
  static const List<String> formatOptions = [
    'any',
    'mp4',
    'webm',
    'mkv',
    'mp3',
    'm4a',
    'opus',
  ];

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
