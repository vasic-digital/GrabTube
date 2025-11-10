import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/schedule.dart';
import '../../../domain/entities/scheduled_download.dart';
import '../../../domain/usecases/schedule/create_schedule_usecase.dart';
import '../../../domain/usecases/schedule/update_schedule_usecase.dart';
import '../../../domain/usecases/schedule/delete_schedule_usecase.dart';
import '../../../domain/usecases/schedule/get_schedules_usecase.dart';
import '../../../domain/usecases/schedule/get_schedule_by_id_usecase.dart';
import '../../../domain/repositories/schedule_repository.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

/// BLoC for managing schedule functionality
@injectable
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(
    this._createScheduleUseCase,
    this._updateScheduleUseCase,
    this._deleteScheduleUseCase,
    this._getSchedulesUseCase,
    this._getScheduleByIdUseCase,
    this._repository,
  ) : super(const ScheduleInitial()) {
    on<LoadSchedulesEvent>(_onLoadSchedules);
    on<LoadScheduleByIdEvent>(_onLoadScheduleById);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
    on<ToggleScheduleEvent>(_onToggleSchedule);
    on<LoadSchedulesByTypeEvent>(_onLoadSchedulesByType);
    on<LoadActiveSchedulesEvent>(_onLoadActiveSchedules);
    on<LoadSchedulesToExecuteEvent>(_onLoadSchedulesToExecute);
    on<MarkScheduleExecutedEvent>(_onMarkScheduleExecuted);
    on<CreateScheduledDownloadEvent>(_onCreateScheduledDownload);
    on<UpdateScheduledDownloadEvent>(_onUpdateScheduledDownload);
    on<LoadScheduledDownloadsEvent>(_onLoadScheduledDownloads);
    on<LoadAllScheduledDownloadsEvent>(_onLoadAllScheduledDownloads);
    on<LoadPendingScheduledDownloadsEvent>(_onLoadPendingScheduledDownloads);
    on<LoadCompletedScheduledDownloadsEvent>(_onLoadCompletedScheduledDownloads);
    on<DeleteScheduledDownloadEvent>(_onDeleteScheduledDownload);
    on<ScheduleUpdatedFromStreamEvent>(_onScheduleUpdatedFromStream);
    on<ScheduledDownloadUpdatedFromStreamEvent>(_onScheduledDownloadUpdatedFromStream);

    // Subscribe to streams
    _scheduleSubscription = _repository.scheduleUpdates.listen((schedule) {
      add(ScheduleUpdatedFromStreamEvent(schedule));
    });

    _scheduledDownloadSubscription = _repository.scheduledDownloadUpdates.listen(
      (scheduledDownload) {
        add(ScheduledDownloadUpdatedFromStreamEvent(scheduledDownload));
      },
    );
  }

  final CreateScheduleUseCase _createScheduleUseCase;
  final UpdateScheduleUseCase _updateScheduleUseCase;
  final DeleteScheduleUseCase _deleteScheduleUseCase;
  final GetSchedulesUseCase _getSchedulesUseCase;
  final GetScheduleByIdUseCase _getScheduleByIdUseCase;
  final ScheduleRepository _repository;

  StreamSubscription<Schedule>? _scheduleSubscription;
  StreamSubscription<ScheduledDownload>? _scheduledDownloadSubscription;

  Future<void> _onLoadSchedules(
    LoadSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    final result = await _getSchedulesUseCase();

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (schedules) => emit(SchedulesLoaded(schedules)),
    );
  }

  Future<void> _onLoadScheduleById(
    LoadScheduleByIdEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    final result = await _getScheduleByIdUseCase(event.scheduleId);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (schedule) {
        if (schedule != null) {
          emit(ScheduleLoaded(schedule));
        } else {
          emit(ScheduleFailure('Schedule not found: ${event.scheduleId}'));
        }
      },
    );
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleCreating());

    final result = await _createScheduleUseCase(event.schedule);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (schedule) {
        emit(ScheduleCreated(schedule));
        add(const LoadSchedulesEvent());
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleUpdating());

    final result = await _updateScheduleUseCase(event.schedule);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (schedule) {
        emit(ScheduleUpdated(schedule));
        add(const LoadSchedulesEvent());
      },
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleDeleting());

    final result = await _deleteScheduleUseCase(event.scheduleId);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (_) {
        emit(ScheduleDeleted(event.scheduleId));
        add(const LoadSchedulesEvent());
      },
    );
  }

  Future<void> _onToggleSchedule(
    ToggleScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      final schedule = await _repository.getScheduleById(event.scheduleId);
      if (schedule == null) {
        emit(ScheduleFailure('Schedule not found: ${event.scheduleId}'));
        return;
      }

      await _repository.toggleSchedule(event.scheduleId, !schedule.isActive);
      add(const LoadSchedulesEvent());
    } catch (e) {
      emit(ScheduleFailure('Failed to toggle schedule: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSchedulesByType(
    LoadSchedulesByTypeEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    try {
      final schedules = await _repository.getSchedulesByType(event.type);
      emit(SchedulesByTypeLoaded(schedules: schedules, type: event.type));
    } catch (e) {
      emit(ScheduleFailure('Failed to load schedules: ${e.toString()}'));
    }
  }

  Future<void> _onLoadActiveSchedules(
    LoadActiveSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    try {
      final schedules = await _repository.getActiveSchedules();
      emit(ActiveSchedulesLoaded(schedules));
    } catch (e) {
      emit(ScheduleFailure('Failed to load active schedules: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSchedulesToExecute(
    LoadSchedulesToExecuteEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    try {
      final schedules = await _repository.getSchedulesToExecute();
      emit(SchedulesToExecuteLoaded(schedules));
    } catch (e) {
      emit(ScheduleFailure('Failed to load schedules to execute: ${e.toString()}'));
    }
  }

  Future<void> _onMarkScheduleExecuted(
    MarkScheduleExecutedEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.markScheduleExecuted(
        event.scheduleId,
        event.executedAt,
      );
      add(LoadScheduleByIdEvent(event.scheduleId));
    } catch (e) {
      emit(ScheduleFailure('Failed to mark schedule executed: ${e.toString()}'));
    }
  }

  Future<void> _onCreateScheduledDownload(
    CreateScheduledDownloadEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduledDownloadCreating());

    try {
      final scheduledDownload = await _repository.createScheduledDownload(
        event.scheduledDownload,
      );
      emit(ScheduledDownloadCreated(scheduledDownload));
    } catch (e) {
      emit(ScheduleFailure('Failed to create scheduled download: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateScheduledDownload(
    UpdateScheduledDownloadEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.updateScheduledDownload(event.scheduledDownload);
      emit(ScheduledDownloadUpdated(event.scheduledDownload));
    } catch (e) {
      emit(ScheduleFailure('Failed to update scheduled download: ${e.toString()}'));
    }
  }

  Future<void> _onLoadScheduledDownloads(
    LoadScheduledDownloadsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduledDownloadsLoading());

    try {
      final scheduledDownloads = await _repository.getScheduledDownloads(
        event.scheduleId,
      );
      emit(ScheduledDownloadsLoaded(scheduledDownloads));
    } catch (e) {
      emit(ScheduleFailure('Failed to load scheduled downloads: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllScheduledDownloads(
    LoadAllScheduledDownloadsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduledDownloadsLoading());

    try {
      final scheduledDownloads = await _repository.getAllScheduledDownloads();
      emit(ScheduledDownloadsLoaded(scheduledDownloads));
    } catch (e) {
      emit(ScheduleFailure('Failed to load all scheduled downloads: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPendingScheduledDownloads(
    LoadPendingScheduledDownloadsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduledDownloadsLoading());

    try {
      final scheduledDownloads = await _repository.getPendingScheduledDownloads();
      emit(PendingScheduledDownloadsLoaded(scheduledDownloads));
    } catch (e) {
      emit(ScheduleFailure('Failed to load pending scheduled downloads: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCompletedScheduledDownloads(
    LoadCompletedScheduledDownloadsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduledDownloadsLoading());

    try {
      final scheduledDownloads = await _repository.getCompletedScheduledDownloads();
      emit(CompletedScheduledDownloadsLoaded(scheduledDownloads));
    } catch (e) {
      emit(ScheduleFailure('Failed to load completed scheduled downloads: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteScheduledDownload(
    DeleteScheduledDownloadEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.deleteScheduledDownload(event.scheduledDownloadId);
      emit(ScheduledDownloadDeleted(event.scheduledDownloadId));
      add(const LoadAllScheduledDownloadsEvent());
    } catch (e) {
      emit(ScheduleFailure('Failed to delete scheduled download: ${e.toString()}'));
    }
  }

  Future<void> _onScheduleUpdatedFromStream(
    ScheduleUpdatedFromStreamEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Reload schedules when stream notifies of updates
    add(const LoadSchedulesEvent());
  }

  Future<void> _onScheduledDownloadUpdatedFromStream(
    ScheduledDownloadUpdatedFromStreamEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Reload scheduled downloads when stream notifies of updates
    add(const LoadAllScheduledDownloadsEvent());
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    _scheduledDownloadSubscription?.cancel();
    return super.close();
  }
}
