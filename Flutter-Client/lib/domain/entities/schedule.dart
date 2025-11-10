import 'package:equatable/equatable.dart';

/// Schedule type enum
enum ScheduleType {
  oneTime,
  recurring,
  periodic,
  collection,
}

/// Recurrence pattern enum for recurring schedules
enum RecurrencePattern {
  daily,
  weekly,
  monthly,
}

/// Week day enum for weekly schedules
enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Time unit enum for periodic schedules
enum TimeUnit {
  minutes,
  hours,
  days,
}

/// Schedule entity representing a scheduled download task
class Schedule extends Equatable {
  const Schedule({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.description,
    this.startDate,
    this.startTime,
    this.recurrencePattern,
    this.weekDays,
    this.interval,
    this.timeUnit,
    this.dayOfMonth,
    this.isActive = true,
    this.lastExecutedAt,
    this.metadata,
  });

  /// Unique schedule identifier
  final String id;

  /// Schedule name
  final String name;

  /// Schedule description (optional)
  final String? description;

  /// Type of schedule (one-time, recurring, periodic, collection)
  final ScheduleType type;

  /// Start date for the schedule (optional, for recurring schedules)
  final DateTime? startDate;

  /// Start time for execution
  final DateTime? startTime;

  /// Recurrence pattern for recurring schedules
  final RecurrencePattern? recurrencePattern;

  /// Days of the week for weekly recurring schedules
  final List<WeekDay>? weekDays;

  /// Interval for periodic schedules
  final int? interval;

  /// Time unit for periodic schedules
  final TimeUnit? timeUnit;

  /// Day of month for monthly recurring schedules (1-31)
  final int? dayOfMonth;

  /// Whether the schedule is active
  final bool isActive;

  /// When the schedule was created
  final DateTime createdAt;

  /// When the schedule was last executed
  final DateTime? lastExecutedAt;

  /// Additional metadata for the schedule
  final Map<String, dynamic>? metadata;

