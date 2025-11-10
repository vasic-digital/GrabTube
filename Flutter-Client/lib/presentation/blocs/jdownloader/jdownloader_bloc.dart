import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/jdownloader_instance.dart';
import '../../../domain/usecases/jdownloader/connect_jdownloader_usecase.dart';
import '../../../domain/usecases/jdownloader/disconnect_jdownloader_usecase.dart';
import '../../../domain/usecases/jdownloader/add_jdownloader_download_usecase.dart';
import '../../../domain/usecases/jdownloader/get_jdownloader_downloads_usecase.dart';
import '../../../domain/usecases/jdownloader/pause_jdownloader_download_usecase.dart';
import '../../../domain/usecases/jdownloader/resume_jdownloader_download_usecase.dart';
import '../../../domain/repositories/jdownloader_repository.dart';
import 'jdownloader_event.dart';
import 'jdownloader_state.dart';

/// BLoC for managing JDownloader functionality
@injectable
class JDownloaderBloc extends Bloc<JDownloaderEvent, JDownloaderState> {
  JDownloaderBloc(
    this._connectJDownloaderUseCase,
    this._disconnectJDownloaderUseCase,
    this._addJDownloaderDownloadUseCase,
    this._getJDownloaderDownloadsUseCase,
    this._pauseJDownloaderDownloadUseCase,
    this._resumeJDownloaderDownloadUseCase,
    this._repository,
  ) : super(const JDownloaderInitial()) {
    on<LoadJDownloaderInstancesEvent>(_onLoadInstances);
    on<LoadJDownloaderInstanceByIdEvent>(_onLoadInstanceById);
    on<AddJDownloaderInstanceEvent>(_onAddInstance);
    on<UpdateJDownloaderInstanceEvent>(_onUpdateInstance);
    on<DeleteJDownloaderInstanceEvent>(_onDeleteInstance);
    on<ConnectJDownloaderInstanceEvent>(_onConnectInstance);
    on<DisconnectJDownloaderInstanceEvent>(_onDisconnectInstance);
    on<PauseJDownloaderInstanceEvent>(_onPauseInstance);
    on<ResumeJDownloaderInstanceEvent>(_onResumeInstance);
    on<AddJDownloaderDownloadEvent>(_onAddDownload);
    on<GetJDownloaderDownloadsEvent>(_onGetDownloads);
    on<PauseJDownloaderDownloadEvent>(_onPauseDownload);
    on<ResumeJDownloaderDownloadEvent>(_onResumeDownload);
    on<RemoveJDownloaderDownloadEvent>(_onRemoveDownload);
    on<GetJDownloaderSpeedHistoryEvent>(_onGetSpeedHistory);
    on<CheckJDownloaderConnectionEvent>(_onCheckConnection);
    on<JDownloaderInstanceUpdatedFromStreamEvent>(_onInstanceUpdatedFromStream);

    // Subscribe to instance updates stream
    _instanceSubscription = _repository.instanceUpdates.listen((instance) {
      add(JDownloaderInstanceUpdatedFromStreamEvent(instance));
    });
  }

  final ConnectJDownloaderUseCase _connectJDownloaderUseCase;
  final DisconnectJDownloaderUseCase _disconnectJDownloaderUseCase;
  final AddJDownloaderDownloadUseCase _addJDownloaderDownloadUseCase;
  final GetJDownloaderDownloadsUseCase _getJDownloaderDownloadsUseCase;
  final PauseJDownloaderDownloadUseCase _pauseJDownloaderDownloadUseCase;
  final ResumeJDownloaderDownloadUseCase _resumeJDownloaderDownloadUseCase;
  final JDownloaderRepository _repository;

  StreamSubscription<JDownloaderInstance>? _instanceSubscription;

  Future<void> _onLoadInstances(
    LoadJDownloaderInstancesEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderInstancesLoading());

