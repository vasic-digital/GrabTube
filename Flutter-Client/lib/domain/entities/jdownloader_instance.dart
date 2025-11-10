import 'package:equatable/equatable.dart';

/// JDownloader instance status enum
enum JDownloaderStatus {
  online,
  offline,
  downloading,
  paused,
  error,
}

/// JDownloader instance entity representing a connected JDownloader device
class JDownloaderInstance extends Equatable {
  const JDownloaderInstance({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.status,
    this.host,
    this.port,
    this.downloadSpeed,
    this.uploadSpeed,
    this.activeDownloads,
    this.totalDownloads,
    this.freeSpace,
    this.totalSpace,
    this.version,
    this.lastConnected,
    this.errorMessage,
  });

  /// Unique instance identifier
  final String id;

  /// User-friendly name for this instance
  final String name;

  /// JDownloader device ID
  final String deviceId;

  /// Current status of the JDownloader instance
  final JDownloaderStatus status;

  /// Host address (IP or hostname)
  final String? host;

  /// Port number
  final int? port;

  /// Current download speed in bytes per second
  final int? downloadSpeed;

  /// Current upload speed in bytes per second
  final int? uploadSpeed;

  /// Number of active downloads
  final int? activeDownloads;

  /// Total number of downloads in queue
  final int? totalDownloads;

  /// Free disk space in bytes
  final int? freeSpace;

  /// Total disk space in bytes
  final int? totalSpace;

  /// JDownloader version
  final String? version;

  /// Last time the instance was connected
  final DateTime? lastConnected;

  /// Error message if status is error
  final String? errorMessage;

  /// Check if instance is online
  bool get isOnline =>
      status == JDownloaderStatus.online ||
      status == JDownloaderStatus.downloading ||
      status == JDownloaderStatus.paused;

  /// Check if instance is currently downloading
  bool get isDownloading => status == JDownloaderStatus.downloading;

  /// Check if instance has error
  bool get hasError => status == JDownloaderStatus.error;

  /// Check if instance is paused
  bool get isPaused => status == JDownloaderStatus.paused;

  /// Get formatted download speed (e.g., "1.5 MB/s")
  String get formattedDownloadSpeed {
    if (downloadSpeed == null || downloadSpeed == 0) return '0 B/s';
    return _formatSpeed(downloadSpeed!);
  }

  /// Get formatted upload speed (e.g., "50 KB/s")
  String get formattedUploadSpeed {
    if (uploadSpeed == null || uploadSpeed == 0) return '0 B/s';
    return _formatSpeed(uploadSpeed!);
  }

  /// Get formatted free space (e.g., "1.5 GB")
  String get formattedFreeSpace {
    if (freeSpace == null) return 'Unknown';
    return _formatBytes(freeSpace!);
  }

  /// Get formatted total space (e.g., "2 GB")
  String get formattedTotalSpace {
    if (totalSpace == null) return 'Unknown';
    return _formatBytes(totalSpace!);
  }

  /// Get disk usage percentage
  double get diskUsagePercentage {
    if (freeSpace == null || totalSpace == null || totalSpace == 0) return 0.0;
    final usedSpace = totalSpace! - freeSpace!;
    return (usedSpace / totalSpace!) * 100;
  }

  /// Format speed in bytes/sec to human-readable format
  String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '$bytesPerSec B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Format bytes to human-readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Create a copy with updated fields
  JDownloaderInstance copyWith({
    String? id,
    String? name,
    String? deviceId,
    JDownloaderStatus? status,
    String? host,
    int? port,
    int? downloadSpeed,
    int? uploadSpeed,
    int? activeDownloads,
    int? totalDownloads,
    int? freeSpace,
    int? totalSpace,
    String? version,
    DateTime? lastConnected,
    String? errorMessage,
  }) {
    return JDownloaderInstance(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      host: host ?? this.host,
      port: port ?? this.port,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      freeSpace: freeSpace ?? this.freeSpace,
      totalSpace: totalSpace ?? this.totalSpace,
      version: version ?? this.version,
      lastConnected: lastConnected ?? this.lastConnected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        deviceId,
        status,
        host,
        port,
        downloadSpeed,
        uploadSpeed,
        activeDownloads,
        totalDownloads,
        freeSpace,
        totalSpace,
        version,
        lastConnected,
        errorMessage,
      ];
}
