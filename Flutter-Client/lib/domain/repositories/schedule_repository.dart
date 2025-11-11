import '../entities/download_schedule.dart';

/// Repository interface for schedule operations
abstract class ScheduleRepository {
  /// Get all schedules
  Future<List<DownloadSchedule>> getSchedules();

  /// Get schedule by ID
  Future<DownloadSchedule?> getSchedule(String id);

  /// Get pending schedules
  Future<List<DownloadSchedule>> getPendingSchedules();

  /// Get due schedules (ready to execute)
  Future<List<DownloadSchedule>> getDueSchedules();

  /// Create a new schedule
  Future<DownloadSchedule> createSchedule(DownloadSchedule schedule);

  /// Update schedule
  Future<void> updateSchedule(DownloadSchedule schedule);

  /// Delete schedule
  Future<void> deleteSchedule(String id);

  /// Cancel schedule
  Future<void> cancelSchedule(String id);

  /// Execute schedule (manually trigger)
  Future<void> executeSchedule(String id);

  /// Stream of schedule updates
  Stream<List<DownloadSchedule>> get scheduleUpdates;
}
