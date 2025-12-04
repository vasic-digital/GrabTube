import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/download_schedule.dart';

/// Service for managing local notifications
@lazySingleton
class NotificationService {
  NotificationService() {
    _initialize();
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Function(String)? _onNotificationTapCallback;

  /// Initialize the notification service
  Future<void> _initialize() async {
    try {
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('⚠️  Failed to initialize notifications: $e');
    }
  }

  /// Set notification tap callback
  void setNotificationTapCallback(Function(String) callback) {
    _onNotificationTapCallback = callback;
    print('✅ Notification tap callback registered');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      print('⚠️  Notification tapped with no payload');
      return;
    }

    print('🔔 Notification tapped: $payload');

    // Call the registered callback
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(payload);
    } else {
      print('⚠️  No notification tap callback registered');
    }
  }

  /// Request notification permissions (iOS/macOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? true;
    } catch (e) {
      print('⚠️  Failed to request permissions: $e');
      return false;
    }
  }

  /// Show notification for schedule execution
  Future<void> showScheduleExecutedNotification(DownloadSchedule schedule) async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'schedule_channel',
        'Schedule Notifications',
        channelDescription: 'Notifications for scheduled download execution',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      // Extract title from URL (remove protocol and query params)
      final title = _extractTitle(schedule.url);

      await _notifications.show(
        schedule.id.hashCode,
        'Scheduled Download Started',
        title,
        notificationDetails,
        payload: 'schedule:${schedule.id}',
      );

      print('✅ Notification shown for schedule: ${schedule.id}');
    } catch (e) {
      print('⚠️  Failed to show notification: $e');
    }
  }

  /// Show notification for schedule failure
  Future<void> showScheduleFailedNotification(
    DownloadSchedule schedule,
    String error,
  ) async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'schedule_channel',
        'Schedule Notifications',
        channelDescription: 'Notifications for scheduled download execution',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        color: Color(0xFFE74C3C), // GrabTube red
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      final title = _extractTitle(schedule.url);

      await _notifications.show(
        schedule.id.hashCode,
        'Scheduled Download Failed',
        '$title - $error',
        notificationDetails,
        payload: 'schedule:${schedule.id}',
      );

      print('✅ Failure notification shown for schedule: ${schedule.id}');
    } catch (e) {
      print('⚠️  Failed to show failure notification: $e');
    }
  }

  /// Show notification for download completion
  Future<void> showDownloadCompletedNotification(
    String title,
    String? filename,
  ) async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'download_channel',
        'Download Notifications',
        channelDescription: 'Notifications for download completion',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Download Complete',
        filename ?? title,
        notificationDetails,
        payload: 'download:$title',
      );

      print('✅ Download completion notification shown');
    } catch (e) {
      print('⚠️  Failed to show download notification: $e');
    }
  }

  /// Show notification for download failure
  Future<void> showDownloadFailedNotification(
    String title,
    String error,
  ) async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        'download_channel',
        'Download Notifications',
        channelDescription: 'Notifications for download events',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        color: Color(0xFFE74C3C), // GrabTube red
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Download Failed',
        '$title - $error',
        notificationDetails,
        payload: 'download:$title',
      );

      print('✅ Download failure notification shown');
    } catch (e) {
      print('⚠️  Failed to show failure notification: $e');
    }
  }

  /// Show notification for recurring schedule created
  Future<void> showRecurringScheduleNotification(
    DownloadSchedule schedule,
    DateTime nextExecution,
  ) async {
    if (!_initialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'schedule_channel',
        'Schedule Notifications',
        channelDescription: 'Notifications for scheduled download execution',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      final title = _extractTitle(schedule.url);
      final nextTime = _formatNextTime(nextExecution);

      await _notifications.show(
        schedule.id.hashCode + 1,
        'Recurring Schedule Created',
        '$title scheduled for $nextTime',
        notificationDetails,
        payload: 'schedule:${schedule.id}',
      );

      print('✅ Recurring schedule notification shown');
    } catch (e) {
      print('⚠️  Failed to show recurring notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('✅ Notification cancelled: $id');
    } catch (e) {
      print('⚠️  Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('⚠️  Failed to cancel all notifications: $e');
    }
  }

  /// Extract a readable title from URL
  String _extractTitle(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;

      // Get the last part of the path or domain
      if (path.isNotEmpty && path != '/') {
        final segments = path.split('/');
        final lastSegment = segments.last;
        if (lastSegment.isNotEmpty) {
          return lastSegment.length > 30
              ? '${lastSegment.substring(0, 27)}...'
              : lastSegment;
        }
      }

      // Fallback to domain
      final domain = uri.host;
      return domain.isNotEmpty ? domain : 'Download';
    } catch (e) {
      return 'Download';
    }
  }

  /// Format next execution time as relative string
  String _formatNextTime(DateTime nextTime) {
    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? "s" : ""}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""}';
    } else {
      return 'in a few moments';
    }
  }

  @disposeMethod
  void dispose() {
    // Cancel all notifications on disposal
    cancelAllNotifications();
  }
}