    try {
      final instances = await _repository.getInstances();
      emit(JDownloaderInstancesLoaded(instances));
    } catch (e) {
      emit(JDownloaderFailure('Failed to load instances: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInstanceById(
    LoadJDownloaderInstanceByIdEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderInstancesLoading());

    try {
      final instance = await _repository.getInstanceById(event.instanceId);
      if (instance != null) {
        emit(JDownloaderInstanceLoaded(instance));
      } else {
        emit(JDownloaderFailure('Instance not found: ${event.instanceId}'));
      }
    } catch (e) {
      emit(JDownloaderFailure('Failed to load instance: ${e.toString()}'));
    }
  }

  Future<void> _onAddInstance(
    AddJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderInstanceAdding());

    try {
      final instance = await _repository.addInstance(
        name: event.name,
        deviceId: event.deviceId,
        host: event.host,
        port: event.port,
        username: event.username,
        password: event.password,
      );
      emit(JDownloaderInstanceAdded(instance));
      add(const LoadJDownloaderInstancesEvent());
    } catch (e) {
      emit(JDownloaderFailure('Failed to add instance: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateInstance(
    UpdateJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderInstanceUpdating());

    try {
      final instance = await _repository.updateInstance(event.instance);
      emit(JDownloaderInstanceUpdated(instance));
      add(const LoadJDownloaderInstancesEvent());
    } catch (e) {
      emit(JDownloaderFailure('Failed to update instance: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteInstance(
    DeleteJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderInstanceDeleting());

    try {
      await _repository.deleteInstance(event.instanceId);
      emit(JDownloaderInstanceDeleted(event.instanceId));
      add(const LoadJDownloaderInstancesEvent());
    } catch (e) {
      emit(JDownloaderFailure('Failed to delete instance: ${e.toString()}'));
    }
  }

  Future<void> _onConnectInstance(
    ConnectJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(JDownloaderInstanceConnecting(event.instanceId));

    final result = await _connectJDownloaderUseCase(event.instanceId);

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (instance) {
        emit(JDownloaderInstanceConnected(instance));
        add(const LoadJDownloaderInstancesEvent());
      },
    );
  }

  Future<void> _onDisconnectInstance(
    DisconnectJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(JDownloaderInstanceDisconnecting(event.instanceId));

    final result = await _disconnectJDownloaderUseCase(event.instanceId);

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (_) {
        emit(JDownloaderInstanceDisconnected(event.instanceId));
        add(const LoadJDownloaderInstancesEvent());
      },
    );
  }

  Future<void> _onPauseInstance(
    PauseJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    try {
      await _repository.pauseInstance(event.instanceId);
      add(const LoadJDownloaderInstancesEvent());
    } catch (e) {
      emit(JDownloaderFailure('Failed to pause instance: ${e.toString()}'));
    }
  }

  Future<void> _onResumeInstance(
    ResumeJDownloaderInstanceEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    try {
      await _repository.resumeInstance(event.instanceId);
      add(const LoadJDownloaderInstancesEvent());
    } catch (e) {
      emit(JDownloaderFailure('Failed to resume instance: ${e.toString()}'));
    }
  }

  Future<void> _onAddDownload(
    AddJDownloaderDownloadEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderDownloadAdding());

    final result = await _addJDownloaderDownloadUseCase(
      instanceId: event.instanceId,
      url: event.url,
      destinationFolder: event.destinationFolder,
      packageName: event.packageName,
    );

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (_) {
        emit(JDownloaderDownloadAdded(
          instanceId: event.instanceId,
          url: event.url,
        ));
        add(GetJDownloaderDownloadsEvent(event.instanceId));
      },
    );
  }

  Future<void> _onGetDownloads(
    GetJDownloaderDownloadsEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderDownloadsLoading());

    final result = await _getJDownloaderDownloadsUseCase(event.instanceId);

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (downloads) => emit(JDownloaderDownloadsLoaded(
        instanceId: event.instanceId,
        downloads: downloads,
      )),
    );
  }

  Future<void> _onPauseDownload(
    PauseJDownloaderDownloadEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderDownloadOperating());

    final result = await _pauseJDownloaderDownloadUseCase(
      instanceId: event.instanceId,
      downloadId: event.downloadId,
    );

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (_) {
        emit(const JDownloaderDownloadOperated('Download paused'));
        add(GetJDownloaderDownloadsEvent(event.instanceId));
      },
    );
  }

  Future<void> _onResumeDownload(
    ResumeJDownloaderDownloadEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderDownloadOperating());

    final result = await _resumeJDownloaderDownloadUseCase(
      instanceId: event.instanceId,
      downloadId: event.downloadId,
    );

    result.fold(
      (error) => emit(JDownloaderFailure(error)),
      (_) {
        emit(const JDownloaderDownloadOperated('Download resumed'));
        add(GetJDownloaderDownloadsEvent(event.instanceId));
      },
    );
  }

  Future<void> _onRemoveDownload(
    RemoveJDownloaderDownloadEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderDownloadOperating());

    try {
      await _repository.removeDownload(
        instanceId: event.instanceId,
        downloadId: event.downloadId,
      );
      emit(const JDownloaderDownloadOperated('Download removed'));
      add(GetJDownloaderDownloadsEvent(event.instanceId));
    } catch (e) {
      emit(JDownloaderFailure('Failed to remove download: ${e.toString()}'));
    }
  }

  Future<void> _onGetSpeedHistory(
    GetJDownloaderSpeedHistoryEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderSpeedHistoryLoading());

    try {
      final speedHistory = await _repository.getSpeedHistory(
        event.instanceId,
        limit: event.limit,
      );
      emit(JDownloaderSpeedHistoryLoaded(
        instanceId: event.instanceId,
        speedHistory: speedHistory,
      ));
    } catch (e) {
      emit(JDownloaderFailure('Failed to get speed history: ${e.toString()}'));
    }
  }

  Future<void> _onCheckConnection(
    CheckJDownloaderConnectionEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    emit(const JDownloaderConnectionChecking());

    try {
      final isConnected = await _repository.checkConnection(event.instanceId);
      emit(JDownloaderConnectionChecked(
        instanceId: event.instanceId,
        isConnected: isConnected,
      ));
    } catch (e) {
      emit(JDownloaderFailure('Failed to check connection: ${e.toString()}'));
    }
  }

  Future<void> _onInstanceUpdatedFromStream(
    JDownloaderInstanceUpdatedFromStreamEvent event,
    Emitter<JDownloaderState> emit,
  ) async {
    // Reload instances when stream notifies of updates
    add(const LoadJDownloaderInstancesEvent());
  }

  @override
  Future<void> close() {
    _instanceSubscription?.cancel();
    return super.close();
  }
}
