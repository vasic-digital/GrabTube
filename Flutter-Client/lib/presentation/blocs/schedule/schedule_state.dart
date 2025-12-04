import 'package:equatable/equatable.dart';
import '../../../domain/entities/download_schedule.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class SchedulesLoading extends ScheduleState {
  const SchedulesLoading();
}

class SchedulesLoaded extends ScheduleState {
  const SchedulesLoaded(this.schedules);
  final List<DownloadSchedule> schedules;
  @override
  List<Object?> get props => [schedules];
}

class ScheduleCreated extends ScheduleState {
  const ScheduleCreated(this.schedule);
  final DownloadSchedule schedule;
  @override
  List<Object?> get props => [schedule];
}

class ScheduleUpdated extends ScheduleState {
  const ScheduleUpdated(this.schedule);
  final DownloadSchedule schedule;
  @override
  List<Object?> get props => [schedule];
}

class ScheduleDeleted extends ScheduleState {
  const ScheduleDeleted(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleExecuting extends ScheduleState {
  const ScheduleExecuting(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleExecuted extends ScheduleState {
  const ScheduleExecuted(this.scheduleId);
  final String scheduleId;
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleError extends ScheduleState {
  const ScheduleError(this.error);
  final String error;
  @override
  List<Object?> get props => [error];
}

class ScheduleOperationInProgress extends ScheduleState {
  const ScheduleOperationInProgress();
}

class ScheduleOperationSuccess extends ScheduleState {
  const ScheduleOperationSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
