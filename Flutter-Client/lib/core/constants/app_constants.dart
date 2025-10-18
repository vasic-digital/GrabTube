import 'package:flutter/foundation.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GrabTube';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Cutting-edge tube services downloader';

  // Build Configuration
  static const bool isDebugMode = kDebugMode;
  static const bool isReleaseMode = kReleaseMode;
  static const bool isProfileMode = kProfileMode;

  // Network
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // WebSocket
  static const Duration socketReconnectDelay = Duration(seconds: 5);
  static const int socketMaxReconnectAttempts = 10;

  // Storage
  static const String hiveBoxDownloads = 'downloads';
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxQueue = 'queue';

  // Shared Preferences Keys
  static const String prefKeyServerUrl = 'server_url';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyNotificationsEnabled = 'notifications_enabled';
  static const String prefKeyAutoStart = 'auto_start';
  static const String prefKeyDefaultQuality = 'default_quality';
  static const String prefKeyDefaultFormat = 'default_format';
  static const String prefKeyDownloadPath = 'download_path';

  // Default Values
  static const String defaultServerUrl = 'http://localhost:8081';
  static const String defaultQuality = 'best';
  static const String defaultFormat = 'any';
  static const bool defaultAutoStart = true;
  static const bool defaultNotificationsEnabled = true;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const int maxRecentSearches = 10;

  // Download
  static const int maxConcurrentDownloads = 3;
  static const Duration downloadStatusUpdateInterval = Duration(seconds: 1);

  // Quality Options
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

  // Format Options
  static const List<String> formatOptions = [
    'any',
    'mp4',
    'webm',
    'mkv',
    'flv',
    'avi',
    'mov',
    'm4a',
    'mp3',
    'opus',
    'wav',
  ];

  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorServerUnreachable = 'Cannot reach server';
  static const String errorInvalidUrl = 'Invalid URL';
  static const String errorDownloadFailed = 'Download failed';
  static const String errorUnknown = 'An unknown error occurred';

  // Success Messages
  static const String successDownloadAdded = 'Download added to queue';
  static const String successDownloadStarted = 'Download started';
  static const String successDownloadCompleted = 'Download completed';
  static const String successDownloadCanceled = 'Download canceled';
}
