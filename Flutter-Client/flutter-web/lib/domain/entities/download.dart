import 'package:equatable/equatable.dart';

/// Download status enum
enum DownloadStatus {
  pending,
  downloading,
  completed,
  error,
  canceled,
}

/// Download entity representing a video download
class Download extends Equatable {
  /// Unique identifier
  final String id;

  /// Video URL
  final String url;

  /// Video title
  final String title;

  /// Download status
  final DownloadStatus status;

  /// Download progress (0.0 to 1.0)
  final double progress;

  /// Download speed in bytes per second
  final int speed;

  /// Estimated time remaining in seconds
  final int? eta;

  /// Downloaded bytes
  final int downloadedBytes;

  /// Total bytes
  final int totalBytes;

  /// Selected quality (e.g., "1080", "best")
  final String quality;

  /// Selected format (e.g., "mp4", "webm")
  final String format;

  /// Custom download folder
  final String? folder;

  /// Thumbnail URL
  final String? thumbnail;

  /// Duration in seconds
  final int? duration;

  /// Error message if status is error
  final String? error;

  /// Timestamp when added
  final DateTime addedAt;

  /// Timestamp when completed
  final DateTime? completedAt;

  const Download({
    required this.id,
    required this.url,
    required this.title,
    required this.status,
    this.progress = 0.0,
    this.speed = 0,
    this.eta,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    required this.quality,
    required this.format,
    this.folder,
    this.thumbnail,
    this.duration,
    this.error,
    required this.addedAt,
    this.completedAt,
  });

  /// Check if download is active
  bool get isActive => status == DownloadStatus.downloading;

  /// Check if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download is pending
  bool get isPending => status == DownloadStatus.pending;

  /// Check if download has error
  bool get hasError => status == DownloadStatus.error;

  /// Check if download is canceled
  bool get isCanceled => status == DownloadStatus.canceled;

  /// Get formatted file size
  String get formattedSize {
    if (totalBytes == 0) return 'Unknown';
    final mb = totalBytes / (1024 * 1024);
    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }

  /// Get formatted progress percentage
  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  /// Create a copy with updated fields
  Download copyWith({
    String? id,
    String? url,
    String? title,
    DownloadStatus? status,
    double? progress,
    int? speed,
    int? eta,
    int? downloadedBytes,
    int? totalBytes,
    String? quality,
    String? format,
    String? folder,
    String? thumbnail,
    int? duration,
    String? error,
    DateTime? addedAt,
    DateTime? completedAt,
  }) {
    return Download(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      folder: folder ?? this.folder,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      error: error ?? this.error,
      addedAt: addedAt ?? this.addedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        status,
        progress,
        speed,
        eta,
        downloadedBytes,
        totalBytes,
        quality,
        format,
        folder,
        thumbnail,
        duration,
        error,
        addedAt,
        completedAt,
      ];
}
