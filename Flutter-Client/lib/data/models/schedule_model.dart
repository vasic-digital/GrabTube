import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/schedule.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  ScheduleModel({
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

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  final String id;
  final String name;
  final String? description;
  final String type;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'start_time')
  final String? startTime;

  @JsonKey(name: 'recurrence_pattern')
  final String? recurrencePattern;

  @JsonKey(name: 'week_days')
  final List<String>? weekDays;

  final int? interval;

  @JsonKey(name: 'time_unit')
  final String? timeUnit;

  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'last_executed_at')
  final String? lastExecutedAt;

  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  /// Convert to domain entity
  Schedule toEntity() {
    return Schedule(
      id: id,
      name: name,
      description: description,
      type: _parseScheduleType(type),
      startDate: startDate != null ? DateTime.parse(startDate!) : null,
      startTime: startTime != null ? DateTime.parse(startTime!) : null,
      recurrencePattern: recurrencePattern != null
          ? _parseRecurrencePattern(recurrencePattern!)
          : null,
      weekDays: weekDays?.map(_parseWeekDay).toList(),
      interval: interval,
      timeUnit: timeUnit != null ? _parseTimeUnit(timeUnit!) : null,
      dayOfMonth: dayOfMonth,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      lastExecutedAt:
          lastExecutedAt != null ? DateTime.parse(lastExecutedAt!) : null,
      metadata: metadata,
    );
  }

  /// Create from domain entity
  factory ScheduleModel.fromEntity(Schedule entity) {
    return ScheduleModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type.name,
      startDate: entity.startDate?.toIso8601String(),
      startTime: entity.startTime?.toIso8601String(),
      recurrencePattern: entity.recurrencePattern?.name,
      weekDays: entity.weekDays?.map((d) => d.name).toList(),
      interval: entity.interval,
      timeUnit: entity.timeUnit?.name,
      dayOfMonth: entity.dayOfMonth,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      lastExecutedAt: entity.lastExecutedAt?.toIso8601String(),
      metadata: entity.metadata,
    );
  }

  static ScheduleType _parseScheduleType(String type) {
    switch (type) {
      case 'oneTime':
        return ScheduleType.oneTime;
      case 'recurring':
        return ScheduleType.recurring;
      case 'periodic':
        return ScheduleType.periodic;
      case 'collection':
        return ScheduleType.collection;
      default:
        return ScheduleType.oneTime;
    }
  }

  static RecurrencePattern _parseRecurrencePattern(String pattern) {
    switch (pattern) {
      case 'daily':
        return RecurrencePattern.daily;
      case 'weekly':
        return RecurrencePattern.weekly;
      case 'monthly':
        return RecurrencePattern.monthly;
      default:
        return RecurrencePattern.daily;
    }
  }

  static WeekDay _parseWeekDay(String day) {
    switch (day) {
      case 'monday':
        return WeekDay.monday;
      case 'tuesday':
        return WeekDay.tuesday;
      case 'wednesday':
        return WeekDay.wednesday;
      case 'thursday':
        return WeekDay.thursday;
      case 'friday':
        return WeekDay.friday;
      case 'saturday':
        return WeekDay.saturday;
      case 'sunday':
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }

  static TimeUnit _parseTimeUnit(String unit) {
    switch (unit) {
      case 'minutes':
        return TimeUnit.minutes;
      case 'hours':
        return TimeUnit.hours;
      case 'days':
        return TimeUnit.days;
      default:
        return TimeUnit.hours;
    }
  }
}
