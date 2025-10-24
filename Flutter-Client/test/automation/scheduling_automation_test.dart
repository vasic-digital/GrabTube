import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/schedule.dart';
import 'package:grabtube/domain/entities/scheduled_download.dart';

void main() {
  group('Scheduling Automation Tests', () {
    test('should handle complex recurring schedule calculations', () {
      // Test weekly schedule with multiple days
      final weeklySchedule = Schedule.weekly(
        id: 'complex-weekly',
        name: 'Complex Weekly',
        startTime: DateTime(0, 0, 0, 9, 30), // 9:30 AM
        weekDays: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday, WeekDay.sunday],
      );

      // Test next execution calculation for different days
      final testCases = [
        // Monday -> should execute Monday
        DateTime(2024, 1, 8, 8, 0), // Monday 8:00 AM
        DateTime(2024, 1, 10, 8, 0), // Wednesday 8:00 AM
        DateTime(2024, 1, 12, 8, 0), // Friday 8:00 AM
        DateTime(2024, 1, 14, 8, 0), // Sunday 8:00 AM
        DateTime(2024, 1, 9, 8, 0), // Tuesday 8:00 AM (not in schedule)
      ];

      for (final testDate in testCases) {
        final nextExecution = weeklySchedule.calculateNextExecution(from: testDate);
        expect(nextExecution, isNotNull, reason: 'Should calculate next execution for $testDate');

        // Verify it's on a scheduled day
        final executionDay = WeekDay.values[nextExecution!.weekday - 1];
        expect(weeklySchedule.weekDays!.contains(executionDay), true,
            reason: 'Execution should be on a scheduled day');

        // Verify time is correct
        expect(nextExecution.hour, 9);
        expect(nextExecution.minute, 30);
      }
    });

    test('should handle monthly schedule edge cases', () {
      // Test monthly schedule on the 31st
      final monthlySchedule = Schedule(
        id: 'monthly-31st',
        name: 'Monthly 31st',
        type: ScheduleType.recurring,
        recurrencePattern: RecurrencePattern.monthly,
        startTime: DateTime(0, 0, 0, 10, 0),
        dayOfMonth: 31,
        createdAt: DateTime.now(),
      );

      // Test in months with different numbers of days
      final testCases = [
        DateTime(2024, 1, 1, 8, 0), // January (31 days)
        DateTime(2024, 2, 1, 8, 0), // February (28/29 days) - should use last day
        DateTime(2024, 4, 1, 8, 0), // April (30 days) - should use 30th
      ];

      for (final testDate in testCases) {
        final nextExecution = monthlySchedule.calculateNextExecution(from: testDate);
        expect(nextExecution, isNotNull);

        final executionMonth = nextExecution!.month;
        final daysInMonth = DateTime(nextExecution.year, nextExecution.month + 1, 0).day;

        // Should be on the 31st or last day of month, whichever is smaller
        expect(nextExecution.day, minOf(31, daysInMonth));
      }
    });

    test('should handle schedule expiration correctly', () {
      final now = DateTime.now();

      // Test max executions
      final maxExecutionsSchedule = Schedule.daily(
        id: 'max-executions',
        name: 'Max Executions',
        startTime: DateTime(0, 0, 0, 9, 0),
        maxExecutions: 5,
      ).copyWith(executionCount: 5);

      expect(maxExecutionsSchedule.isExpired(), true);

      // Test end date
      final endDateSchedule = Schedule.daily(
        id: 'end-date',
        name: 'End Date',
        startTime: DateTime(0, 0, 0, 9, 0),
        endDate: now.subtract(const Duration(days: 1)), // Yesterday
      );

      expect(endDateSchedule.isExpired(), true);

      // Test active schedule
      final activeSchedule = Schedule.daily(
        id: 'active',
        name: 'Active',
        startTime: DateTime(0, 0, 0, 9, 0),
        endDate: now.add(const Duration(days: 30)),
        maxExecutions: 100,
      ).copyWith(executionCount: 10);

      expect(activeSchedule.isExpired(), false);
    });

    test('should handle periodic schedules with different time units', () {
      final testCases = [
        {'unit': TimeUnit.minutes, 'interval': 30, 'expectedHours': 0, 'expectedMinutes': 30},
        {'unit': TimeUnit.hours, 'interval': 2, 'expectedHours': 2, 'expectedMinutes': 0},
        {'unit': TimeUnit.days, 'interval': 1, 'expectedHours': 24, 'expectedMinutes': 0},
        {'unit': TimeUnit.weeks, 'interval': 1, 'expectedHours': 168, 'expectedMinutes': 0},
      ];

      for (final testCase in testCases) {
        final schedule = Schedule.periodic(
          id: 'periodic-${testCase['unit']}',
          name: 'Periodic Test',
          interval: testCase['interval'] as int,
          timeUnit: testCase['unit'] as TimeUnit,
        );

        final nextExecution = schedule.calculateNextExecution();
        expect(nextExecution, isNotNull);

        final timeDiff = nextExecution!.difference(schedule.createdAt);
        expect(timeDiff.inHours, testCase['expectedHours'] as int);
        expect(timeDiff.inMinutes % 60, testCase['expectedMinutes'] as int);
      }
    });

    test('should handle schedule execution timing precision', () {
      final baseTime = DateTime(2024, 1, 15, 10, 0); // 10:00 AM

      // Test exact timing
      final exactSchedule = Schedule.oneTime(
        id: 'exact-timing',
        name: 'Exact Timing',
        executeAt: baseTime,
      );

      expect(exactSchedule.shouldExecuteNow(currentTime: baseTime), true);

      // Test within tolerance (1 minute)
      final withinTolerance = baseTime.add(const Duration(seconds: 30));
      expect(exactSchedule.shouldExecuteNow(currentTime: withinTolerance), true);

      // Test outside tolerance
      final outsideTolerance = baseTime.add(const Duration(minutes: 2));
      expect(exactSchedule.shouldExecuteNow(currentTime: outsideTolerance), false);
    });

    test('should handle complex schedule metadata', () {
      final complexMetadata = {
        'url': 'https://youtube.com/watch?v=test',
        'quality': '1080p',
        'format': 'mp4',
        'folder': '/downloads/videos',
        'customNamePrefix': 'Test_',
        'playlistStrictMode': true,
        'playlistItemLimit': 10,
        'autoStart': true,
        'additionalParams': {
          'subtitles': true,
          'thumbnail': true,
          'description': false,
        }
      };

      final schedule = Schedule.daily(
        id: 'complex-metadata',
        name: 'Complex Metadata',
        startTime: DateTime(0, 0, 0, 9, 0),
        metadata: complexMetadata,
      );

      expect(schedule.metadata, complexMetadata);
      expect(schedule.metadata?['url'], 'https://youtube.com/watch?v=test');
      expect(schedule.metadata?['additionalParams'], isA<Map<String, dynamic>>());
    });

    test('should handle schedule state transitions', () {
      final schedule = Schedule.daily(
        id: 'state-transitions',
        name: 'State Transitions',
        startTime: DateTime(0, 0, 0, 9, 0),
      );

      // Initial state
      expect(schedule.isActive, true);
      expect(schedule.executionCount, 0);
      expect(schedule.lastExecutedAt, isNull);

      // After execution
      final executedSchedule = schedule.copyWith(
        executionCount: 1,
        lastExecutedAt: DateTime.now(),
      );

      expect(executedSchedule.executionCount, 1);
      expect(executedSchedule.lastExecutedAt, isNotNull);

      // After deactivation
      final deactivatedSchedule = executedSchedule.copyWith(isActive: false);
      expect(deactivatedSchedule.isActive, false);

      // After reactivation
      final reactivatedSchedule = deactivatedSchedule.copyWith(isActive: true);
      expect(reactivatedSchedule.isActive, true);
    });

    test('should handle scheduled download state management', () {
      final scheduledDownload = ScheduledDownload(
        id: 'test-scheduled-download',
        scheduleId: 'test-schedule',
        downloadId: 'test-download',
        scheduledAt: DateTime.now(),
      );

      // Initial state
      expect(scheduledDownload.isExecuted, false);
      expect(scheduledDownload.isSuccessful, false);

      // After successful execution
      final successful = scheduledDownload.copyWith(
        executedAt: DateTime.now().add(const Duration(minutes: 5)),
        isExecuted: true,
        isSuccessful: true,
        result: {'fileSize': 1048576, 'duration': 180},
      );

      expect(successful.isExecuted, true);
      expect(successful.isSuccessful, true);
      expect(successful.result, isNotNull);

      // After failed execution
      final failed = scheduledDownload.copyWith(
        executedAt: DateTime.now().add(const Duration(seconds: 30)),
        isExecuted: true,
        isSuccessful: false,
        errorMessage: 'Network timeout',
      );

      expect(failed.isExecuted, true);
      expect(failed.isSuccessful, false);
      expect(failed.errorMessage, 'Network timeout');
    });

    test('should handle concurrent schedule executions', () {
      // This test would verify that multiple schedules can execute concurrently
      // without interfering with each other

      final schedule1 = Schedule.oneTime(
        id: 'concurrent-1',
        name: 'Concurrent 1',
        executeAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      final schedule2 = Schedule.oneTime(
        id: 'concurrent-2',
        name: 'Concurrent 2',
        executeAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      // Both should be able to execute at the same time
      expect(schedule1.shouldExecuteNow(), false);
      expect(schedule2.shouldExecuteNow(), false);

      final futureTime = DateTime.now().add(const Duration(minutes: 1));

      expect(schedule1.shouldExecuteNow(currentTime: futureTime), true);
      expect(schedule2.shouldExecuteNow(currentTime: futureTime), true);
    });

    test('should handle schedule validation', () {
      // Test invalid schedule creation attempts

      // Missing required fields should fail
      expect(() {
        Schedule(
          id: '', // Empty ID
          name: 'Test',
          type: ScheduleType.oneTime,
          createdAt: DateTime.now(),
        );
      }, throwsAssertionError);

      // Invalid date combinations
      expect(() {
        Schedule.oneTime(
          id: 'invalid-date',
          name: 'Invalid Date',
          executeAt: DateTime.now().subtract(const Duration(days: 1)), // Past date
        );
      }, throwsAssertionError);

      // Invalid recurrence configuration
      expect(() {
        Schedule.weekly(
          id: 'invalid-weekly',
          name: 'Invalid Weekly',
          startTime: DateTime(0, 0, 0, 9, 0),
          weekDays: [], // Empty weekdays
        );
      }, throwsAssertionError);
    });

    test('should handle large scale scheduling operations', () {
      // Test performance with many schedules
      final schedules = List.generate(100, (index) {
        return Schedule.daily(
          id: 'performance-$index',
          name: 'Performance Schedule $index',
          startTime: DateTime(0, 0, 0, 9, index % 24), // Different hours
        );
      });

      final startTime = DateTime.now();

      // Calculate next executions for all schedules
      for (final schedule in schedules) {
        final nextExecution = schedule.calculateNextExecution();
        expect(nextExecution, isNotNull);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should complete within reasonable time (less than 1 second for 100 schedules)
      expect(duration.inMilliseconds, lessThan(1000));
    });

    test('should handle timezone considerations', () {
      // Test schedule execution across timezone changes
      // This is important for mobile apps that may travel across timezones

      final schedule = Schedule.daily(
        id: 'timezone-test',
        name: 'Timezone Test',
        startTime: DateTime(0, 0, 0, 9, 0), // 9:00 AM in system timezone
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);

      // The execution time should be consistent regardless of system timezone
      // (This is a simplified test; real timezone testing would be more complex)
      expect(nextExecution!.hour, 9);
      expect(nextExecution.minute, 0);
    });
  });
}

// Helper function for min calculation
int minOf(int a, int b) => a < b ? a : b;