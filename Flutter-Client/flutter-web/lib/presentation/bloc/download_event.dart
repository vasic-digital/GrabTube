import 'package:equatable/equatable.dart';

/// Base class for download events
abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all downloads
class LoadDownloads extends DownloadEvent {
  const LoadDownloads();
}

/// Event to refresh downloads
class RefreshDownloads extends DownloadEvent {
  const RefreshDownloads();
}

/// Event to add a new download
class AddDownload extends DownloadEvent {
  final String url;
  final String quality;
  final String format;
  final String? folder;
  final bool autoStart;

  const AddDownload({
    required this.url,
    required this.quality,
    required this.format,
    this.folder,
    this.autoStart = true,
  });

  @override
  List<Object?> get props => [url, quality, format, folder, autoStart];
}

/// Event to start a pending download
class StartDownload extends DownloadEvent {
  final String id;

  const StartDownload(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to cancel an active download
class CancelDownload extends DownloadEvent {
  final String id;

  const CancelDownload(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to delete a download
class DeleteDownload extends DownloadEvent {
  final String id;

  const DeleteDownload(this.id);

  @override
  List<Object> get props => [id];
}

/// Event to clear all completed downloads
class ClearCompleted extends DownloadEvent {
  const ClearCompleted();
}

/// Event when a download is updated via WebSocket
class DownloadUpdated extends DownloadEvent {
  final String id;
  final Map<String, dynamic> data;

  const DownloadUpdated({
    required this.id,
    required this.data,
  });

  @override
  List<Object> get props => [id, data];
}

/// Event when a download is added via WebSocket
class DownloadAdded extends DownloadEvent {
  final Map<String, dynamic> data;

  const DownloadAdded(this.data);

  @override
  List<Object> get props => [data];
}

/// Event when a download is deleted via WebSocket
class DownloadDeleted extends DownloadEvent {
  final String id;

  const DownloadDeleted(this.id);

  @override
  List<Object> get props => [id];
}

/// Event when downloads are cleared via WebSocket
class DownloadsCleared extends DownloadEvent {
  const DownloadsCleared();
}

/// Event when WebSocket connection status changes
class ConnectionStatusChanged extends DownloadEvent {
  final bool isConnected;

  const ConnectionStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
