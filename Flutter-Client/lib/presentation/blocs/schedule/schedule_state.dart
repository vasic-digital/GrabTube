import 'package:equatable/equatable.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/scheduled_download.dart';

/// Base class for Schedule states
abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

/// State when schedules are being loaded
class SchedulesLoading extends ScheduleState {
  const SchedulesLoading();
}

/// State when schedules are loaded successfully
class SchedulesLoaded extends ScheduleState {
  const SchedulesLoaded(this.schedules);

  final List<Schedule> schedules;

  @override
  List<Object?> get props => [schedules];
}

/// State when a single schedule is loaded
class ScheduleLoaded extends ScheduleState {
  const ScheduleLoaded(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// State when schedule operation fails
class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// State when creating a schedule
class ScheduleCreating extends ScheduleState {
  const ScheduleCreating();
}

/// State when a schedule is created successfully
class ScheduleCreated extends ScheduleState {
  const ScheduleCreated(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// State when updating a schedule
class ScheduleUpdating extends ScheduleState {
  const ScheduleUpdating();
}

/// State when a schedule is updated successfully
class ScheduleUpdated extends ScheduleState {
  const ScheduleUpdated(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// State when deleting a schedule
class ScheduleDeleting extends ScheduleState {
  const ScheduleDeleting();
}

/// State when a schedule is deleted successfully
class ScheduleDeleted extends ScheduleState {
  const ScheduleDeleted(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// State when active schedules are loaded
class ActiveSchedulesLoaded extends ScheduleState {
  const ActiveSchedulesLoaded(this.schedules);

  final List<Schedule> schedules;

  @override
  List<Object?> get props => [schedules];
}

/// State when schedules to execute are loaded
class SchedulesToExecuteLoaded extends ScheduleState {
  const SchedulesToExecuteLoaded(this.schedules);

  final List<Schedule> schedules;

  @override
  List<Object?> get props => [schedules];
}

/// State when schedules by type are loaded
class SchedulesByTypeLoaded extends ScheduleState {
  const SchedulesByTypeLoaded({
    required this.schedules,
    required this.type,
  });

  final List<Schedule> schedules;
  final ScheduleType type;

  @override
  List<Object?> get props => [schedules, type];
}

/// State when scheduled downloads are being loaded
class ScheduledDownloadsLoading extends ScheduleState {
  const ScheduledDownloadsLoading();
}

/// State when scheduled downloads are loaded
class ScheduledDownloadsLoaded extends ScheduleState {
  const ScheduledDownloadsLoaded(this.scheduledDownloads);

  final List<ScheduledDownload> scheduledDownloads;

  @override
  List<Object?> get props => [scheduledDownloads];
}

/// State when creating a scheduled download
class ScheduledDownloadCreating extends ScheduleState {
  const ScheduledDownloadCreating();
}

/// State when a scheduled download is created
class ScheduledDownloadCreated extends ScheduleState {
  const ScheduledDownloadCreated(this.scheduledDownload);

  final ScheduledDownload scheduledDownload;

  @override
  List<Object?> get props => [scheduledDownload];
}

/// State when a scheduled download is updated
class ScheduledDownloadUpdated extends ScheduleState {
  const ScheduledDownloadUpdated(this.scheduledDownload);

  final ScheduledDownload scheduledDownload;

  @override
  List<Object?> get props => [scheduledDownload];
}

/// State when a scheduled download is deleted
class ScheduledDownloadDeleted extends ScheduleState {
  const ScheduledDownloadDeleted(this.scheduledDownloadId);

  final String scheduledDownloadId;

  @override
  List<Object?> get props => [scheduledDownloadId];
}

/// State when pending scheduled downloads are loaded
class PendingScheduledDownloadsLoaded extends ScheduleState {
  const PendingScheduledDownloadsLoaded(this.scheduledDownloads);

  final List<ScheduledDownload> scheduledDownloads;

  @override
  List<Object?> get props => [scheduledDownloads];
}

/// State when completed scheduled downloads are loaded
class CompletedScheduledDownloadsLoaded extends ScheduleState {
  const CompletedScheduledDownloadsLoaded(this.scheduledDownloads);

  final List<ScheduledDownload> scheduledDownloads;

  @override
  List<Object?> get props => [scheduledDownloads];
}
