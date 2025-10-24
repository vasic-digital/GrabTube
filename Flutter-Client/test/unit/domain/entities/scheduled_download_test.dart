import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/scheduled_download.dart';

void main() {
  group('ScheduledDownload Model Tests', () {
    final testScheduledAt = DateTime(2024, 1, 15, 10, 30);
    final testExecutedAt = DateTime(2024, 1, 15, 10, 35);

    test('should create ScheduledDownload with required fields', () {
      final scheduledDownload = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
      );

      expect(scheduledDownload.id, 'test-id');
      expect(scheduledDownload.scheduleId, 'schedule-123');
      expect(scheduledDownload.downloadId, 'download-456');
      expect(scheduledDownload.scheduledAt, testScheduledAt);
      expect(scheduledDownload.executedAt, isNull);
      expect(scheduledDownload.isExecuted, false);
      expect(scheduledDownload.isSuccessful, false);
      expect(scheduledDownload.errorMessage, isNull);
      expect(scheduledDownload.result, isNull);
    });

    test('should create ScheduledDownload with all fields', () {
      final result = {'fileSize': 1048576, 'duration': 3600};
      final scheduledDownload = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        executedAt: testExecutedAt,
        isExecuted: true,
        isSuccessful: true,
        errorMessage: null,
        result: result,
      );

      expect(scheduledDownload.executedAt, testExecutedAt);
      expect(scheduledDownload.isExecuted, true);
      expect(scheduledDownload.isSuccessful, true);
      expect(scheduledDownload.errorMessage, isNull);
      expect(scheduledDownload.result, result);
    });

    test('should create ScheduledDownload with error', () {
      final scheduledDownload = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        executedAt: testExecutedAt,
        isExecuted: true,
        isSuccessful: false,
        errorMessage: 'Network timeout',
        result: null,
      );

      expect(scheduledDownload.isExecuted, true);
      expect(scheduledDownload.isSuccessful, false);
      expect(scheduledDownload.errorMessage, 'Network timeout');
      expect(scheduledDownload.result, isNull);
    });

    test('should create copy with updated fields', () {
      final original = ScheduledDownload(
        id: 'original-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        isExecuted: false,
        isSuccessful: false,
      );

      final updated = original.copyWith(
        executedAt: testExecutedAt,
        isExecuted: true,
        isSuccessful: true,
        result: {'completed': true},
      );

      expect(updated.id, original.id);
      expect(updated.scheduleId, original.scheduleId);
      expect(updated.downloadId, original.downloadId);
      expect(updated.scheduledAt, original.scheduledAt);
      expect(updated.executedAt, testExecutedAt);
      expect(updated.isExecuted, true);
      expect(updated.isSuccessful, true);
      expect(updated.result, {'completed': true});
    });

    test('should handle partial updates in copyWith', () {
      final original = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        isExecuted: false,
        isSuccessful: false,
      );

      final updated = original.copyWith(
        isExecuted: true,
        errorMessage: 'Failed to download',
      );

      expect(updated.isExecuted, true);
      expect(updated.isSuccessful, false); // Unchanged
      expect(updated.errorMessage, 'Failed to download');
      expect(updated.executedAt, isNull); // Unchanged
    });

    test('should support equatable comparison', () {
      final download1 = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        isExecuted: true,
        isSuccessful: true,
      );

      final download2 = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        isExecuted: true,
        isSuccessful: true,
      );

      final download3 = ScheduledDownload(
        id: 'different-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        isExecuted: true,
        isSuccessful: true,
      );

      expect(download1, equals(download2));
      expect(download1, isNot(equals(download3)));
    });

    test('should handle null result in copyWith', () {
      final original = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        result: {'original': 'data'},
      );

      final updated = original.copyWith(result: null);

      expect(updated.result, isNull);
    });

    test('should handle complex result data', () {
      final complexResult = {
        'fileName': 'video.mp4',
        'fileSize': 5242880,
        'duration': 180.5,
        'quality': '1080p',
        'format': 'mp4',
        'downloadUrl': 'https://example.com/download/video.mp4',
        'metadata': {
          'title': 'Sample Video',
          'uploader': 'Test Channel',
          'viewCount': 15000,
        }
      };

      final scheduledDownload = ScheduledDownload(
        id: 'complex-test',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        executedAt: testExecutedAt,
        isExecuted: true,
        isSuccessful: true,
        result: complexResult,
      );

      expect(scheduledDownload.result, complexResult);
      expect(scheduledDownload.result?['metadata'], isA<Map<String, dynamic>>());
      expect(scheduledDownload.result?['metadata']?['title'], 'Sample Video');
    });

    test('should handle execution timing', () {
      final scheduledDownload = ScheduledDownload(
        id: 'timing-test',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
        executedAt: testExecutedAt,
        isExecuted: true,
        isSuccessful: true,
      );

      final executionDuration = scheduledDownload.executedAt!.difference(scheduledDownload.scheduledAt);
      expect(executionDuration.inMinutes, 5); // 10:35 - 10:30 = 5 minutes
    });

    test('should validate required fields', () {
      // Test that required fields are present
      final scheduledDownload = ScheduledDownload(
        id: 'test-id',
        scheduleId: 'schedule-123',
        downloadId: 'download-456',
        scheduledAt: testScheduledAt,
      );

      expect(scheduledDownload.id, isNotEmpty);
      expect(scheduledDownload.scheduleId, isNotEmpty);
      expect(scheduledDownload.downloadId, isNotEmpty);
      expect(scheduledDownload.scheduledAt, isNotNull);
    });
  });
}