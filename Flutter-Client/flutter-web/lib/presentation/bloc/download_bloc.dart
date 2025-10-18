import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/download.dart';
import '../../domain/repositories/download_repository.dart';
import '../../data/repositories/download_repository_impl.dart';
import 'download_event.dart';
import 'download_state.dart';

/// BLoC for managing download state
@injectable
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository _repository;
  StreamSubscription? _updateSubscription;
  StreamSubscription? _addedSubscription;
  StreamSubscription? _deletedSubscription;
  StreamSubscription? _clearedSubscription;
  StreamSubscription? _connectionSubscription;

  DownloadBloc(this._repository) : super(const DownloadInitial()) {
    // Register event handlers
    on<LoadDownloads>(_onLoadDownloads);
    on<RefreshDownloads>(_onRefreshDownloads);
    on<AddDownload>(_onAddDownload);
    on<StartDownload>(_onStartDownload);
    on<CancelDownload>(_onCancelDownload);
    on<DeleteDownload>(_onDeleteDownload);
    on<ClearCompleted>(_onClearCompleted);
    on<DownloadUpdated>(_onDownloadUpdated);
    on<DownloadAdded>(_onDownloadAdded);
    on<DownloadDeleted>(_onDownloadDeleted);
    on<DownloadsCleared>(_onDownloadsCleared);
    on<ConnectionStatusChanged>(_onConnectionStatusChanged);

    // Start listening to WebSocket events
    _subscribeToWebSocket();

    // Initial load
    add(const LoadDownloads());
  }

  /// Subscribe to WebSocket events
  void _subscribeToWebSocket() {
    _updateSubscription = _repository.watchDownloadUpdates().listen(
      (download) {
        AppLogger.debug('WebSocket update received for: ${download.id}');
        add(DownloadUpdated(id: download.id, data: _downloadToMap(download)));
      },
      onError: (error) {
        AppLogger.error('WebSocket update error', error: error);
      },
    );

    _addedSubscription = _repository.watchDownloadAdditions().listen(
      (download) {
        AppLogger.info('WebSocket addition received: ${download.id}');
        add(DownloadAdded(_downloadToMap(download)));
      },
      onError: (error) {
        AppLogger.error('WebSocket addition error', error: error);
      },
    );

    _deletedSubscription = _repository.watchDownloadDeletions().listen(
      (id) {
        AppLogger.info('WebSocket deletion received: $id');
        add(DownloadDeleted(id));
      },
      onError: (error) {
        AppLogger.error('WebSocket deletion error', error: error);
      },
    );

    _clearedSubscription = _repository.watchClearedEvents().listen(
      (_) {
        AppLogger.info('WebSocket cleared event received');
        add(const DownloadsCleared());
      },
      onError: (error) {
        AppLogger.error('WebSocket cleared error', error: error);
      },
    );

    // Listen to connection status if repository supports it
    if (_repository is DownloadRepositoryImpl) {
      final repo = _repository as DownloadRepositoryImpl;
      _connectionSubscription = repo.connectionStatus.listen(
        (isConnected) {
          AppLogger.info('Connection status changed: $isConnected');
          add(ConnectionStatusChanged(isConnected));
        },
      );
    }
  }

  /// Convert Download entity to Map for events
  Map<String, dynamic> _downloadToMap(Download download) {
    return {
      'id': download.id,
      'url': download.url,
      'title': download.title,
      'status': download.status.name,
      'progress': download.progress,
      'speed': download.speed,
      'eta': download.eta,
      'downloadedBytes': download.downloadedBytes,
      'totalBytes': download.totalBytes,
      'quality': download.quality,
      'format': download.format,
      'folder': download.folder,
      'thumbnail': download.thumbnail,
      'duration': download.duration,
      'error': download.error,
      'addedAt': download.addedAt.toIso8601String(),
      'completedAt': download.completedAt?.toIso8601String(),
    };
  }

  /// Load all downloads
  Future<void> _onLoadDownloads(
    LoadDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadLoading());

      final results = await Future.wait([
        _repository.getActiveDownloads(),
        _repository.getCompletedDownloads(),
        _repository.getPendingDownloads(),
      ]);

      final isConnected = _repository is DownloadRepositoryImpl
          ? (_repository as DownloadRepositoryImpl).isConnected
          : false;

      emit(DownloadLoaded(
        activeDownloads: results[0],
        completedDownloads: results[1],
        pendingDownloads: results[2],
        isConnected: isConnected,
      ));
    } catch (e) {
      AppLogger.error('Error loading downloads', error: e);
      emit(DownloadError(e.toString()));
    }
  }

  /// Refresh downloads
  Future<void> _onRefreshDownloads(
    RefreshDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _repository.getActiveDownloads(),
        _repository.getCompletedDownloads(),
        _repository.getPendingDownloads(),
      ]);

      if (state is DownloadLoaded) {
        final currentState = state as DownloadLoaded;
        emit(currentState.copyWith(
          activeDownloads: results[0],
          completedDownloads: results[1],
          pendingDownloads: results[2],
          message: 'Downloads refreshed',
        ));
      }
    } catch (e) {
      AppLogger.error('Error refreshing downloads', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError(e.toString(), previousState: state as DownloadLoaded));
      }
    }
  }

  /// Add a new download
  Future<void> _onAddDownload(
    AddDownload event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.addDownload(
        url: event.url,
        quality: event.quality,
        format: event.format,
        folder: event.folder,
        autoStart: event.autoStart,
      );

      // Refresh to get the new download
      add(const RefreshDownloads());
    } catch (e) {
      AppLogger.error('Error adding download', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError('Failed to add download: $e',
            previousState: state as DownloadLoaded));
      }
    }
  }

  /// Start a pending download
  Future<void> _onStartDownload(
    StartDownload event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.startDownload(event.id);
      add(const RefreshDownloads());
    } catch (e) {
      AppLogger.error('Error starting download', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError('Failed to start download: $e',
            previousState: state as DownloadLoaded));
      }
    }
  }

  /// Cancel an active download
  Future<void> _onCancelDownload(
    CancelDownload event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.cancelDownload(event.id);
      add(const RefreshDownloads());
    } catch (e) {
      AppLogger.error('Error canceling download', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError('Failed to cancel download: $e',
            previousState: state as DownloadLoaded));
      }
    }
  }

  /// Delete a download
  Future<void> _onDeleteDownload(
    DeleteDownload event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.deleteDownload(event.id);
      add(const RefreshDownloads());
    } catch (e) {
      AppLogger.error('Error deleting download', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError('Failed to delete download: $e',
            previousState: state as DownloadLoaded));
      }
    }
  }

  /// Clear all completed downloads
  Future<void> _onClearCompleted(
    ClearCompleted event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.clearCompleted();
      if (state is DownloadLoaded) {
        final currentState = state as DownloadLoaded;
        emit(currentState.copyWith(
          completedDownloads: [],
          message: 'Completed downloads cleared',
        ));
      }
    } catch (e) {
      AppLogger.error('Error clearing completed', error: e);
      if (state is DownloadLoaded) {
        emit(DownloadError('Failed to clear completed: $e',
            previousState: state as DownloadLoaded));
      }
    }
  }

  /// Handle download update from WebSocket
  void _onDownloadUpdated(
    DownloadUpdated event,
    Emitter<DownloadState> emit,
  ) {
    if (state is DownloadLoaded) {
      // Refresh to get latest data
      add(const RefreshDownloads());
    }
  }

  /// Handle download added from WebSocket
  void _onDownloadAdded(
    DownloadAdded event,
    Emitter<DownloadState> emit,
  ) {
    if (state is DownloadLoaded) {
      add(const RefreshDownloads());
    }
  }

  /// Handle download deleted from WebSocket
  void _onDownloadDeleted(
    DownloadDeleted event,
    Emitter<DownloadState> emit,
  ) {
    if (state is DownloadLoaded) {
      add(const RefreshDownloads());
    }
  }

  /// Handle downloads cleared from WebSocket
  void _onDownloadsCleared(
    DownloadsCleared event,
    Emitter<DownloadState> emit,
  ) {
    if (state is DownloadLoaded) {
      final currentState = state as DownloadLoaded;
      emit(currentState.copyWith(
        completedDownloads: [],
        message: 'Downloads cleared',
      ));
    }
  }

  /// Handle connection status change
  void _onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<DownloadState> emit,
  ) {
    if (state is DownloadLoaded) {
      final currentState = state as DownloadLoaded;
      emit(currentState.copyWith(isConnected: event.isConnected));
    }
  }

  @override
  Future<void> close() {
    _updateSubscription?.cancel();
    _addedSubscription?.cancel();
    _deletedSubscription?.cancel();
    _clearedSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}
