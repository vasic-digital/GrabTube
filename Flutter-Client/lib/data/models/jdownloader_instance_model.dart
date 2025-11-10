import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/jdownloader_instance.dart';

part 'jdownloader_instance_model.g.dart';

@JsonSerializable()
class JDownloaderInstanceModel {
  JDownloaderInstanceModel({
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

  factory JDownloaderInstanceModel.fromJson(Map<String, dynamic> json) =>
      _$JDownloaderInstanceModelFromJson(json);

  final String id;
  final String name;

  @JsonKey(name: 'device_id')
  final String deviceId;

  final String status;
  final String? host;
  final int? port;

  @JsonKey(name: 'download_speed')
  final int? downloadSpeed;

  @JsonKey(name: 'upload_speed')
  final int? uploadSpeed;

  @JsonKey(name: 'active_downloads')
  final int? activeDownloads;

  @JsonKey(name: 'total_downloads')
  final int? totalDownloads;

  @JsonKey(name: 'free_space')
  final int? freeSpace;

  @JsonKey(name: 'total_space')
  final int? totalSpace;

  final String? version;

  @JsonKey(name: 'last_connected')
  final String? lastConnected;

  @JsonKey(name: 'error_message')
  final String? errorMessage;

  Map<String, dynamic> toJson() => _$JDownloaderInstanceModelToJson(this);

  /// Convert to domain entity
  JDownloaderInstance toEntity() {
    return JDownloaderInstance(
      id: id,
      name: name,
      deviceId: deviceId,
      status: _parseStatus(status),
      host: host,
      port: port,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      activeDownloads: activeDownloads,
      totalDownloads: totalDownloads,
      freeSpace: freeSpace,
      totalSpace: totalSpace,
      version: version,
      lastConnected:
          lastConnected != null ? DateTime.parse(lastConnected!) : null,
      errorMessage: errorMessage,
    );
  }

  /// Create from domain entity
  factory JDownloaderInstanceModel.fromEntity(JDownloaderInstance entity) {
    return JDownloaderInstanceModel(
      id: entity.id,
      name: entity.name,
      deviceId: entity.deviceId,
      status: entity.status.name,
      host: entity.host,
      port: entity.port,
      downloadSpeed: entity.downloadSpeed,
      uploadSpeed: entity.uploadSpeed,
      activeDownloads: entity.activeDownloads,
      totalDownloads: entity.totalDownloads,
      freeSpace: entity.freeSpace,
      totalSpace: entity.totalSpace,
      version: entity.version,
      lastConnected: entity.lastConnected?.toIso8601String(),
      errorMessage: entity.errorMessage,
    );
  }

  static JDownloaderStatus _parseStatus(String status) {
    switch (status) {
      case 'online':
        return JDownloaderStatus.online;
      case 'offline':
        return JDownloaderStatus.offline;
      case 'downloading':
        return JDownloaderStatus.downloading;
      case 'paused':
        return JDownloaderStatus.paused;
      case 'error':
        return JDownloaderStatus.error;
      default:
        return JDownloaderStatus.offline;
    }
  }
}
