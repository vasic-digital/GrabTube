import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/download_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/download_schedule_model.dart';

/// Implementation of ScheduleRepository using Hive
class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._schedulesBox);

  final Box<String> _schedulesBox;

  final _schedulesController = StreamController<List<DownloadSchedule>>.broadcast();

  @override
  Stream<List<DownloadSchedule>> get scheduleUpdates => _schedulesController.stream;

  @override
  Future<List<DownloadSchedule>> getSchedules() async {
    try {
      final schedules = <DownloadSchedule>[];
      for (final key in _schedulesBox.keys) {
        final jsonString = _schedulesBox.get(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final model = DownloadScheduleModel.fromJson(json);
          schedules.add(model.toEntity());
        }
      }
      return schedules;
    } catch (e) {
      throw Exception('Failed to get schedules: ${e.toString()}');
    }
  }

  @override
  Future<DownloadSchedule?> getSchedule(String id) async {
    try {
      final jsonString = _schedulesBox.get(id);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = DownloadScheduleModel.fromJson(json);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DownloadSchedule?> getScheduleById(String id) async {
    return getSchedule(id);
  }

  @override
  Future<List<DownloadSchedule>> getPendingSchedules() async {
    final schedules = await getSchedules();
    return schedules.where((s) => s.status == ScheduleStatus.pending).toList();
  }

  @override
  Future<List<DownloadSchedule>> getDueSchedules() async {
    final schedules = await getPendingSchedules();
    final now = DateTime.now();
    return schedules
        .where((s) => s.nextExecutionTime != null && s.nextExecutionTime!.isBefore(now))
        .toList();
  }

  @override
  Future<DownloadSchedule> createSchedule(DownloadSchedule schedule) async {
    try {
      final model = DownloadScheduleModel.fromEntity(schedule);
      final jsonString = jsonEncode(model.toJson());
      await _schedulesBox.put(schedule.id, jsonString);
      await _notifySchedulesChanged();
      return schedule;
    } catch (e) {
      throw Exception('Failed to create schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSchedule(DownloadSchedule schedule) async {
    try {
      final model = DownloadScheduleModel.fromEntity(schedule);
      final jsonString = jsonEncode(model.toJson());
      await _schedulesBox.put(schedule.id, jsonString);
      await _notifySchedulesChanged();
    } catch (e) {
      throw Exception('Failed to update schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    try {
      await _schedulesBox.delete(id);
      await _notifySchedulesChanged();
    } catch (e) {
      throw Exception('Failed to delete schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelSchedule(String id) async {
    try {
      final schedule = await getSchedule(id);
      if (schedule != null) {
        final updatedSchedule = schedule.copyWith(
          status: ScheduleStatus.canceled,
        );
        await updateSchedule(updatedSchedule);
      }
    } catch (e) {
      throw Exception('Failed to cancel schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> executeSchedule(String id) async {
    try {
      final schedule = await getSchedule(id);
      if (schedule != null) {
        final updatedSchedule = schedule.copyWith(
          status: ScheduleStatus.executing,
        );
        await updateSchedule(updatedSchedule);
      }
    } catch (e) {
      throw Exception('Failed to execute schedule: ${e.toString()}');
    }
  }

  Future<void> _notifySchedulesChanged() async {
    try {
      final schedules = await getSchedules();
      _schedulesController.add(schedules);
    } catch (e) {
      // Silently fail - this is just for notifications
    }
  }

  void dispose() {
    _schedulesController.close();
  }
}