  /// Factory constructor for one-time schedule
  factory Schedule.oneTime({
    required String id,
    required String name,
    required DateTime executeAt,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: ScheduleType.oneTime,
      startDate: DateTime(executeAt.year, executeAt.month, executeAt.day),
      startTime: executeAt,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Factory constructor for daily recurring schedule
  factory Schedule.daily({
    required String id,
    required String name,
    required DateTime startTime,
    String? description,
    DateTime? startDate,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: ScheduleType.recurring,
      recurrencePattern: RecurrencePattern.daily,
      startDate: startDate,
      startTime: startTime,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Factory constructor for weekly recurring schedule
  factory Schedule.weekly({
    required String id,
    required String name,
    required DateTime startTime,
    required List<WeekDay> weekDays,
    String? description,
    DateTime? startDate,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: ScheduleType.recurring,
      recurrencePattern: RecurrencePattern.weekly,
      weekDays: weekDays,
      startDate: startDate,
      startTime: startTime,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Factory constructor for periodic schedule
  factory Schedule.periodic({
    required String id,
    required String name,
    required int interval,
    required TimeUnit timeUnit,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: ScheduleType.periodic,
      interval: interval,
      timeUnit: timeUnit,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Factory constructor for collection schedule (e.g., playlist monitoring)
  factory Schedule.collection({
    required String id,
    required String name,
    required int interval,
    required TimeUnit timeUnit,
    required String collectionUrl,
    String? description,
  }) {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: ScheduleType.collection,
      interval: interval,
      timeUnit: timeUnit,
      createdAt: DateTime.now(),
      metadata: {'collectionUrl': collectionUrl},
    );
  }

  /// Calculate the next execution time for this schedule
  DateTime? calculateNextExecution() {
    if (!isActive) return null;

    final now = DateTime.now();
    final baseTime = lastExecutedAt ?? createdAt;

    switch (type) {
      case ScheduleType.oneTime:
        if (startTime == null) return null;
        return startTime!.isAfter(now) ? startTime : null;

      case ScheduleType.recurring:
        return _calculateRecurringExecution(now);

      case ScheduleType.periodic:
      case ScheduleType.collection:
        return _calculatePeriodicExecution(baseTime);
    }
  }

  /// Calculate next execution for recurring schedules
  DateTime? _calculateRecurringExecution(DateTime now) {
    if (startTime == null) return null;

    switch (recurrencePattern) {
      case RecurrencePattern.daily:
        return _calculateDailyExecution(now);

      case RecurrencePattern.weekly:
        return _calculateWeeklyExecution(now);

      case RecurrencePattern.monthly:
        return _calculateMonthlyExecution(now);

      default:
        return null;
    }
  }

  /// Calculate next daily execution
  DateTime _calculateDailyExecution(DateTime now) {
    final targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime!.hour,
      startTime!.minute,
    );

    if (targetTime.isAfter(now)) {
      return targetTime;
    } else {
      return targetTime.add(const Duration(days: 1));
    }
  }

  /// Calculate next weekly execution
  DateTime _calculateWeeklyExecution(DateTime now) {
    if (weekDays == null || weekDays!.isEmpty) {
      return _calculateDailyExecution(now);
    }

    final currentWeekDay = now.weekday;
    final targetWeekDays = weekDays!.map(_weekDayToInt).toList()..sort();

    for (final targetDay in targetWeekDays) {
      int daysUntilTarget = targetDay - currentWeekDay;
      if (daysUntilTarget < 0) daysUntilTarget += 7;

      final targetDate = now.add(Duration(days: daysUntilTarget));
      final targetTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startTime!.hour,
        startTime!.minute,
      );

      if (targetTime.isAfter(now)) {
        return targetTime;
      }
    }

    // If no valid time today, find next week's first occurrence
    final firstDay = targetWeekDays.first;
    int daysUntilNext = firstDay - currentWeekDay;
    if (daysUntilNext <= 0) daysUntilNext += 7;

    final nextDate = now.add(Duration(days: daysUntilNext));
    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      startTime!.hour,
      startTime!.minute,
    );
  }

  /// Calculate next monthly execution
  DateTime _calculateMonthlyExecution(DateTime now) {
    if (dayOfMonth == null) return _calculateDailyExecution(now);

    final targetDate = DateTime(
      now.year,
      now.month,
      dayOfMonth!,
      startTime!.hour,
      startTime!.minute,
    );

    if (targetDate.isAfter(now)) {
      return targetDate;
    } else {
      // Next month
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      return DateTime(
        nextYear,
        nextMonth,
        dayOfMonth!,
        startTime!.hour,
        startTime!.minute,
      );
    }
  }

  /// Calculate next periodic execution
  DateTime _calculatePeriodicExecution(DateTime baseTime) {
    if (interval == null || timeUnit == null) return DateTime.now();

    final duration = _getDuration(interval!, timeUnit!);
    return baseTime.add(duration);
  }

  /// Convert time unit and interval to Duration
  Duration _getDuration(int interval, TimeUnit unit) {
    switch (unit) {
      case TimeUnit.minutes:
        return Duration(minutes: interval);
      case TimeUnit.hours:
        return Duration(hours: interval);
      case TimeUnit.days:
        return Duration(days: interval);
    }
  }

  /// Convert WeekDay to int (1 = Monday, 7 = Sunday)
  int _weekDayToInt(WeekDay day) {
    switch (day) {
      case WeekDay.monday:
        return 1;
      case WeekDay.tuesday:
        return 2;
      case WeekDay.wednesday:
        return 3;
      case WeekDay.thursday:
        return 4;
      case WeekDay.friday:
        return 5;
      case WeekDay.saturday:
        return 6;
      case WeekDay.sunday:
        return 7;
    }
  }

  /// Check if schedule should execute now (within 1 minute window)
  bool shouldExecuteNow() {
    final nextExecution = calculateNextExecution();
    if (nextExecution == null) return false;

    final now = DateTime.now();
    final difference = nextExecution.difference(now);

    return difference.inSeconds.abs() <= 60; // Within 1 minute
  }

  /// Check if one-time schedule is expired
  bool isExpired() {
    if (type != ScheduleType.oneTime) return false;
    if (startTime == null) return true;

    return startTime!.isBefore(DateTime.now());
  }

  /// Create a copy with updated fields
  Schedule copyWith({
    String? id,
    String? name,
    String? description,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? startTime,
    RecurrencePattern? recurrencePattern,
    List<WeekDay>? weekDays,
    int? interval,
    TimeUnit? timeUnit,
    int? dayOfMonth,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastExecutedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      weekDays: weekDays ?? this.weekDays,
      interval: interval ?? this.interval,
      timeUnit: timeUnit ?? this.timeUnit,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        startDate,
        startTime,
        recurrencePattern,
        weekDays,
        interval,
        timeUnit,
        dayOfMonth,
        isActive,
        createdAt,
        lastExecutedAt,
        metadata,
      ];
}
