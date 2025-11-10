import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/scheduled_download.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/schedule_model.dart';
import '../models/scheduled_download_model.dart';

/// Implementation of ScheduleRepository using Hive for local storage
@LazySingleton(as: ScheduleRepository)
class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(
    this._schedulesBox,
    this._scheduledDownloadsBox,
  );

  final Box<ScheduleModel> _schedulesBox;
  final Box<ScheduledDownloadModel> _scheduledDownloadsBox;

  final _scheduleController = StreamController<Schedule>.broadcast();
  final _scheduledDownloadController =
      StreamController<ScheduledDownload>.broadcast();

  @override
  Stream<Schedule> get scheduleUpdates => _scheduleController.stream;

  @override
  Stream<ScheduledDownload> get scheduledDownloadUpdates =>
      _scheduledDownloadController.stream;

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await _schedulesBox.put(schedule.id, model);
      _scheduleController.add(schedule);
      return schedule;
    } catch (e) {
      throw Exception('Failed to create schedule: ${e.toString()}');
    }
  }

  @override
  Future<Schedule> updateSchedule(Schedule schedule) async {
    try {
      if (!_schedulesBox.containsKey(schedule.id)) {
        throw Exception('Schedule not found: ${schedule.id}');
      }

      final model = ScheduleModel.fromEntity(schedule);
      await _schedulesBox.put(schedule.id, model);
      _scheduleController.add(schedule);
      return schedule;
    } catch (e) {
      throw Exception('Failed to update schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _schedulesBox.delete(scheduleId);

      // Also delete associated scheduled downloads
      final scheduledDownloads = await getScheduledDownloads(scheduleId);
      for (final sd in scheduledDownloads) {
        await deleteScheduledDownload(sd.id);
      }
    } catch (e) {
      throw Exception('Failed to delete schedule: ${e.toString()}');
    }
  }

  @override
  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      final model = _schedulesBox.get(scheduleId);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final models = _schedulesBox.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Schedule>> getActiveSchedules() async {
    try {
      final allSchedules = await getAllSchedules();
      return allSchedules.where((s) => s.isActive).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Schedule>> getSchedulesByType(ScheduleType type) async {
    try {
      final allSchedules = await getAllSchedules();
      return allSchedules.where((s) => s.type == type).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> toggleSchedule(String scheduleId, bool isActive) async {
    try {
      final schedule = await getScheduleById(scheduleId);
      if (schedule == null) {
        throw Exception('Schedule not found: $scheduleId');
      }

      // Create updated schedule with new isActive value
      final updatedSchedule = Schedule(
        id: schedule.id,
        name: schedule.name,
        description: schedule.description,
        type: schedule.type,
        startDate: schedule.startDate,
        startTime: schedule.startTime,
        recurrencePattern: schedule.recurrencePattern,
        weekDays: schedule.weekDays,
        interval: schedule.interval,
        timeUnit: schedule.timeUnit,
        dayOfMonth: schedule.dayOfMonth,
        isActive: isActive,
        createdAt: schedule.createdAt,
        lastExecutedAt: schedule.lastExecutedAt,
        metadata: schedule.metadata,
      );

      await updateSchedule(updatedSchedule);
    } catch (e) {
      throw Exception('Failed to toggle schedule: ${e.toString()}');
    }
  }

  @override
  Future<List<Schedule>> getSchedulesToExecute() async {
    try {
      final activeSchedules = await getActiveSchedules();
      final now = DateTime.now();
      final toExecute = <Schedule>[];

      for (final schedule in activeSchedules) {
        final nextExecution = schedule.calculateNextExecution();
        if (nextExecution != null && nextExecution.isBefore(now)) {
          toExecute.add(schedule);
        }
      }

      return toExecute;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markScheduleExecuted(
    String scheduleId,
    DateTime executedAt,
  ) async {
    try {
      final schedule = await getScheduleById(scheduleId);
      if (schedule == null) {
        throw Exception('Schedule not found: $scheduleId');
      }

      final updatedSchedule = Schedule(
        id: schedule.id,
        name: schedule.name,
        description: schedule.description,
        type: schedule.type,
        startDate: schedule.startDate,
        startTime: schedule.startTime,
        recurrencePattern: schedule.recurrencePattern,
        weekDays: schedule.weekDays,
        interval: schedule.interval,
        timeUnit: schedule.timeUnit,
        dayOfMonth: schedule.dayOfMonth,
        isActive: schedule.isActive,
        createdAt: schedule.createdAt,
        lastExecutedAt: executedAt,
        metadata: schedule.metadata,
      );

      await updateSchedule(updatedSchedule);
    } catch (e) {
      throw Exception('Failed to mark schedule executed: ${e.toString()}');
    }
  }

  @override
  Future<ScheduledDownload> createScheduledDownload(
    ScheduledDownload scheduledDownload,
  ) async {
    try {
      final model = ScheduledDownloadModel.fromEntity(scheduledDownload);
      await _scheduledDownloadsBox.put(scheduledDownload.id, model);
      _scheduledDownloadController.add(scheduledDownload);
      return scheduledDownload;
    } catch (e) {
      throw Exception('Failed to create scheduled download: ${e.toString()}');
    }
  }

  @override
  Future<void> updateScheduledDownload(
    ScheduledDownload scheduledDownload,
  ) async {
    try {
      if (!_scheduledDownloadsBox.containsKey(scheduledDownload.id)) {
        throw Exception('Scheduled download not found: ${scheduledDownload.id}');
      }

      final model = ScheduledDownloadModel.fromEntity(scheduledDownload);
      await _scheduledDownloadsBox.put(scheduledDownload.id, model);
      _scheduledDownloadController.add(scheduledDownload);
    } catch (e) {
      throw Exception('Failed to update scheduled download: ${e.toString()}');
    }
  }

  @override
  Future<List<ScheduledDownload>> getScheduledDownloads(
    String scheduleId,
  ) async {
    try {
      final allScheduledDownloads = await getAllScheduledDownloads();
      return allScheduledDownloads
          .where((sd) => sd.scheduleId == scheduleId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ScheduledDownload>> getAllScheduledDownloads() async {
    try {
      final models = _scheduledDownloadsBox.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ScheduledDownload>> getPendingScheduledDownloads() async {
    try {
      final allScheduledDownloads = await getAllScheduledDownloads();
      return allScheduledDownloads.where((sd) => !sd.isExecuted).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ScheduledDownload>> getCompletedScheduledDownloads() async {
    try {
      final allScheduledDownloads = await getAllScheduledDownloads();
      return allScheduledDownloads.where((sd) => sd.isExecuted).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteScheduledDownload(String scheduledDownloadId) async {
    try {
      await _scheduledDownloadsBox.delete(scheduledDownloadId);
    } catch (e) {
      throw Exception('Failed to delete scheduled download: ${e.toString()}');
    }
  }

  @disposeMethod
  void dispose() {
    _scheduleController.close();
    _scheduledDownloadController.close();
  }
}
