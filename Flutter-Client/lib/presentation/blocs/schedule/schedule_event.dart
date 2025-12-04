import 'package:equatable/equatable.dart';
import '../../../domain/entities/download_schedule.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();
  @override
  List<Object?> get props => [];
}

class LoadSchedulesEvent extends ScheduleEvent {
  const LoadSchedulesEvent();
}

class LoadPendingSchedulesEvent extends ScheduleEvent {
  const LoadPendingSchedulesEvent();
}

class CreateScheduleEvent extends ScheduleEvent {
  const CreateScheduleEvent(this.schedule);
  final DownloadSchedule schedule;
  @override
  List<Object?> get props => [schedule];
}

class UpdateScheduleEvent extends ScheduleEvent {
  const UpdateScheduleEvent(this.schedule);
  final DownloadSchedule schedule;
  @override
  List<Object?> get props => [schedule];
}

class DeleteScheduleEvent extends ScheduleEvent {
  const DeleteScheduleEvent(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class CancelScheduleEvent extends ScheduleEvent {
  const CancelScheduleEvent(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class ExecuteScheduleEvent extends ScheduleEvent {
  const ExecuteScheduleEvent(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class SchedulesUpdatedEvent extends ScheduleEvent {
  const SchedulesUpdatedEvent();
}

class RefreshSchedulesEvent extends ScheduleEvent {
  const RefreshSchedulesEvent();
}

class ToggleScheduleEvent extends ScheduleEvent {
  const ToggleScheduleEvent(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}
