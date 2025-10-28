import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/download.dart';
import '../../../domain/repositories/download_repository.dart';
import 'download_event.dart';
import 'download_state.dart';

@injectable
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc(this._repository) : super(const DownloadInitial()) {
    on<LoadDownloads>(_onLoadDownloads);
    on<AddDownload>(_onAddDownload);
    on<DeleteDownloads>(_onDeleteDownloads);
    on<StartDownloads>(_onStartDownloads);
    on<ClearCompleted>(_onClearCompleted);
    on<RefreshDownloads>(_onRefreshDownloads);
    on<GetVideoInfo>(_onGetVideoInfo);
    on<DownloadUpdated>(_onDownloadUpdated);
    on<DownloadAdded>(_onDownloadAdded);
    on<DownloadCompleted>(_onDownloadCompleted);
    on<DownloadCanceled>(_onDownloadCanceled);
    on<LoadHistory>(_onLoadHistory);
    on<RedownloadFromHistory>(_onRedownloadFromHistory);
    on<ToggleFavorite>(_onToggleFavorite);

    _initializeSocketListeners();
  }

  final DownloadRepository _repository;
  StreamSubscription? _downloadUpdatesSubscription;
  StreamSubscription? _newDownloadsSubscription;
  StreamSubscription? _completedDownloadsSubscription;
  StreamSubscription? _canceledDownloadsSubscription;
  StreamSubscription? _connectionStatusSubscription;

  void _initializeSocketListeners() {
    // Listen to download updates
    _downloadUpdatesSubscription = _repository.downloadUpdates.listen(
      (download) {
        AppLogger.debug('Download updated: ${download.id}');
        add(DownloadUpdated(download.id));
      },
      onError: (error) {
        AppLogger.error('Error in download updates stream', error);
      },
    );

    // Listen to new downloads
    _newDownloadsSubscription = _repository.newDownloads.listen(
      (download) {
        AppLogger.debug('New download: ${download.id}');
        add(const DownloadAdded());
      },
      onError: (error) {
        AppLogger.error('Error in new downloads stream', error);
      },
    );

    // Listen to completed downloads
    _completedDownloadsSubscription = _repository.completedDownloads.listen(
      (download) {
        AppLogger.debug('Download completed: ${download.id}');
        add(DownloadCompleted(download.id));
      },
      onError: (error) {
        AppLogger.error('Error in completed downloads stream', error);
      },
    );

    // Listen to canceled downloads
    _canceledDownloadsSubscription = _repository.canceledDownloads.listen(
      (downloadId) {
        AppLogger.debug('Download canceled: $downloadId');
        add(DownloadCanceled(downloadId));
      },
      onError: (error) {
        AppLogger.error('Error in canceled downloads stream', error);
      },
    );

    // Listen to connection status
    _connectionStatusSubscription = _repository.connectionStatus.listen(
      (isConnected) {
        AppLogger.info('Connection status changed: $isConnected');
        add(const RefreshDownloads());
      },
      onError: (error) {
        AppLogger.error('Error in connection status stream', error);
      },
    );
  }

  Future<void> _onLoadDownloads(
    LoadDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadLoading());

      final queue = await _repository.getQueue();
      final completed = await _repository.getCompleted();
      final pending = await _repository.getPending();

      emit(DownloadsLoaded(
        queue: queue,
        completed: completed,
        pending: pending,
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load downloads', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to load downloads: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onAddDownload(
    AddDownload event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadOperationInProgress(
        message: 'Adding download...',
      ));

      await _repository.addDownload(
        url: event.url,
        quality: event.quality,
        format: event.format,
        folder: event.folder,
        autoStart: event.autoStart,
      );

      emit(const DownloadOperationSuccess(
        message: AppConstants.successDownloadAdded,
      ));

      // Reload downloads
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add download', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to add download: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onDeleteDownloads(
    DeleteDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadOperationInProgress(
        message: 'Deleting downloads...',
      ));

      await _repository.deleteDownload(
        ids: event.ids,
        where: event.where,
      );

      emit(const DownloadOperationSuccess(
        message: 'Downloads deleted successfully',
      ));

      // Reload downloads
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete downloads', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to delete downloads: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onStartDownloads(
    StartDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadOperationInProgress(
        message: 'Starting downloads...',
      ));

      await _repository.startDownload(ids: event.ids);

      emit(const DownloadOperationSuccess(
        message: AppConstants.successDownloadStarted,
      ));

      // Reload downloads
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start downloads', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to start downloads: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onClearCompleted(
    ClearCompleted event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadOperationInProgress(
        message: 'Clearing completed downloads...',
      ));

      await _repository.clearCompleted();

      emit(const DownloadOperationSuccess(
        message: 'Completed downloads cleared',
      ));

      // Reload downloads
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear completed downloads', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to clear completed: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onRefreshDownloads(
    RefreshDownloads event,
    Emitter<DownloadState> emit,
  ) async {
    add(const LoadDownloads());
  }

  Future<void> _onGetVideoInfo(
    GetVideoInfo event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const VideoInfoLoading());

      final videoInfo = await _repository.getVideoInfo(url: event.url);

      emit(VideoInfoLoaded(videoInfo: videoInfo));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get video info', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to get video info: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onDownloadUpdated(
    DownloadUpdated event,
    Emitter<DownloadState> emit,
  ) async {
    // Refresh downloads to get latest state
    add(const LoadDownloads());
  }

  Future<void> _onDownloadAdded(
    DownloadAdded event,
    Emitter<DownloadState> emit,
  ) async {
    // Refresh downloads to include new download
    add(const LoadDownloads());
  }

  Future<void> _onDownloadCompleted(
    DownloadCompleted event,
    Emitter<DownloadState> emit,
  ) async {
    // Refresh downloads to move to completed
    add(const LoadDownloads());
  }

  Future<void> _onDownloadCanceled(
    DownloadCanceled event,
    Emitter<DownloadState> emit,
  ) async {
    // Refresh downloads to reflect cancellation
    add(const LoadDownloads());
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const HistoryLoading());

      final history = await _repository.getHistory();

      emit(HistoryLoaded(history: history));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load history', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to load history: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onRedownloadFromHistory(
    RedownloadFromHistory event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      emit(const DownloadOperationInProgress(
        message: 'Re-downloading from history...',
      ));

      await _repository.redownload(
        url: event.url,
        quality: event.quality,
        format: event.format,
        folder: event.folder,
        autoStart: event.autoStart,
      );

      emit(const DownloadOperationSuccess(
        message: 'Re-download started successfully',
      ));

      // Reload downloads
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to redownload from history', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to redownload: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      await _repository.toggleFavorite(event.downloadId);
      // Reload downloads to reflect the change
      add(const LoadDownloads());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle favorite', e, stackTrace);
      emit(DownloadError(
        message: 'Failed to toggle favorite: ${e.toString()}',
        error: e,
      ));
    }
  }

  Future<void> toggleFavorite(String downloadId) async {
    add(ToggleFavorite(downloadId: downloadId));
  }

  @override
  Future<void> close() {
    _downloadUpdatesSubscription?.cancel();
    _newDownloadsSubscription?.cancel();
    _completedDownloadsSubscription?.cancel();
    _canceledDownloadsSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    return super.close();
  }
}
