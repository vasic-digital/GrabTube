// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadModel _$DownloadModelFromJson(Map<String, dynamic> json) =>
    DownloadModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toInt(),
      eta: (json['eta'] as num?)?.toInt(),
      downloadedBytes: (json['downloaded_bytes'] as num?)?.toInt(),
      totalBytes: (json['total_bytes'] as num?)?.toInt(),
      quality: json['quality'] as String,
      format: json['format'] as String,
      folder: json['folder'] as String?,
      thumbnail: json['thumbnail'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      error: json['error'] as String?,
      addedAt: json['added_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );

Map<String, dynamic> _$DownloadModelToJson(DownloadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'status': instance.status,
      'progress': instance.progress,
      'speed': instance.speed,
      'eta': instance.eta,
      'downloaded_bytes': instance.downloadedBytes,
      'total_bytes': instance.totalBytes,
      'quality': instance.quality,
      'format': instance.format,
      'folder': instance.folder,
      'thumbnail': instance.thumbnail,
      'duration': instance.duration,
      'error': instance.error,
      'added_at': instance.addedAt,
      'completed_at': instance.completedAt,
    };

AddDownloadRequest _$AddDownloadRequestFromJson(Map<String, dynamic> json) =>
    AddDownloadRequest(
      url: json['url'] as String,
      quality: json['quality'] as String,
      format: json['format'] as String,
      folder: json['folder'] as String?,
      autoStart: json['auto_start'] as bool? ?? true,
    );

Map<String, dynamic> _$AddDownloadRequestToJson(AddDownloadRequest instance) =>
    <String, dynamic>{
      'url': instance.url,
      'quality': instance.quality,
      'format': instance.format,
      'folder': instance.folder,
      'auto_start': instance.autoStart,
    };

AddDownloadResponse _$AddDownloadResponseFromJson(Map<String, dynamic> json) =>
    AddDownloadResponse(
      status: json['status'] as String,
      download: json['download'] == null
          ? null
          : DownloadModel.fromJson(json['download'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AddDownloadResponseToJson(
        AddDownloadResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'download': instance.download,
      'error': instance.error,
    };
