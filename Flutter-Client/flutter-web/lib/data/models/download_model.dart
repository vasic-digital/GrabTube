import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/download.dart';

part 'download_model.g.dart';

/// Download model for JSON serialization
@JsonSerializable()
class DownloadModel {
  final String id;
  final String url;
  final String title;
  final String status;
  final double? progress;
  final int? speed;
  final int? eta;
  @JsonKey(name: 'downloaded_bytes')
  final int? downloadedBytes;
  @JsonKey(name: 'total_bytes')
  final int? totalBytes;
  final String quality;
  final String format;
  final String? folder;
  final String? thumbnail;
  final int? duration;
  final String? error;
  @JsonKey(name: 'added_at')
  final String? addedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;

  const DownloadModel({
    required this.id,
    required this.url,
    required this.title,
    required this.status,
    this.progress,
    this.speed,
    this.eta,
    this.downloadedBytes,
    this.totalBytes,
    required this.quality,
    required this.format,
    this.folder,
    this.thumbnail,
    this.duration,
    this.error,
    this.addedAt,
    this.completedAt,
  });

  /// Create from JSON
  factory DownloadModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$DownloadModelToJson(this);

  /// Convert to domain entity
  Download toEntity() {
    return Download(
      id: id,
      url: url,
      title: title,
      status: _parseStatus(status),
      progress: progress ?? 0.0,
      speed: speed ?? 0,
      eta: eta,
      downloadedBytes: downloadedBytes ?? 0,
      totalBytes: totalBytes ?? 0,
      quality: quality,
      format: format,
      folder: folder,
      thumbnail: thumbnail,
      duration: duration,
      error: error,
      addedAt: addedAt != null ? DateTime.parse(addedAt!) : DateTime.now(),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
    );
  }

  /// Create from domain entity
  factory DownloadModel.fromEntity(Download download) {
    return DownloadModel(
      id: download.id,
      url: download.url,
      title: download.title,
      status: _statusToString(download.status),
      progress: download.progress,
      speed: download.speed,
      eta: download.eta,
      downloadedBytes: download.downloadedBytes,
      totalBytes: download.totalBytes,
      quality: download.quality,
      format: download.format,
      folder: download.folder,
      thumbnail: download.thumbnail,
      duration: download.duration,
      error: download.error,
      addedAt: download.addedAt.toIso8601String(),
      completedAt: download.completedAt?.toIso8601String(),
    );
  }

  /// Parse status string to enum
  static DownloadStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
      case 'active':
        return DownloadStatus.downloading;
      case 'completed':
      case 'finished':
        return DownloadStatus.completed;
      case 'error':
      case 'failed':
        return DownloadStatus.error;
      case 'canceled':
      case 'cancelled':
        return DownloadStatus.canceled;
      default:
        return DownloadStatus.pending;
    }
  }

  /// Convert status enum to string
  static String _statusToString(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return 'pending';
      case DownloadStatus.downloading:
        return 'downloading';
      case DownloadStatus.completed:
        return 'completed';
      case DownloadStatus.error:
        return 'error';
      case DownloadStatus.canceled:
        return 'canceled';
    }
  }
}

/// Add download request model
@JsonSerializable()
class AddDownloadRequest {
  final String url;
  final String quality;
  final String format;
  final String? folder;
  @JsonKey(name: 'auto_start')
  final bool autoStart;

  const AddDownloadRequest({
    required this.url,
    required this.quality,
    required this.format,
    this.folder,
    this.autoStart = true,
  });

  factory AddDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$AddDownloadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddDownloadRequestToJson(this);
}

/// Add download response model
@JsonSerializable()
class AddDownloadResponse {
  final String status;
  final DownloadModel? download;
  final String? error;

  const AddDownloadResponse({
    required this.status,
    this.download,
    this.error,
  });

  factory AddDownloadResponse.fromJson(Map<String, dynamic> json) =>
      _$AddDownloadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddDownloadResponseToJson(this);
}
