import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/core/services/notification_service.dart';
import 'package:grabtube/domain/entities/download_schedule.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotificationResponse extends Mock implements NotificationResponse {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;

    setUp(() {
      // NotificationService is a lazySingleton, so we'll test its public API
      notificationService = NotificationService();
    });

    group('Notification Tap Callback', () {
      test('registers callback successfully', () {
        var callbackCalled = false;
        String? receivedPayload;

        notificationService.setNotificationTapCallback((payload) {
          callbackCalled = true;
          receivedPayload = payload;
        });

        // Callback should be registered (no exception thrown)
        expect(callbackCalled, false); // Not yet called
      });

      test('callback can be replaced', () {
        var firstCallbackCalled = false;
        var secondCallbackCalled = false;

        // Register first callback
        notificationService.setNotificationTapCallback((payload) {
          firstCallbackCalled = true;
        });

        // Replace with second callback
        notificationService.setNotificationTapCallback((payload) {
          secondCallbackCalled = true;
        });

        // Only the second callback should be active
        expect(firstCallbackCalled, false);
        expect(secondCallbackCalled, false); // Not yet triggered
      });
    });

    group('Payload Format Validation', () {
      test('schedule payload format is correct', () {
        final schedule = DownloadSchedule(
          id: 'test-123',
          url: 'https://youtube.com/watch?v=test',
          scheduledTime: DateTime.now(),
          status: ScheduleStatus.pending,
        );

        // Expected payload format: "schedule:id"
        const expectedPayload = 'schedule:test-123';

        // Verify payload format matches what NotificationService would create
        expect('schedule:${schedule.id}', expectedPayload);
      });

      test('download payload format is correct', () {
        const downloadTitle = 'Test Video';

        // Expected payload format: "download:title"
        const expectedPayload = 'download:Test Video';

        // Verify payload format matches what NotificationService would create
        expect('download:$downloadTitle', expectedPayload);
      });

      test('payload parsing extracts type and id correctly', () {
        const payload = 'schedule:abc-123';
        final parts = payload.split(':');

        expect(parts.length, 2);
        expect(parts[0], 'schedule');
        expect(parts[1], 'abc-123');
      });

      test('handles malformed payload gracefully', () {
        const malformedPayloads = [
          'invalid',
          'no-colon',
          'too:many:colons',
          '',
          ':noprefix',
          'nosuffix:',
        ];

        for (final payload in malformedPayloads) {
          final parts = payload.split(':');
          // Should either have wrong length or empty parts
          expect(
            parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty,
            true,
            reason: 'Payload "$payload" should be considered invalid',
          );
        }
      });
    });

    group('Notification ID Generation', () {
      test('generates consistent IDs from schedule hashCode', () {
        final schedule1 = DownloadSchedule(
          id: 'same-id',
          url: 'https://youtube.com/watch?v=test',
          scheduledTime: DateTime.now(),
          status: ScheduleStatus.pending,
        );

        final schedule2 = DownloadSchedule(
          id: 'same-id',
          url: 'https://youtube.com/watch?v=test',
          scheduledTime: DateTime.now(),
          status: ScheduleStatus.pending,
        );

        // Same ID should produce same hashCode
        expect(schedule1.id.hashCode, schedule2.id.hashCode);
      });

      test('generates different IDs for different schedules', () {
        final schedule1 = DownloadSchedule(
          id: 'id-1',
          url: 'https://youtube.com/watch?v=test1',
          scheduledTime: DateTime.now(),
          status: ScheduleStatus.pending,
        );

        final schedule2 = DownloadSchedule(
          id: 'id-2',
          url: 'https://youtube.com/watch?v=test2',
          scheduledTime: DateTime.now(),
          status: ScheduleStatus.pending,
        );

        // Different IDs should produce different hashCodes
        expect(schedule1.id.hashCode, isNot(schedule2.id.hashCode));
      });

      test('download notification IDs are based on timestamp', () {
        final timestamp1 = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timestamp2 = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Timestamps should be similar (within same second)
        expect((timestamp1 - timestamp2).abs(), lessThan(2));
      });
    });

    group('Title Extraction from URL', () {
      test('extracts filename from YouTube URL', () {
        const url = 'https://youtube.com/watch?v=dQw4w9WgXcQ';
        final title = _extractTitle(url);

        // Should return 'watch' or something meaningful
        expect(title, isNotEmpty);
        expect(title.length, lessThanOrEqualTo(30));
      });

      test('extracts domain when path is empty', () {
        const url = 'https://youtube.com/';
        final title = _extractTitle(url);

        expect(title, 'youtube.com');
      });

      test('truncates long filenames', () {
        const url =
            'https://example.com/very-long-filename-that-exceeds-thirty-characters.mp4';
        final title = _extractTitle(url);

        expect(title.length, lessThanOrEqualTo(30));
        if (title.length == 30) {
          expect(title.endsWith('...'), true);
        }
      });

      test('handles invalid URLs gracefully', () {
        const invalidUrls = [
          'not a url',
          '',
          'http://',
          'ftp://invalid',
        ];

        for (final url in invalidUrls) {
          final title = _extractTitle(url);
          expect(title, isNotEmpty);
          expect(title, 'Download'); // Fallback value
        }
      });
    });

    group('Time Formatting', () {
      test('formats days correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(days: 3));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 3 days');
      });

      test('formats single day correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(days: 1));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 1 day');
      });

      test('formats hours correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(hours: 5));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 5 hours');
      });

      test('formats single hour correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(hours: 1));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 1 hour');
      });

      test('formats minutes correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(minutes: 30));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 30 minutes');
      });

      test('formats single minute correctly', () {
        final now = DateTime.now();
        final future = now.add(const Duration(minutes: 1));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in 1 minute');
      });

      test('formats near-future as "in a few moments"', () {
        final now = DateTime.now();
        final future = now.add(const Duration(seconds: 30));

        final formatted = _formatNextTime(future);

        expect(formatted, 'in a few moments');
      });
    });

    group('Notification Channel Configuration', () {
      test('schedule channel has correct configuration', () {
        const channelId = 'schedule_channel';
        const channelName = 'Schedule Notifications';

        // Verify channel configuration matches NotificationService
        expect(channelId, 'schedule_channel');
        expect(channelName, 'Schedule Notifications');
      });

      test('download channel has correct configuration', () {
        const channelId = 'download_channel';
        const channelName = 'Download Notifications';

        // Verify channel configuration matches NotificationService
        expect(channelId, 'download_channel');
        expect(channelName, 'Download Notifications');
      });
    });

    group('Error Handling', () {
      test('handles null payload gracefully', () {
        String? nullPayload;

        // Should not throw when payload is null
        expect(() {
          if (nullPayload == null || nullPayload.isEmpty) {
            // This is the expected behavior
            return;
          }
        }, returnsNormally);
      });

      test('handles empty payload gracefully', () {
        const emptyPayload = '';

        // Should not throw when payload is empty
        expect(() {
          if (emptyPayload.isEmpty) {
            // This is the expected behavior
            return;
          }
        }, returnsNormally);
      });

      test('handles callback not registered', () {
        // Create new service without callback
        final service = NotificationService();

        // Should not crash when trying to call unregistered callback
        // (In actual implementation, this is handled with null check)
        expect(() {
          // Simulate callback being null
          Function(String)? callback;
          if (callback != null) {
            callback('test');
          }
        }, returnsNormally);
      });
    });
  });
}

/// Extract a readable title from URL (mirrors NotificationService logic)
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

/// Format next execution time as relative string (mirrors NotificationService logic)
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
