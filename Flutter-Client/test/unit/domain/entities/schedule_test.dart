import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/schedule.dart';

void main() {
  group('Schedule Model Tests', () {
    final testDate = DateTime(2024, 1, 15, 10, 30); // Jan 15, 2024, 10:30 AM
    final testTime = DateTime(0, 0, 0, 14, 45); // 2:45 PM

    test('should create one-time schedule', () {
      final schedule = Schedule.oneTime(
        id: 'test-one-time',
        name: 'Test One-time',
        executeAt: testDate,
        description: 'Test description',
      );

      expect(schedule.id, 'test-one-time');
      expect(schedule.name, 'Test One-time');
      expect(schedule.description, 'Test description');
      expect(schedule.type, ScheduleType.oneTime);
      expect(schedule.startDate, DateTime(2024, 1, 15));
      expect(schedule.startTime, testDate);
      expect(schedule.isActive, true);
    });

    test('should create daily recurring schedule', () {
      final schedule = Schedule.daily(
        id: 'test-daily',
        name: 'Test Daily',
        startTime: testTime,
        description: 'Daily download',
      );

      expect(schedule.type, ScheduleType.recurring);
      expect(schedule.recurrencePattern, RecurrencePattern.daily);
      expect(schedule.startTime, testTime);
      expect(schedule.isActive, true);
    });

    test('should create weekly recurring schedule', () {
      final schedule = Schedule.weekly(
        id: 'test-weekly',
        name: 'Test Weekly',
        startTime: testTime,
        weekDays: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
        description: 'Weekly downloads',
      );

      expect(schedule.type, ScheduleType.recurring);
      expect(schedule.recurrencePattern, RecurrencePattern.weekly);
      expect(schedule.weekDays, [WeekDay.monday, WeekDay.wednesday, WeekDay.friday]);
    });

    test('should create periodic schedule', () {
      final schedule = Schedule.periodic(
        id: 'test-periodic',
        name: 'Test Periodic',
        interval: 2,
        timeUnit: TimeUnit.hours,
        description: 'Every 2 hours',
      );

      expect(schedule.type, ScheduleType.periodic);
      expect(schedule.interval, 2);
      expect(schedule.timeUnit, TimeUnit.hours);
    });

    test('should create collection schedule', () {
      final schedule = Schedule.collection(
        id: 'test-collection',
        name: 'Test Collection',
        interval: 1,
        timeUnit: TimeUnit.days,
        collectionUrl: 'https://youtube.com/playlist?list=test',
        description: 'Daily collection download',
      );

      expect(schedule.type, ScheduleType.collection);
      expect(schedule.interval, 1);
      expect(schedule.timeUnit, TimeUnit.days);
      expect(schedule.metadata?['collectionUrl'], 'https://youtube.com/playlist?list=test');
    });

    test('should calculate next execution for one-time schedule', () {
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final schedule = Schedule.oneTime(
        id: 'future-one-time',
        name: 'Future One-time',
        executeAt: futureDate,
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);
      expect(nextExecution!.isAfter(DateTime.now()), true);
    });

    test('should return null for past one-time schedule', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2));
      final schedule = Schedule.oneTime(
        id: 'past-one-time',
        name: 'Past One-time',
        executeAt: pastDate,
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNull);
    });

    test('should calculate next execution for daily schedule', () {
      final now = DateTime.now();
      final schedule = Schedule.daily(
        id: 'daily-test',
        name: 'Daily Test',
        startTime: DateTime(0, 0, 0, 15, 0), // 3:00 PM
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);

      // Should be today at 3:00 PM if not past, or tomorrow
      final expectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        15,
        0,
      );

      if (expectedTime.isAfter(now)) {
        expect(nextExecution!.hour, 15);
        expect(nextExecution.minute, 0);
      } else {
        // Tomorrow
        final tomorrow = now.add(const Duration(days: 1));
        expect(nextExecution!.year, tomorrow.year);
        expect(nextExecution.month, tomorrow.month);
        expect(nextExecution.day, tomorrow.day);
        expect(nextExecution.hour, 15);
        expect(nextExecution.minute, 0);
      }
    });

    test('should calculate next execution for weekly schedule', () {
      final schedule = Schedule.weekly(
        id: 'weekly-test',
        name: 'Weekly Test',
        startTime: DateTime(0, 0, 0, 10, 0), // 10:00 AM
        weekDays: [WeekDay.monday, WeekDay.wednesday],
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);
      expect(nextExecution!.hour, 10);
      expect(nextExecution.minute, 0);
    });

    test('should check if schedule should execute now', () {
      final futureDate = DateTime.now().add(const Duration(minutes: 1));
      final schedule = Schedule.oneTime(
        id: 'should-execute',
        name: 'Should Execute',
        executeAt: futureDate,
      );

      // Should not execute now (too far in future)
      expect(schedule.shouldExecuteNow(), false);

      // Test with time close to execution
      final closeDate = DateTime.now().add(const Duration(seconds: 30));
      final closeSchedule = Schedule.oneTime(
        id: 'close-execute',
        name: 'Close Execute',
        executeAt: closeDate,
      );

      expect(closeSchedule.shouldExecuteNow(), true);
    });

    test('should check if schedule is expired', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final expiredSchedule = Schedule.oneTime(
        id: 'expired',
        name: 'Expired',
        executeAt: pastDate,
      );

      expect(expiredSchedule.isExpired(), true);

      final futureDate = DateTime.now().add(const Duration(days: 1));
      final activeSchedule = Schedule.oneTime(
        id: 'active',
        name: 'Active',
        executeAt: futureDate,
      );

      expect(activeSchedule.isExpired(), false);
    });

    test('should create copy with updated fields', () {
      final original = Schedule.oneTime(
        id: 'original',
        name: 'Original',
        executeAt: testDate,
      );

      final updated = original.copyWith(
        name: 'Updated',
        description: 'New description',
        isActive: false,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated');
      expect(updated.description, 'New description');
      expect(updated.isActive, false);
      expect(updated.startDate, original.startDate);
    });

    test('should support equatable comparison', () {
      final schedule1 = Schedule.oneTime(
        id: 'test',
        name: 'Test',
        executeAt: testDate,
      );

      final schedule2 = Schedule.oneTime(
        id: 'test',
        name: 'Test',
        executeAt: testDate,
      );

      final schedule3 = Schedule.oneTime(
        id: 'different',
        name: 'Test',
        executeAt: testDate,
      );

      expect(schedule1, equals(schedule2));
      expect(schedule1, isNot(equals(schedule3)));
    });

    test('should handle monthly recurrence correctly', () {
      final schedule = Schedule(
        id: 'monthly-test',
        name: 'Monthly Test',
        type: ScheduleType.recurring,
        recurrencePattern: RecurrencePattern.monthly,
        startTime: DateTime(0, 0, 0, 9, 0), // 9:00 AM
        dayOfMonth: 15,
        createdAt: DateTime.now(),
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);
      expect(nextExecution!.hour, 9);
      expect(nextExecution.minute, 0);
    });

    test('should handle periodic execution calculation', () {
      final schedule = Schedule.periodic(
        id: 'periodic-test',
        name: 'Periodic Test',
        interval: 2,
        timeUnit: TimeUnit.hours,
      );

      final nextExecution = schedule.calculateNextExecution();
      expect(nextExecution, isNotNull);

      // Should be 2 hours from last execution (or creation time)
      final expectedTime = schedule.lastExecutedAt ?? schedule.createdAt;
      final expectedNext = expectedTime.add(const Duration(hours: 2));

      expect(nextExecution!.difference(expectedTime).inHours, 2);
    });
  });
}