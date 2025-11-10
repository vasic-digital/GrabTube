import 'package:equatable/equatable.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/scheduled_download.dart';

/// Base class for Schedule events
abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all schedules
class LoadSchedulesEvent extends ScheduleEvent {
  const LoadSchedulesEvent();
}

/// Event to load a specific schedule by ID
class LoadScheduleByIdEvent extends ScheduleEvent {
  const LoadScheduleByIdEvent(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// Event to create a new schedule
class CreateScheduleEvent extends ScheduleEvent {
  const CreateScheduleEvent(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// Event to update an existing schedule
class UpdateScheduleEvent extends ScheduleEvent {
  const UpdateScheduleEvent(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// Event to delete a schedule
class DeleteScheduleEvent extends ScheduleEvent {
  const DeleteScheduleEvent(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// Event to toggle schedule active/inactive
class ToggleScheduleEvent extends ScheduleEvent {
  const ToggleScheduleEvent(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// Event to get schedules by type
class LoadSchedulesByTypeEvent extends ScheduleEvent {
  const LoadSchedulesByTypeEvent(this.type);

  final ScheduleType type;

  @override
  List<Object?> get props => [type];
}

/// Event to get active schedules
class LoadActiveSchedulesEvent extends ScheduleEvent {
  const LoadActiveSchedulesEvent();
}

/// Event to get schedules that should execute
class LoadSchedulesToExecuteEvent extends ScheduleEvent {
  const LoadSchedulesToExecuteEvent();
}

/// Event to mark schedule as executed
class MarkScheduleExecutedEvent extends ScheduleEvent {
  const MarkScheduleExecutedEvent({
    required this.scheduleId,
    required this.executedAt,
  });

  final String scheduleId;
  final DateTime executedAt;

  @override
  List<Object?> get props => [scheduleId, executedAt];
}

/// Event to create a scheduled download
class CreateScheduledDownloadEvent extends ScheduleEvent {
  const CreateScheduledDownloadEvent(this.scheduledDownload);

  final ScheduledDownload scheduledDownload;

  @override
  List<Object?> get props => [scheduledDownload];
}

/// Event to update scheduled download status
class UpdateScheduledDownloadEvent extends ScheduleEvent {
  const UpdateScheduledDownloadEvent(this.scheduledDownload);

  final ScheduledDownload scheduledDownload;

  @override
  List<Object?> get props => [scheduledDownload];
}

/// Event to load scheduled downloads for a schedule
class LoadScheduledDownloadsEvent extends ScheduleEvent {
  const LoadScheduledDownloadsEvent(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// Event to load all scheduled downloads
class LoadAllScheduledDownloadsEvent extends ScheduleEvent {
  const LoadAllScheduledDownloadsEvent();
}

/// Event to load pending scheduled downloads
class LoadPendingScheduledDownloadsEvent extends ScheduleEvent {
  const LoadPendingScheduledDownloadsEvent();
}

/// Event to load completed scheduled downloads
class LoadCompletedScheduledDownloadsEvent extends ScheduleEvent {
  const LoadCompletedScheduledDownloadsEvent();
}

/// Event to delete a scheduled download
class DeleteScheduledDownloadEvent extends ScheduleEvent {
  const DeleteScheduledDownloadEvent(this.scheduledDownloadId);

  final String scheduledDownloadId;

  @override
  List<Object?> get props => [scheduledDownloadId];
}

/// Event when schedule is updated from stream
class ScheduleUpdatedFromStreamEvent extends ScheduleEvent {
  const ScheduleUpdatedFromStreamEvent(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// Event when scheduled download is updated from stream
class ScheduledDownloadUpdatedFromStreamEvent extends ScheduleEvent {
  const ScheduledDownloadUpdatedFromStreamEvent(this.scheduledDownload);

  final ScheduledDownload scheduledDownload;

  @override
  List<Object?> get props => [scheduledDownload];
}
