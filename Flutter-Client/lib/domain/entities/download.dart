import 'package:equatable/equatable.dart';

/// Download status enum
enum DownloadStatus {
  pending,
  downloading,
  completed,
  error,
  canceled,
}

/// Download entity representing a single download task
class Download extends Equatable {
  const Download({
    required this.id,
    required this.url,
    required this.title,
    required this.status,
    this.thumbnail,
    this.folder,
    this.quality,
    this.format,
    this.progress = 0.0,
    this.speed,
    this.eta,
    this.fileSize,
    this.downloadedSize,
    this.error,
    this.timestamp,
    // Rich metadata fields
    this.description,
    this.duration,
    this.uploader,
    this.viewCount,
    this.uploadDate,
    this.webpageUrl,
    this.extractor,
    this.likeCount,
    this.channelId,
    this.channelUrl,
  });

  final String id;
  final String url;
  final String title;
  final DownloadStatus status;
  final String? thumbnail;
  final String? folder;
  final String? quality;
  final String? format;
  final double progress;
  final String? speed;
  final String? eta;
  final int? fileSize;
  final int? downloadedSize;
  final String? error;
  final DateTime? timestamp;

  // Rich metadata fields
  final String? description;
  final int? duration; // Duration in seconds
  final String? uploader;
  final int? viewCount;
  final String? uploadDate;
  final String? webpageUrl;
  final String? extractor;
  final int? likeCount;
  final String? channelId;
  final String? channelUrl;

  /// Create a copy with updated fields
  Download copyWith({
    String? id,
    String? url,
    String? title,
    DownloadStatus? status,
    String? thumbnail,
    String? folder,
    String? quality,
    String? format,
    double? progress,
    String? speed,
    String? eta,
    int? fileSize,
    int? downloadedSize,
    String? error,
    DateTime? timestamp,
    String? description,
    int? duration,
    String? uploader,
    int? viewCount,
    String? uploadDate,
    String? webpageUrl,
    String? extractor,
    int? likeCount,
    String? channelId,
    String? channelUrl,
  }) {
    return Download(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      status: status ?? this.status,
      thumbnail: thumbnail ?? this.thumbnail,
      folder: folder ?? this.folder,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      fileSize: fileSize ?? this.fileSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      uploader: uploader ?? this.uploader,
      viewCount: viewCount ?? this.viewCount,
      uploadDate: uploadDate ?? this.uploadDate,
      webpageUrl: webpageUrl ?? this.webpageUrl,
      extractor: extractor ?? this.extractor,
      likeCount: likeCount ?? this.likeCount,
      channelId: channelId ?? this.channelId,
      channelUrl: channelUrl ?? this.channelUrl,
    );
  }

  /// Get progress percentage (0-100)
  int get progressPercentage => (progress * 100).round();

  /// Check if download is active
  bool get isActive => status == DownloadStatus.downloading;

  /// Check if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download has error
  bool get hasError => status == DownloadStatus.error;

  /// Check if download is pending
  bool get isPending => status == DownloadStatus.pending;

  /// Check if download is canceled
  bool get isCanceled => status == DownloadStatus.canceled;

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        status,
        thumbnail,
        folder,
        quality,
        format,
        progress,
        speed,
        eta,
        fileSize,
        downloadedSize,
        error,
        timestamp,
        description,
        duration,
        uploader,
        viewCount,
        uploadDate,
        webpageUrl,
        extractor,
        likeCount,
        channelId,
        channelUrl,
      ];
}
