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
      thumbnail: json['thumbnail'] as String?,
      folder: json['folder'] as String?,
      quality: json['quality'] as String?,
      format: json['format'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      speed: json['speed'] as String?,
      eta: json['eta'] as String?,
      fileSize: (json['total_bytes'] as num?)?.toInt(),
      downloadedSize: (json['downloaded_bytes'] as num?)?.toInt(),
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String?,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      uploader: json['uploader'] as String?,
      viewCount: (json['view_count'] as num?)?.toInt(),
      uploadDate: json['upload_date'] as String?,
      webpageUrl: json['webpage_url'] as String?,
      extractor: json['extractor'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt(),
      channelId: json['channel_id'] as String?,
      channelUrl: json['channel_url'] as String?,
    );

Map<String, dynamic> _$DownloadModelToJson(DownloadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'status': instance.status,
      'thumbnail': instance.thumbnail,
      'folder': instance.folder,
      'quality': instance.quality,
      'format': instance.format,
      'progress': instance.progress,
      'speed': instance.speed,
      'eta': instance.eta,
      'total_bytes': instance.fileSize,
      'downloaded_bytes': instance.downloadedSize,
      'error': instance.error,
      'timestamp': instance.timestamp,
      'description': instance.description,
      'duration': instance.duration,
      'uploader': instance.uploader,
      'view_count': instance.viewCount,
      'upload_date': instance.uploadDate,
      'webpage_url': instance.webpageUrl,
      'extractor': instance.extractor,
      'like_count': instance.likeCount,
      'channel_id': instance.channelId,
      'channel_url': instance.channelUrl,
    };
