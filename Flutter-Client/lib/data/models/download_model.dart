import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/download.dart';

part 'download_model.g.dart';

@JsonSerializable()
class DownloadModel {
  DownloadModel({
    required this.id,
    required this.url,
    required this.title,
    required this.status,
    this.thumbnail,
    this.folder,
    this.quality,
    this.format,
    this.progress,
    this.speed,
    this.eta,
    this.fileSize,
    this.downloadedSize,
    this.error,
    this.timestamp,
    // Rich metadata
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

  factory DownloadModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadModelFromJson(json);

  final String id;
  final String url;
  final String title;
  final String status;
  final String? thumbnail;
  final String? folder;
  final String? quality;
  final String? format;
  final double? progress;
  final String? speed;
  final String? eta;
  @JsonKey(name: 'total_bytes')
  final int? fileSize;
  @JsonKey(name: 'downloaded_bytes')
  final int? downloadedSize;
  final String? error;
  final String? timestamp;

  // Rich metadata fields
  final String? description;
  final int? duration;
  final String? uploader;
  @JsonKey(name: 'view_count')
  final int? viewCount;
  @JsonKey(name: 'upload_date')
  final String? uploadDate;
  @JsonKey(name: 'webpage_url')
  final String? webpageUrl;
  final String? extractor;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @JsonKey(name: 'channel_url')
  final String? channelUrl;

  Map<String, dynamic> toJson() => _$DownloadModelToJson(this);

  /// Convert to domain entity
  Download toEntity() {
    return Download(
      id: id,
      url: url,
      title: title,
      status: _parseStatus(status),
      thumbnail: thumbnail,
      folder: folder,
      quality: quality,
      format: format,
      progress: progress ?? 0.0,
      speed: speed,
      eta: eta,
      fileSize: fileSize,
      downloadedSize: downloadedSize,
      error: error,
      timestamp: timestamp != null ? DateTime.tryParse(timestamp!) : null,
      description: description,
      duration: duration,
      uploader: uploader,
      viewCount: viewCount,
      uploadDate: uploadDate,
      webpageUrl: webpageUrl,
      extractor: extractor,
      likeCount: likeCount,
      channelId: channelId,
      channelUrl: channelUrl,
    );
  }

  /// Create from domain entity
  factory DownloadModel.fromEntity(Download download) {
    return DownloadModel(
      id: download.id,
      url: download.url,
      title: download.title,
      status: _statusToString(download.status),
      thumbnail: download.thumbnail,
      folder: download.folder,
      quality: download.quality,
      format: download.format,
      progress: download.progress,
      speed: download.speed,
      eta: download.eta,
      fileSize: download.fileSize,
      downloadedSize: download.downloadedSize,
      error: download.error,
      timestamp: download.timestamp?.toIso8601String(),
      description: download.description,
      duration: download.duration,
      uploader: download.uploader,
      viewCount: download.viewCount,
      uploadDate: download.uploadDate,
      webpageUrl: download.webpageUrl,
      extractor: download.extractor,
      likeCount: download.likeCount,
      channelId: download.channelId,
      channelUrl: download.channelUrl,
    );
  }

  static DownloadStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
      case 'preparing':
        return DownloadStatus.downloading;
      case 'finished':
      case 'completed':
        return DownloadStatus.completed;
      case 'error':
        return DownloadStatus.error;
      case 'canceled':
      case 'cancelled':
        return DownloadStatus.canceled;
      default:
        return DownloadStatus.pending;
    }
  }

  static String _statusToString(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return 'pending';
      case DownloadStatus.downloading:
        return 'downloading';
      case DownloadStatus.completed:
        return 'finished';
      case DownloadStatus.error:
        return 'error';
      case DownloadStatus.canceled:
        return 'canceled';
    }
  }
}
