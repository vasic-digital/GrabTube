import 'package:equatable/equatable.dart';

import '../../../domain/entities/download.dart';
import '../../../domain/entities/video_info.dart';

/// Base class for download states
abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DownloadInitial extends DownloadState {
  const DownloadInitial();
}

/// Loading state
class DownloadLoading extends DownloadState {
  const DownloadLoading();
}

/// Downloads loaded successfully
class DownloadsLoaded extends DownloadState {
  const DownloadsLoaded({
    required this.queue,
    required this.completed,
    required this.pending,
    this.isConnected = false,
  });

  final List<Download> queue;
  final List<Download> completed;
  final List<Download> pending;
  final bool isConnected;

  /// Get all downloads
  List<Download> get allDownloads => [...queue, ...completed, ...pending];

  /// Get active downloads count
  int get activeCount => queue.where((d) => d.isActive).length;

  /// Get pending downloads count
  int get pendingCount => pending.length;

  /// Get completed downloads count
  int get completedCount => completed.length;

  DownloadsLoaded copyWith({
    List<Download>? queue,
    List<Download>? completed,
    List<Download>? pending,
    bool? isConnected,
  }) {
    return DownloadsLoaded(
      queue: queue ?? this.queue,
      completed: completed ?? this.completed,
      pending: pending ?? this.pending,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [queue, completed, pending, isConnected];
}

/// Download operation in progress
class DownloadOperationInProgress extends DownloadState {
  const DownloadOperationInProgress({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Download operation successful
class DownloadOperationSuccess extends DownloadState {
  const DownloadOperationSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Download error
class DownloadError extends DownloadState {
  const DownloadError({required this.message, this.error});

  final String message;
  final dynamic error;

  @override
  List<Object?> get props => [message, error];
}

/// Video info loaded
class VideoInfoLoaded extends DownloadState {
  const VideoInfoLoaded({required this.videoInfo});

  final VideoInfo videoInfo;

  @override
  List<Object?> get props => [videoInfo];
}

/// Video info loading
class VideoInfoLoading extends DownloadState {
  const VideoInfoLoading();
}

/// History loaded successfully
class HistoryLoaded extends DownloadState {
  const HistoryLoaded({required this.history});

  final List<Download> history;

  @override
  List<Object?> get props => [history];
}

/// History loading
class HistoryLoading extends DownloadState {
  const HistoryLoading();
}
