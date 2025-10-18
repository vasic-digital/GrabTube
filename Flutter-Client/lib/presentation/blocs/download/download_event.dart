import 'package:equatable/equatable.dart';

/// Base class for download events
abstract class DownloadEvent extends Equatable {
  const DownloadEvent();

  @override
  List<Object?> get props => [];
}

/// Load all downloads
class LoadDownloads extends DownloadEvent {
  const LoadDownloads();
}

/// Add a new download
class AddDownload extends DownloadEvent {
  const AddDownload({
    required this.url,
    this.quality,
    this.format,
    this.folder,
    this.autoStart,
  });

  final String url;
  final String? quality;
  final String? format;
  final String? folder;
  final bool? autoStart;

  @override
  List<Object?> get props => [url, quality, format, folder, autoStart];
}

/// Delete downloads
class DeleteDownloads extends DownloadEvent {
  const DeleteDownloads({
    required this.ids,
    this.where = 'queue',
  });

  final List<String> ids;
  final String where;

  @override
  List<Object?> get props => [ids, where];
}

/// Start downloads
class StartDownloads extends DownloadEvent {
  const StartDownloads({required this.ids});

  final List<String> ids;

  @override
  List<Object?> get props => [ids];
}

/// Clear completed downloads
class ClearCompleted extends DownloadEvent {
  const ClearCompleted();
}

/// Download was updated (from socket)
class DownloadUpdated extends DownloadEvent {
  const DownloadUpdated(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Download was added (from socket)
class DownloadAdded extends DownloadEvent {
  const DownloadAdded();
}

/// Download was completed (from socket)
class DownloadCompleted extends DownloadEvent {
  const DownloadCompleted(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Download was canceled (from socket)
class DownloadCanceled extends DownloadEvent {
  const DownloadCanceled(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Refresh downloads
class RefreshDownloads extends DownloadEvent {
  const RefreshDownloads();
}

/// Get video info
class GetVideoInfo extends DownloadEvent {
  const GetVideoInfo({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}
