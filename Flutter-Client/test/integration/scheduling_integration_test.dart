import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/schedule.dart';
import 'package:grabtube/domain/entities/scheduled_download.dart';
import 'package:grabtube/domain/repositories/schedule_repository.dart';
import 'package:grabtube/data/repositories/schedule_repository_impl.dart';
import 'package:grabtube/data/services/schedule_execution_service.dart';
import 'package:grabtube/domain/repositories/download_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'scheduling_integration_test.mocks.dart';

@GenerateMocks([DownloadRepository])
void main() {
  late ScheduleRepository scheduleRepository;
  late ScheduleExecutionService executionService;
  late MockDownloadRepository mockDownloadRepository;

  setUp(() {
    mockDownloadRepository = MockDownloadRepository();
    scheduleRepository = ScheduleRepositoryImpl(mockDownloadRepository);
    executionService = ScheduleExecutionServiceImpl(
      scheduleRepository,
      mockDownloadRepository,
    );
  });

  group('Scheduling Integration Tests', () {
    test('should create and retrieve schedule', () async {
      // Create a schedule
      final schedule = Schedule.daily(
        id: 'integration-test-schedule',
        name: 'Integration Test Schedule',
        startTime: DateTime(0, 0, 0, 9, 0), // 9:00 AM
        description: 'Test schedule for integration testing',
      );

      // Save schedule
      await scheduleRepository.createSchedule(schedule);

      // Retrieve schedule
      final retrieved = await scheduleRepository.getScheduleById(schedule.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, schedule.id);
      expect(retrieved.name, schedule.name);
      expect(retrieved.type, schedule.type);
      expect(retrieved.recurrencePattern, schedule.recurrencePattern);
    });

    test('should execute schedule and create scheduled download record', () async {
      // Create a schedule
      final schedule = Schedule.oneTime(
        id: 'execution-test-schedule',
        name: 'Execution Test Schedule',
        executeAt: DateTime.now().add(const Duration(minutes: 1)), // Execute in 1 minute
        metadata: {
          'url': 'https://example.com/test-video',
          'quality': '720p',
          'format': 'mp4',
        },
      );

      await scheduleRepository.createSchedule(schedule);

      // Mock successful download creation
      when(mockDownloadRepository.addDownload(any))
          .thenAnswer((_) async => Result.success(
                Download(
                  id: 'test-download-id',
                  url: 'https://example.com/test-video',
                  title: 'Test Video',
                  status: DownloadStatus.pending,
                  quality: '720p',
                  format: 'mp4',
                ),
              ));

      // Execute schedule
      await executionService.executeScheduleNow(schedule.id);

      // Verify scheduled download was created
      final scheduledDownloads = await scheduleRepository.getScheduledDownloads(schedule.id);
      expect(scheduledDownloads.length, 1);

      final scheduledDownload = scheduledDownloads.first;
      expect(scheduledDownload.scheduleId, schedule.id);
      expect(scheduledDownload.downloadId, 'test-download-id');
      expect(scheduledDownload.isExecuted, true);
      expect(scheduledDownload.isSuccessful, true);
    });

    test('should handle schedule execution failure', () async {
      // Create a schedule
      final schedule = Schedule.oneTime(
        id: 'failure-test-schedule',
        name: 'Failure Test Schedule',
        executeAt: DateTime.now().add(const Duration(minutes: 1)),
        metadata: {
          'url': 'https://example.com/failing-video',
        },
      );

      await scheduleRepository.createSchedule(schedule);

      // Mock download failure
      when(mockDownloadRepository.addDownload(any))
          .thenAnswer((_) async => Result.failure(Exception('Download failed')));

      // Execute schedule
      await executionService.executeScheduleNow(schedule.id);

      // Verify failure was recorded
      final scheduledDownloads = await scheduleRepository.getScheduledDownloads(schedule.id);
      expect(scheduledDownloads.length, 1);

      final scheduledDownload = scheduledDownloads.first;
      expect(scheduledDownload.isExecuted, true);
      expect(scheduledDownload.isSuccessful, false);
      expect(scheduledDownload.errorMessage, contains('Download failed'));
    });

    test('should find schedules to execute', () async {
      // Create schedules - one that should execute now, one that shouldn't
      final shouldExecuteSchedule = Schedule.oneTime(
        id: 'should-execute',
        name: 'Should Execute',
        executeAt: DateTime.now().add(const Duration(seconds: 30)), // Very soon
      );

      final shouldNotExecuteSchedule = Schedule.oneTime(
        id: 'should-not-execute',
        name: 'Should Not Execute',
        executeAt: DateTime.now().add(const Duration(hours: 1)), // Much later
      );

      await scheduleRepository.createSchedule(shouldExecuteSchedule);
      await scheduleRepository.createSchedule(shouldNotExecuteSchedule);

      // Find schedules to execute
      final schedulesToExecute = await scheduleRepository.getSchedulesToExecute();

      // Should find the schedule that should execute soon
      expect(schedulesToExecute.length, 1);
      expect(schedulesToExecute.first.id, shouldExecuteSchedule.id);
    });

    test('should toggle schedule active status', () async {
      // Create active schedule
      final schedule = Schedule.daily(
        id: 'toggle-test',
        name: 'Toggle Test',
        startTime: DateTime(0, 0, 0, 10, 0),
      );

      await scheduleRepository.createSchedule(schedule);
      expect(schedule.isActive, true);

      // Toggle to inactive
      await scheduleRepository.toggleSchedule(schedule.id, false);

      final updated = await scheduleRepository.getScheduleById(schedule.id);
      expect(updated?.isActive, false);

      // Toggle back to active
      await scheduleRepository.toggleSchedule(schedule.id, true);

      final reUpdated = await scheduleRepository.getScheduleById(schedule.id);
      expect(reUpdated?.isActive, true);
    });

    test('should update schedule execution info', () async {
      // Create schedule
      final schedule = Schedule.oneTime(
        id: 'execution-info-test',
        name: 'Execution Info Test',
        executeAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await scheduleRepository.createSchedule(schedule);

      // Mark as executed
      final executedAt = DateTime.now();
      await scheduleRepository.markScheduleExecuted(schedule.id, executedAt);

      final updated = await scheduleRepository.getScheduleById(schedule.id);
      expect(updated?.lastExecutedAt, isNotNull);
      expect(updated?.executionCount, 1);
    });

    test('should get next execution times for all schedules', () async {
      // Create multiple schedules
      final schedule1 = Schedule.daily(
        id: 'next-execution-1',
        name: 'Daily Schedule',
        startTime: DateTime(0, 0, 0, 8, 0), // 8:00 AM
      );

      final schedule2 = Schedule.oneTime(
        id: 'next-execution-2',
        name: 'One-time Schedule',
        executeAt: DateTime.now().add(const Duration(days: 1)),
      );

      await scheduleRepository.createSchedule(schedule1);
      await scheduleRepository.createSchedule(schedule2);

      // Get next execution times
      final nextExecutionTimes = await scheduleRepository.getNextExecutionTimes();

      expect(nextExecutionTimes.length, 2);
      expect(nextExecutionTimes[schedule1.id], isNotNull);
      expect(nextExecutionTimes[schedule2.id], isNotNull);
    });

    test('should cleanup old scheduled downloads', () async {
      // Create a schedule and some old scheduled downloads
      final schedule = Schedule.daily(
        id: 'cleanup-test',
        name: 'Cleanup Test',
        startTime: DateTime(0, 0, 0, 12, 0),
      );

      await scheduleRepository.createSchedule(schedule);

      // Create old scheduled downloads (30+ days ago)
      final oldDate = DateTime.now().subtract(const Duration(days: 35));
      final oldScheduledDownload = ScheduledDownload(
        id: 'old-scheduled-download',
        scheduleId: schedule.id,
        downloadId: 'old-download-id',
        scheduledAt: oldDate,
        executedAt: oldDate.add(const Duration(hours: 1)),
        isExecuted: true,
        isSuccessful: true,
      );

      await scheduleRepository.createScheduledDownload(oldScheduledDownload);

      // Verify it exists
      var scheduledDownloads = await scheduleRepository.getScheduledDownloads(schedule.id);
      expect(scheduledDownloads.length, 1);

      // Cleanup old downloads
      await scheduleRepository.cleanupOldScheduledDownloads();

      // Verify it was cleaned up
      scheduledDownloads = await scheduleRepository.getScheduledDownloads(schedule.id);
      expect(scheduledDownloads.length, 0);
    });

    test('should handle schedule execution service lifecycle', () async {
      // Start service
      await executionService.start();

      // Check that it's running (this would need actual service implementation)
      final stats = await executionService.getExecutionStats();
      expect(stats, isNotNull);

      // Stop service
      await executionService.stop();

      // Service should be stopped
      final statsAfterStop = await executionService.getExecutionStats();
      expect(statsAfterStop, isNotNull);
    });

    test('should provide execution statistics', () async {
      // Create some test data
      final schedule1 = Schedule.daily(
        id: 'stats-schedule-1',
        name: 'Stats Schedule 1',
        startTime: DateTime(0, 0, 0, 9, 0),
      );

      final schedule2 = Schedule.daily(
        id: 'stats-schedule-2',
        name: 'Stats Schedule 2',
        startTime: DateTime(0, 0, 0, 10, 0),
        isActive: false, // Inactive
      );

      await scheduleRepository.createSchedule(schedule1);
      await scheduleRepository.createSchedule(schedule2);

      // Get execution stats
      final stats = await executionService.getExecutionStats();

      expect(stats['totalSchedules'], 2);
      expect(stats['activeSchedules'], 1);
      expect(stats.containsKey('totalExecutions'), true);
      expect(stats.containsKey('successfulExecutions'), true);
    });
  });
}