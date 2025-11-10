import '../entities/schedule.dart';
import '../entities/scheduled_download.dart';

/// Repository interface for schedule operations
abstract class ScheduleRepository {
  /// Create a new schedule
  Future<Schedule> createSchedule(Schedule schedule);

  /// Update an existing schedule
  Future<Schedule> updateSchedule(Schedule schedule);

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId);

  /// Get schedule by ID
  Future<Schedule?> getScheduleById(String scheduleId);

  /// Get all schedules
  Future<List<Schedule>> getAllSchedules();

  /// Get active schedules
  Future<List<Schedule>> getActiveSchedules();

  /// Get schedules by type
  Future<List<Schedule>> getSchedulesByType(ScheduleType type);

  /// Enable/disable a schedule
  Future<void> toggleSchedule(String scheduleId, bool isActive);

  /// Get schedules that should execute now
  Future<List<Schedule>> getSchedulesToExecute();

  /// Mark schedule as executed
  Future<void> markScheduleExecuted(
    String scheduleId,
    DateTime executedAt,
  );

  /// Create a scheduled download instance
  Future<ScheduledDownload> createScheduledDownload(
    ScheduledDownload scheduledDownload,
  );

  /// Update scheduled download status
  Future<void> updateScheduledDownload(ScheduledDownload scheduledDownload);

  /// Get scheduled downloads for a schedule
  Future<List<ScheduledDownload>> getScheduledDownloads(String scheduleId);

  /// Get all scheduled downloads
  Future<List<ScheduledDownload>> getAllScheduledDownloads();

  /// Get pending scheduled downloads
  Future<List<ScheduledDownload>> getPendingScheduledDownloads();

  /// Get completed scheduled downloads
  Future<List<ScheduledDownload>> getCompletedScheduledDownloads();

  /// Delete scheduled download
  Future<void> deleteScheduledDownload(String scheduledDownloadId);

  /// Stream of schedule updates
  Stream<Schedule> get scheduleUpdates;

  /// Stream of scheduled download updates
  Stream<ScheduledDownload> get scheduledDownloadUpdates;
}
