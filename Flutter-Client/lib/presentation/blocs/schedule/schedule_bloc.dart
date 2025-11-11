import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/download_schedule.dart';
import '../../../domain/usecases/schedule/get_schedules_usecase.dart';
import '../../../domain/usecases/schedule/create_schedule_usecase.dart';
import '../../../domain/usecases/schedule/delete_schedule_usecase.dart';
import '../../../domain/usecases/schedule/execute_schedule_usecase.dart';
import '../../../domain/repositories/schedule_repository.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

@injectable
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(
    this._getSchedulesUseCase,
    this._createScheduleUseCase,
    this._deleteScheduleUseCase,
    this._executeScheduleUseCase,
    this._repository,
  ) : super(const ScheduleInitial()) {
    on<LoadSchedulesEvent>(_onLoadSchedules);
    on<LoadPendingSchedulesEvent>(_onLoadPendingSchedules);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
    on<CancelScheduleEvent>(_onCancelSchedule);
    on<ExecuteScheduleEvent>(_onExecuteSchedule);
    on<SchedulesUpdatedEvent>(_onSchedulesUpdated);

    _schedulesSubscription = _repository.scheduleUpdates.listen((schedules) {
      add(const SchedulesUpdatedEvent());
    });
  }

  final GetSchedulesUseCase _getSchedulesUseCase;
  final CreateScheduleUseCase _createScheduleUseCase;
  final DeleteScheduleUseCase _deleteScheduleUseCase;
  final ExecuteScheduleUseCase _executeScheduleUseCase;
  final ScheduleRepository _repository;

  StreamSubscription<List<DownloadSchedule>>? _schedulesSubscription;

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

  Future<void> _onLoadPendingSchedules(
    LoadPendingSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const SchedulesLoading());

    try {
      final schedules = await _repository.getPendingSchedules();
      emit(SchedulesLoaded(schedules));
    } catch (e) {
      emit(ScheduleFailure(e.toString()));
    }
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
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
    try {
      await _repository.updateSchedule(event.schedule);
      emit(ScheduleUpdated(event.schedule));
      add(const LoadSchedulesEvent());
    } catch (e) {
      emit(ScheduleFailure(e.toString()));
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final result = await _deleteScheduleUseCase(event.scheduleId);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (_) {
        emit(ScheduleDeleted(event.scheduleId));
        add(const LoadSchedulesEvent());
      },
    );
  }

  Future<void> _onCancelSchedule(
    CancelScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _repository.cancelSchedule(event.scheduleId);
      add(const LoadSchedulesEvent());
    } catch (e) {
      emit(ScheduleFailure(e.toString()));
    }
  }

  Future<void> _onExecuteSchedule(
    ExecuteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleExecuting(event.scheduleId));

    final result = await _executeScheduleUseCase(event.scheduleId);

    result.fold(
      (error) => emit(ScheduleFailure(error)),
      (_) {
        emit(ScheduleExecuted(event.scheduleId));
        add(const LoadSchedulesEvent());
      },
    );
  }

  Future<void> _onSchedulesUpdated(
    SchedulesUpdatedEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    add(const LoadSchedulesEvent());
  }

  @override
  Future<void> close() {
    _schedulesSubscription?.cancel();
    return super.close();
  }
}
