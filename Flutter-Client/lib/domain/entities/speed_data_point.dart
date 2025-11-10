import 'package:equatable/equatable.dart';

/// Speed data point entity for tracking download/upload speeds over time
class SpeedDataPoint extends Equatable {
  const SpeedDataPoint({
    required this.timestamp,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  /// Timestamp when this speed was recorded
  final DateTime timestamp;

  /// Download speed in bytes per second
  final double downloadSpeed;

  /// Upload speed in bytes per second
  final double uploadSpeed;

  /// Create from JSON
  factory SpeedDataPoint.fromJson(Map<String, dynamic> json) {
    return SpeedDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int,
      ),
      downloadSpeed: (json['downloadSpeed'] as num?)?.toDouble() ?? 0.0,
      uploadSpeed: (json['uploadSpeed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
    };
  }

  /// Get formatted download speed (e.g., "1.5 MB/s")
  String get formattedDownloadSpeed => _formatSpeed(downloadSpeed);

  /// Get formatted upload speed (e.g., "50 KB/s")
  String get formattedUploadSpeed => _formatSpeed(uploadSpeed);

  /// Format speed in bytes/sec to human-readable format
  String _formatSpeed(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  @override
  List<Object?> get props => [
        timestamp,
        downloadSpeed,
        uploadSpeed,
      ];
}
